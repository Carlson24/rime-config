-- super_replacer.lua 一个rime 更灵活地滤镜转换器
-- https://github.com/amzxyz/rime-wanxiang
-- @amzxyz

local M = {}

-- 性能优化：本地化常用库函数
local insert = table.insert
local concat = table.concat
local s_match = string.match
local s_format = string.format
local s_byte = string.byte
local s_sub = string.sub
local s_gsub = string.gsub
local s_find = string.find
local s_lower = string.lower
local s_upper = string.upper
local t_sort = table.sort
local type = type
local DB_FORMAT_VERSION = "7"
local KEYMAP_EXPAND_CAP = 64
local KEYMAP_PREIMAGE_CAP = 4096

-- 模块私有 store 池：相同签名的数据共享同一份内存 store，引用计数管理生命周期。
local STORE_CACHE = {}
local VALUE_SEPARATOR = "\\t"
local VALUE_SEPARATOR_LEN = #VALUE_SEPARATOR
local CANDIDATE_LIMIT = 100
local EXACT_CACHE_PREFIX = "\1"

-- 基础依赖
local wanxiang = require("wanxiang")

local function clear_array(t)
  for i = #t, 1, -1 do t[i] = nil end
end

local function clear_table(t)
  for key in pairs(t) do t[key] = nil end
end

local function generate_files_signature(tasks)
  local parts = {}
  local seen = {}

  for _, task in ipairs(tasks) do
    if not seen[task.path] then
      seen[task.path] = true
      parts[#parts + 1] = (task.source or task.path) .. "|" .. wanxiang.get_file_signature(task.path)
    end
  end

  return wanxiang.digest_parts(parts)
end

local function each_file_value(rule, callback)
  local function each_item(item)
    if not item then return end

    if item.type == "kList" then
      local list = item:get_list()
      for i = 0, list.size - 1 do
        local value = list:get_value_at(i)
        if value then callback(value) end
      end
    elseif item.type == "kScalar" then
      local value = item:get_value()
      if value then callback(value) end
    end
  end

  each_item(rule:get("files"))
  each_item(rule:get("file"))
end

local function task_signature(task)
  return (task.source or "")
      .. "|" .. (task.prefix or "")
end

local function tasks_signature(tasks)
  local parts = {}
  for i, task in ipairs(tasks) do
    parts[i] = task_signature(task)
  end
  return wanxiang.digest_parts(parts)
end

local function next_value(value, start)
  local pos = s_find(value, VALUE_SEPARATOR, start, true)
  if pos then
    return s_sub(value, start, pos - 1), pos + VALUE_SEPARATOR_LEN
  end
  if start == 1 then return value, nil end
  return s_sub(value, start), nil
end

local function parse_source_line(line)
  local key, value = s_match(line, "^([^\t]+)\t+(.+)$")
  if not key or not value or key == "" or value == "" then return nil, nil end
  value = s_gsub(value, "\t", VALUE_SEPARATOR)
  return key, value
end

local function fetch_aggregate(store, key)
  return wanxiang.blob_fetch(store.data, store.pos, key)
end

local function fetch_exact_cached(store, key, query_cache)
  local cache_key = EXACT_CACHE_PREFIX .. key
  local value = query_cache[cache_key]
  if value ~= nil then return value or nil end

  value = fetch_aggregate(store, key)
  query_cache[cache_key] = value or false
  return value
end

-- 部署时预展开：把 keymap 布局（14/18/t9）的展开结果烘焙进 store，
-- 使输入时简码查询退化为单次精确取数，不再每次击键做笛卡尔展开。
-- 只对简码规则前缀生效；26 键等无展开表的布局直接跳过。
local function expand_store_with_keymap(map, abbrev_prefixes, keymap_id)
  local expand = wanxiang.build_keymap_expand(keymap_id)
  if not expand then return end
  local preimage = wanxiang.build_keymap_preimage(keymap_id)
  if not preimage or not abbrev_prefixes or #abbrev_prefixes == 0 then return end

  -- 收集所有「展开能命中 store」的可输入码：对每个 store key 的编码逐字符
  -- 替换为能产生该字母的按键（含原字母自身），枚举全部写法后去重。
  local bucket = {}

  local function enumerate_code(prefix, code)
    local n = 0
    local capped = false
    local function rec(i, acc)
      if capped then return end
      if i > #code then
        n = n + 1
        bucket[prefix .. acc] = true
        return
      end
      local ch = code:sub(i, i)
      local set = preimage[ch]
      if not set or #set == 1 then
        rec(i + 1, acc .. ch)
      else
        for _, c in ipairs(set) do
          rec(i + 1, acc .. c)
          if n >= KEYMAP_PREIMAGE_CAP then
            capped = true
            return
          end
        end
      end
    end
    rec(1, "")
  end

  for _, prefix in ipairs(abbrev_prefixes) do
    local plen = #prefix
    for store_key in pairs(map) do
      if s_sub(store_key, 1, plen) == prefix then
        enumerate_code(prefix, s_sub(store_key, plen + 1))
      end
    end
  end

  -- 两阶段写回：先基于原始 map 计算合并值，避免使用已被覆盖的条目二次合并。
  local additions = {}
  for full_key in pairs(bucket) do
    local prefix, code
    for _, p in ipairs(abbrev_prefixes) do
      if s_sub(full_key, 1, #p) == p then
        prefix = p
        code = s_sub(full_key, #p + 1)
        break
      end
    end
    if prefix then
      local parts = {}
      local seen = {}
      local expanded = wanxiang.expand_keymap_code(code, expand, KEYMAP_EXPAND_CAP)
      for _, ec in ipairs(expanded) do
        local ev = map[prefix .. ec]
        if ev then
          local pos = 1
          while pos do
            local item
            item, pos = next_value(ev, pos)
            if item ~= "" and not seen[item] then
              seen[item] = true
              parts[#parts + 1] = item
            end
          end
        end
      end

      local merged = #parts > 0 and concat(parts, VALUE_SEPARATOR) or nil
      if not merged then merged = map[full_key] end
      if merged and merged ~= map[full_key] then
        additions[full_key] = merged
      end
    end
  end

  for k, v in pairs(additions) do
    map[k] = v
  end
end

-- 构建内存 store：所有任务逐行解析，按 prefix..key 聚合，
-- 编码为 "key\tvalue\n" 单串 blob + 偏移索引 pos。
local function build_store(tasks, keymap_id, abbrev_prefixes)
  local map = {}
  local written = {}
  local invalid_count = 0

  for _, task in ipairs(tasks) do
    local prefix = task.prefix
    local file, close = wanxiang.load_file_with_fallback(task.path, "r")

    if file then
      for line in file:lines() do
        if line ~= "" and not s_match(line, "^%s*#") then
          local key, value = parse_source_line(line)

          if key and value then
            value = s_match(value, "^%s*(.-)%s*$")
            local store_key = prefix .. key

            if written[store_key] then
              local existing = map[store_key]
              if existing then
                map[store_key] = existing .. VALUE_SEPARATOR .. value
              end
            else
              map[store_key] = value
              written[store_key] = true
            end
          else
            invalid_count = invalid_count + 1
          end
        end
      end

      close()
    end
  end

  if log and log.warning and invalid_count > 0 then
    log.warning(s_format(
      "super_replacer: 已跳过 %d 行无效数据，格式必须为 key<真实Tab>候选1\\t候选2",
      invalid_count
    ))
  end

  expand_store_with_keymap(map, abbrev_prefixes, keymap_id)

  local keys = {}
  for k in pairs(map) do
    keys[#keys + 1] = k
  end
  t_sort(keys)

  local data = wanxiang.blob_encode(keys, map)
  local pos = wanxiang.blob_index(data)

  return { data = data, pos = pos }
end

-- 连接 store：优先命中模块级缓存，其次读 blob 缓存，最后从文本重建。
local function connect_store(tasks, current_version, schema_id, keymap_id, abbrev_prefixes)
  local files_sig = generate_files_signature(tasks)
  local tasks_sig = tasks_signature(tasks)
  local prefixes = {}
  for i, p in ipairs(abbrev_prefixes or {}) do
    prefixes[i] = p
  end
  t_sort(prefixes)
  local signature = wanxiang.digest_parts({
    "super_replacer",
    current_version,
    DB_FORMAT_VERSION,
    files_sig,
    tasks_sig,
    schema_id,
    keymap_id or "",
    concat(prefixes, "|"),
  })

  local entry = STORE_CACHE[signature]
  if entry then
    entry.refs = entry.refs + 1
    return entry.store, signature, false
  end

  local cache_path = wanxiang.store_cache_path("replacer", schema_id)
  local store
  local built = false

  local blob = wanxiang.read_store_cache(cache_path, signature)
  if blob then
    store = { data = blob, pos = wanxiang.blob_index(blob) }
  else
    store = build_store(tasks, keymap_id, abbrev_prefixes)
    built = true
    if store then
      wanxiang.write_store_cache(cache_path, signature, store.data)
    end
  end

  if not store then return nil, signature, built end

  STORE_CACHE[signature] = { store = store, refs = 1 }
  return store, signature, built
end

-- 释放当前组件引用，并在最后一个使用者退出时回收 store。
local function release_store(env)
  local store = env.store
  local signature = env.store_sig

  env.store = nil
  env.store_sig = nil

  if not store or not signature then return end

  local entry = STORE_CACHE[signature]
  if not entry or entry.store ~= store then return end

  entry.refs = entry.refs - 1
  if entry.refs > 0 then return end

  STORE_CACHE[signature] = nil
end

-- 模块接口
function M.init(env)
  if env.store then release_store(env) end

  env.query_cache = {}
  env.shared_pending = {}
  env.shared_pending_comments = {}
  env.shared_comments = {}
  local ns = env.name_space
  ns = s_gsub(ns, "^%*", "")
  ns = string.match(ns, "([^%.]+)$") or ns
  local config = env.engine.schema.config

  -- 1. 获取根节点 Map 对象
  local cfg_root = config:get_map(ns)

  -- 2. 读取基础配置
  local delimiter = config:get_string("speller/delimiter") or " '"
  env.speller_delimiter = delimiter:sub(2, 2)

  local comment_fmt_val = cfg_root and cfg_root:get_value("comment_format")
  env.comment_format = comment_fmt_val and comment_fmt_val:get_string() or "〔%s〕"

  local current_version = "v0.0.2"
  if wanxiang and wanxiang.version then
    current_version = wanxiang.version
  end
  env.input_type = "unknown"
  if wanxiang and wanxiang.get_input_method_type then
    env.input_type = wanxiang.get_input_method_type(env)
  end

  local chain_val = cfg_root and cfg_root:get_value("chain")
  env.chain = chain_val and chain_val:get_bool() or false

  local keymap_val = cfg_root and cfg_root:get_value("keymap")
  local keymap_id = keymap_val and keymap_val:get_string()

  env.rules = {}
  local tasks = {}
  local abbrev_prefixes = {}
  local seen_abbrev_prefix = {}

  -- 3. 读取并遍历 rules 列表
  local rules_item = cfg_root and cfg_root:get("rules")
  local rule_list = rules_item and rules_item:get_list()

  if rule_list then
    for i = 0, rule_list.size - 1 do
      local rule_item = rule_list:get_at(i)
      local rule = rule_item and rule_item:get_map()
      if not rule then goto continue_rule end

      local function check_type_list(key)
        local item = rule:get(key)
        if not item then return nil end
        local list = item.type == "kList" and item:get_list()
        if not list then return nil end
        for k = 0, list.size - 1 do
          local val = list:get_value_at(k)
          if val and val:get_string() == env.input_type then return true end
        end
        return false
      end

      local is_only = check_type_list("only_types")
      if is_only == false then goto continue_rule end

      local is_excluded = check_type_list("exclude_types")
      if is_excluded == true then goto continue_rule end

      -- 解析 triggers
      local triggers = {}
      local opts_keys = { "option", "options" }
      for _, key in ipairs(opts_keys) do
        local opt_item = rule:get(key)
        if opt_item then
          if opt_item.type == "kList" then
            local list = opt_item:get_list()
            for k = 0, list.size - 1 do
              local val = list:get_value_at(k)
              local str = val and val:get_string()
              if str then insert(triggers, str) end
            end
          elseif opt_item.type == "kScalar" then
            local val = opt_item:get_value()
            if val:get_bool() == true then
              insert(triggers, true)
            else
              local str = val:get_string()
              if str and str ~= "true" then insert(triggers, str) end
            end
          end
        end
      end

      if #triggers == 0 then goto continue_rule end

      -- 解析 tags
      local target_tags = nil
      local tag_keys = { "tag", "tags" }
      for _, key in ipairs(tag_keys) do
        local tag_item = rule:get(key)
        if tag_item then
          if not target_tags then target_tags = {} end
          if tag_item.type == "kList" then
            local list = tag_item:get_list()
            for k = 0, list.size - 1 do
              local val = list:get_value_at(k)
              local str = val and val:get_string()
              if str then target_tags[str] = true end
            end
          elseif tag_item.type == "kScalar" then
            local val = tag_item:get_value()
            local str = val and val:get_string()
            if str then target_tags[str] = true end
          end
        end
      end

      -- 解析各项参数
      local prefix_val = rule:get_value("prefix")
      local prefix = prefix_val and prefix_val:get_string() or ""

      local mode_val = rule:get_value("mode")
      local mode = mode_val and mode_val:get_string() or "append"

      local comment_mode_val = rule:get_value("comment_mode")
      local comment_mode = comment_mode_val and comment_mode_val:get_string() or "comment"

      local custom_cand_type_val = rule:get_value("cand_type")
      local custom_cand_type = custom_cand_type_val and custom_cand_type_val:get_string()

      insert(env.rules, {
        triggers      = triggers,
        tags          = target_tags,
        prefix        = prefix,
        mode          = mode,
        comment_mode  = comment_mode,
        preedit_delim = nil,
        cand_type     = custom_cand_type,
      })

      if mode == "abbrev" and prefix ~= "" and not seen_abbrev_prefix[prefix] then
        seen_abbrev_prefix[prefix] = true
        abbrev_prefixes[#abbrev_prefixes + 1] = prefix
      end

      -- 解析文件路径列表
      each_file_value(rule, function(file_value)
        local source = file_value:get_string()
        if source and source ~= "" then
          tasks[#tasks + 1] = {
            source = source,
            path = source,
            prefix = prefix,
          }
        end
      end)

      ::continue_rule::
    end
  end

  -- 只使用当前方案的任务，隔离方案数据
  local current_id = env.engine.schema.schema_id or ""

  local store, signature, rebuilt = connect_store(tasks, current_version, current_id, keymap_id, abbrev_prefixes)
  env.store = store
  env.store_sig = signature

  if rebuilt then
    tasks = nil
    collectgarbage("collect")
  end
end

function M.fini(env)
  env.query_cache = nil
  env.shared_pending = nil
  env.shared_pending_comments = nil
  env.shared_comments = nil
  env.rules = nil

  release_store(env)
end

local function parse_item(p, delim)
  if delim and delim ~= "" then
    local pos = string.find(p, delim, 1, true)
    if pos then
      return string.sub(p, 1, pos - 1), string.sub(p, pos + #delim)
    end
  end
  return p, nil
end

function M.func(input, env)
  local ctx = env.engine.context
  local input_code = ctx.input
  local store = env.store
  local rules = env.rules
  local comment_fmt = env.comment_format
  local is_chain = env.chain
  local query_cache = env.query_cache
  if not query_cache then
    query_cache = {}
    env.query_cache = query_cache
  end

  if not ctx:is_composing() or ctx.input == "" then
    clear_table(query_cache)
    for cand in input:iter() do yield(cand) end
    return
  end

  if not rules or #rules == 0 or not store then
    for cand in input:iter() do yield(cand) end
    return
  end

  local seg = ctx.composition:back()
  local current_seg_tags = seg and seg.tags or {}
  if seg then input_code = s_sub(ctx.input, seg.start + 1, seg._end) end

  local active_rules = {}
  local active_abbrev_rules = {}

  local function is_rule_active(t)
    local option_active = false
    for _, trigger in ipairs(t.triggers) do
      if trigger == true then
        option_active = true
        break
      elseif type(trigger) == "string" and ctx:get_option(trigger) then
        option_active = true
        break
      end
    end
    if not option_active then return false end

    if t.tags then
      for req_tag in pairs(t.tags) do
        if current_seg_tags[req_tag] then return true end
      end
      return false
    end

    return true
  end

  for _, t in ipairs(rules) do
    if is_rule_active(t) then
      if t.mode == "abbrev" then
        active_abbrev_rules[#active_abbrev_rules + 1] = t
      else
        active_rules[#active_rules + 1] = t
      end
    end
  end

  local pending_texts = env.shared_pending or {}
  local pending_comments = env.shared_pending_comments or {}
  local shared_comments = env.shared_comments or {}
  local main_results = {}
  env.shared_pending = pending_texts
  env.shared_pending_comments = pending_comments
  env.shared_comments = shared_comments

  local function process_rules(cand, results)
    clear_array(results)
    clear_array(pending_texts)
    clear_array(pending_comments)
    clear_array(shared_comments)

    local current_text = cand.text
    local show_main = true
    local current_main_comment = cand.comment
    local matched_cand_type = nil
    local pending_count = 0

    for _, t in ipairs(active_rules) do
      local query_text = is_chain and current_text or cand.text
      local query_key = t.prefix .. query_text
      local val

      val = fetch_exact_cached(store, query_key, query_cache)

      if not val and s_find(query_text, "%u") then
        query_text = s_lower(query_text)
        query_key = t.prefix .. query_text
        val = fetch_exact_cached(store, query_key, query_cache)
      end

      if val then
        matched_cand_type = t.cand_type or matched_cand_type

        local mode = t.mode
        local rule_comment = ""
        if t.comment_mode == "text" then
          rule_comment = cand.text
        elseif t.comment_mode == "comment" then
          rule_comment = cand.comment
        end

        if mode ~= "comment" and rule_comment ~= "" then
          rule_comment = s_format(comment_fmt, rule_comment)
        end

        local value_pos = 1

        if mode == "comment" then
          while value_pos do
            local p
            p, value_pos = next_value(val, value_pos)
            if p ~= "" and p ~= input_code then
              shared_comments[#shared_comments + 1] = p
            end
          end
        elseif mode == "replace" and is_chain then
          local first = true
          while value_pos do
            local p
            p, value_pos = next_value(val, value_pos)
            if p ~= "" then
              if first then
                current_text = p
                if t.comment_mode == "none" then
                  current_main_comment = ""
                elseif t.comment_mode == "text" then
                  current_main_comment = cand.text
                end
                first = false
              else
                pending_count = pending_count + 1
                pending_texts[pending_count] = p
                pending_comments[pending_count] = rule_comment
              end
            end
          end
        elseif mode == "replace" or mode == "append" then
          if mode == "replace" then show_main = false end
          while value_pos do
            local p
            p, value_pos = next_value(val, value_pos)
            if p ~= "" then
              pending_count = pending_count + 1
              pending_texts[pending_count] = p
              pending_comments[pending_count] = rule_comment
            end
          end
        end
      end
    end

    if #shared_comments > 0 and not ctx:get_option("comment_off") then
      local appended = s_format(comment_fmt, concat(shared_comments, " "))
      if current_main_comment ~= "" then
        current_main_comment = current_main_comment .. " " .. appended
      else
        current_main_comment = appended
      end
    end

    local result_count = 0
    if show_main then
      result_count = 1
      if is_chain and current_text ~= cand.text then
        local final_type = matched_cand_type or cand.type or "kv"
        local nc = Candidate(final_type, cand.start, cand._end, current_text, current_main_comment)
        nc.preedit = cand.preedit
        nc.quality = cand.quality
        results[1] = nc
      else
        cand.comment = current_main_comment
        results[1] = cand
      end
    end

    local final_type = matched_cand_type or "derived"
    for i = 1, pending_count do
      local item_text = pending_texts[i]
      if not (show_main and item_text == current_text) then
        local nc = Candidate(final_type, cand.start, cand._end, item_text, pending_comments[i])
        nc.preedit = cand.preedit
        nc.quality = cand.quality
        result_count = result_count + 1
        results[result_count] = nc
      end
    end

    return results
  end

  local function trim_space(str)
    if not str or str == "" then return "" end

    local first = s_byte(str, 1)
    local last = s_byte(str, #str)
    if first > 32 and last > 32 then return str end
    return s_match(str, "^%s*(.-)%s*$")
  end

  local candidate_count = 0
  local function process_main(cand)
    candidate_count = candidate_count + 1
    if candidate_count <= CANDIDATE_LIMIT then
      return process_rules(cand, main_results)
    end

    clear_array(main_results)
    main_results[1] = cand
    return main_results
  end

  local global_yielded = {}

  -- 没有活跃简码规则时，跳过整套简码查询、排序与候选临时对象。
  if #active_abbrev_rules == 0 then
    for cand in input:iter() do
      local processed = process_main(cand)
      for _, pc in ipairs(processed) do
        local dedup_key = trim_space(pc.text)
        if not global_yielded[dedup_key] then
          global_yielded[dedup_key] = true
          yield(pc)
        end
      end
    end
    return
  end

  local seen_texts = {}
  local abbrev_cands = {}
  local aux_results = {}
  local abbrev_start = seg and seg.start or 0
  local abbrev_end = seg and seg._end or #ctx.input

  local function make_abbrev_candidate(item)
    local cand = Candidate(item.cand_type, abbrev_start, abbrev_end, item.text, "")
    cand.quality = item.quality
    if item.preedit then cand.preedit = item.preedit end
    return cand
  end

  local query_source = s_match(ctx.input, "^[a-zA-Z]+$") and ctx.input or input_code
  local query_code = s_gsub(query_source, env.speller_delimiter, "")
  local query_has_upper = s_find(query_code, "[A-Z]") ~= nil
  local upper_query = nil

  if query_code ~= "" then
    for _, t in ipairs(active_abbrev_rules) do
      -- keymap 布局（14/18/t9）的展开结果已由 build_store 在部署时烘焙进 store，
      -- 这里只做单次精确取数；大写回退保留（与现状一致）。
      local val = fetch_exact_cached(store, t.prefix .. query_code, query_cache)

      if not val and not query_has_upper then
        if not upper_query then upper_query = s_upper(query_code) end
        val = fetch_exact_cached(store, t.prefix .. upper_query, query_cache)
      end

      if val then
        local value_pos = 1

        while value_pos do
          local p
          p, value_pos = next_value(val, value_pos)
          if p ~= "" then
            local item_text, item_preedit = parse_item(p, t.preedit_delim)
            if not seen_texts[item_text] then
              seen_texts[item_text] = true

              local item = {
                text = item_text,
                preedit = item_preedit and item_preedit ~= "" and item_preedit or nil,
                cand_type = t.cand_type or "abbrev",
                quality = 999,
              }

              abbrev_cands[#abbrev_cands + 1] = item
            end
          end
        end
      end
    end
  end

  -- 先输出简码候选，再惰性流式输出主候选：不在首个 yield 前物化整个候选流，
  -- 避免强制计算全部输入候选（大词典下单码可达上千候选）造成数十毫秒尖峰。
  for _, item in ipairs(abbrev_cands) do
    local processed = process_rules(make_abbrev_candidate(item), aux_results)
    for _, pc in ipairs(processed) do
      local dedup_key = trim_space(pc.text)
      if not global_yielded[dedup_key] then
        global_yielded[dedup_key] = true
        yield(pc)
      end
    end
  end

  for cand in input:iter() do
    local processed = process_main(cand)
    for _, pc in ipairs(processed) do
      local dedup_key = trim_space(pc.text)
      if not global_yielded[dedup_key] then
        global_yielded[dedup_key] = true
        yield(pc)
      end
    end
  end
end

return M
