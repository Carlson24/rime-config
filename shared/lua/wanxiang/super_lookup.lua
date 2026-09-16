--@amzxyz https://github.com/amzxyz/rime-wanxiang
--wanxiang_lookup: #设置归属于super_lookup.lua
--tags: [ abc ]  # 检索当前tag的候选
--key: "`"       # 输入中反查引导符
--aux_file: "flypy_aux.csv" # 唯一数据源：字 -> 辅码表

local wanxiang = require("wanxiang")

-- 1. 基础工具函数 (UTF8处理 / 字符串)
local function alt_lua_punc(s)
  return wanxiang.escape_pattern(s)
end

local get_utf8_len = utf8.len

local function get_utf8_char_at(text, idx)
  return utf8.sub(text, idx, idx) or ""
end

-- 提取一段 UTF8 字符片段
local function get_utf8_string_range(text, start_idx, end_idx)
  return utf8.sub(text, start_idx, end_idx) or ""
end

-- 将 UTF8 字符串转为字符数组
local function text_to_chars(text)
  if not text or text == "" then
    return {}
  end
  local chars = {}
  for from, to in utf8.grapheme_indices(text) do
    table.insert(chars, text:sub(from, to))
  end
  return chars
end

-- 将字符数组拼回字符串
local function chars_to_text(chars)
  return table.concat(chars)
end

-- 替换一段 UTF8 字符片段
local function replace_text_range(text, start_idx, end_idx, new_str)
  return utf8.insert(utf8.remove(text, start_idx, end_idx), start_idx, new_str)
end

-- 2. 核心解析逻辑 (输入拆分 / 辅码提取 / 音节切分)
local function split_lookup_input(input, key)
  if not input or input == "" or not key or key == "" then
    return nil
  end

  if input:sub(1, #key) == key and not key:match("^%w+$") then
    return nil
  end

  local s_start = nil
  local s_end = nil
  local from = 1

  while true do
    local s, e = input:find(key, from, true)
    if not s then
      break
    end
    s_start = s
    s_end = e
    from = s + 1
  end

  if not s_start then
    return nil
  end

  return input:sub(1, s_start - 1), input:sub(s_end + 1), s_start, s_end
end

-- 解析输入的辅码分块
local function parse_aux_rules(aux)
  local aux_chunks = {}
  for code, digit in aux:gmatch("(%a%a?)(%d*)") do
    table.insert(aux_chunks, string.upper(code) .. digit)
  end

  return aux, aux_chunks
end

-- 3. 辅码数据表 (flypy_aux.csv 唯一数据源，lub 缓存)
-- 采用内存 blob store + 运行时字节码缓存，与 chaifen_tips 同款机制：
-- 数据编码为 "char\tcode1,code2\n" 单串 blob + 偏移索引，首次解析后写入 build/*.lub。
local DB_FORMAT_VERSION = "1"

-- 模块私有 store 池：相同签名的数据共享同一份 blob store，引用计数管理生命周期。
local STORE_CACHE = {}

-- 解析 CSV，构建 char -> 辅码串("code1,code2")，编码为 blob + 偏移索引。
local function build_aux_store(path)
  local map = {}

  local file, close = wanxiang.load_file_with_fallback(path, "r")
  if file then
    for raw_line in file:lines() do
      local line = raw_line:gsub("\r$", ""):gsub("^\239\187\191", "") -- 去 BOM
      local char, codes = line:match("^([^\t]+)\t(.+)$")
      if char and codes then
        local trimmed = codes:gsub("^%s+", ""):gsub("%s+$", "")
        if #trimmed > 0 then
          map[char] = trimmed
        end
      end
    end
    close()
  end

  local keys = {}
  for k in pairs(map) do
    keys[#keys + 1] = k
  end
  table.sort(keys)

  local data = wanxiang.blob_encode(keys, map)
  local pos = wanxiang.blob_index(data)

  return { data = data, pos = pos }
end

-- 文件内容签名（含缺失文件），保证内容变化时缓存失效重建。
local function aux_signature(path)
  return wanxiang.digest_parts({
    "wanxiang_lookup",
    DB_FORMAT_VERSION,
    path .. "|" .. wanxiang.get_file_signature(path)
  })
end

local function connect_aux_store(schema_id, path)
  local signature = aux_signature(path)

  local state = STORE_CACHE[signature]
  if state then
    state.refs = state.refs + 1
    return state.store, signature, false
  end

  local cache_path = wanxiang.store_cache_path("lookup", schema_id)
  local store
  local built = false

  local blob = wanxiang.read_store_cache(cache_path, signature)
  if blob then
    store = { data = blob, pos = wanxiang.blob_index(blob) }
  else
    store = build_aux_store(path)
    built = true
    wanxiang.write_store_cache(cache_path, signature, store.data)
  end

  STORE_CACHE[signature] = { store = store, refs = 1 }
  return store, signature, built
end

local function release_aux_store(env)
  local store = env.aux_store
  local signature = env.aux_store_sig

  env.aux_store = nil
  env.aux_store_sig = nil

  if not store or not signature then return end

  local state = STORE_CACHE[signature]
  if not state or state.store ~= store then return end

  state.refs = state.refs - 1
  if state.refs > 0 then return end

  STORE_CACHE[signature] = nil
end

-- 按 char 从 store 取辅码串并拆分为列表（按串记忆化，避免逐候选重复拆分）。
local split_memo = {}

local function fetch_aux_codes(store, char)
  local codes_str = wanxiang.blob_fetch(store.data, store.pos, char)
  if not codes_str then
    return nil
  end

  local cached = split_memo[codes_str]
  if cached then
    return cached
  end

  local list = {}
  for c in codes_str:gmatch("[^,]+") do
    local t = c:gsub("^%s+", ""):gsub("%s+$", "")
    if #t > 0 then
      list[#list + 1] = t
    end
  end
  split_memo[codes_str] = list
  return list
end

local function get_script_text_parts(ctx, search_key)
  local parts = {}
  if not ctx or not ctx.composition or ctx.composition:empty() then
    return parts
  end

  local spans = ctx.composition:spans()
  if not spans then
    return parts
  end

  local count = type(spans.count) == "function" and spans:count() or spans.count
  if count == 0 then
    return parts
  end

  local vertices = type(spans.vertices) == "function" and spans:vertices() or spans.vertices
  if not vertices or #vertices < 2 then
    return parts
  end

  local raw_in = ctx.input or ""
  for i = 1, #vertices - 1 do
    local start_byte = vertices[i] + 1
    local end_byte = vertices[i + 1]
    local raw_syl = raw_in:sub(start_byte, end_byte)

    if raw_syl and raw_syl ~= "" then
      if search_key and search_key ~= "" then
        local split_pos = raw_syl:find(search_key, 1, true)
        if split_pos then
          raw_syl = raw_syl:sub(1, split_pos - 1)
        end
      end
      raw_syl = raw_syl:gsub("['%s]", "")
      if raw_syl ~= "" then
        table.insert(parts, raw_syl)
      end
    end
  end

  return parts
end

-- 4. 匹配判定引擎 (精准 / 模糊递归)
local function check_char_aux_match(env, pinyin, aux, target_char)
  local probe = pinyin .. aux
  if env.mem:dict_lookup(probe, true, 200) then
    for e in env.mem:iter_dict() do
      if e.text == target_char then
        return true
      end
    end
  end
  if env.mem:user_lookup(probe, true) then
    for e in env.mem:iter_user() do
      if e.text == target_char then
        return true
      end
    end
  end
  return false
end

local function group_match(group, aux)
  if not group then
    return false
  end
  for i = 1, #group do
    if string.sub(group[i], 1, #aux) == aux then
      return true
    end
  end
  return false
end

local function match_fuzzy_recursive(codes_sequence, idx, input_str, input_idx, memo, is_phrase_mode)
  if input_idx > #input_str then
    return true
  end
  if idx > #codes_sequence then
    return false
  end

  local state_key = idx * 1000 + input_idx
  if memo[state_key] ~= nil then
    return memo[state_key]
  end

  local codes = codes_sequence[idx]
  local result = false

  if codes then
    for _, code in ipairs(codes) do
      local skip = false
      if is_phrase_mode and #code > 3 then
        skip = true
      end
      if code:match("^%d+$") then
        skip = true
      end

      if not skip then
        local i_curr = input_idx
        local c_curr = 1
        while i_curr <= #input_str and c_curr <= #code do
          if input_str:byte(i_curr) == code:byte(c_curr) then
            i_curr = i_curr + 1
          end
          c_curr = c_curr + 1
        end
        if match_fuzzy_recursive(codes_sequence, idx + 1, input_str, i_curr, memo, is_phrase_mode) then
          result = true
          break
        end
      end
    end
  else
    if match_fuzzy_recursive(codes_sequence, idx + 1, input_str, input_idx, memo, is_phrase_mode) then
      result = true
    end
  end

  memo[state_key] = result
  return result
end

-- 5. 候选项数据构建核心
local function build_candidate_raw_data(cand, env)
  local raw_data = { csv = {} }
  local store = env.aux_store

  local i = 0
  for _, code_point in utf8.codes(cand.text) do
    i = i + 1
    raw_data.csv[i] = fetch_aux_codes(store, utf8.char(code_point))
  end

  return raw_data
end

-- 6. 引导模式核心逻辑 (词组及单字纠错回溯)
local function get_syl_offset(cand, ctx)
  local syl_offset = 0
  local spans = ctx.composition:spans()
  if not spans then
    return 0
  end

  local vertices = type(spans.vertices) == "function" and spans:vertices() or spans.vertices
  if vertices then
    for i = 1, #vertices - 1 do
      if vertices[i] < cand.start then
        syl_offset = syl_offset + 1
      else
        break
      end
    end
  end

  return syl_offset
end

-- [词组纠错] 1. 尝试长词组整体匹配
local function try_match_long_phrase(current_text, cand_len, env, syllables, aux_chunks, syl_offset)
  local aux_len = #aux_chunks
  if aux_len <= 1 or aux_len > cand_len or not env.main_translator then
    return nil
  end

  for w_start = cand_len - aux_len + 1, 1, -1 do
    local w_end = w_start + aux_len - 1
    local pure_pinyin_parts = {}
    local valid_window = true

    for k = 1, aux_len do
      local syl = syllables[w_start + k - 1 + syl_offset]
      if not syl then
        valid_window = false
        break
      end
      if #syl > 2 then
        syl = string.sub(syl, 1, 2)
      end
      table.insert(pure_pinyin_parts, syl)
    end

    if valid_window then
      local query_str = table.concat(pure_pinyin_parts, "")
      local seg_trans = Segment(0, #query_str)
      seg_trans.tags = Set({ "abc" })

      local translation = env.main_translator:query(query_str, seg_trans)
      local orig_phrase_text = get_utf8_string_range(current_text, w_start, w_end)

      if translation then
        for c in translation:iter() do
          local phrase_text = c.text
          if get_utf8_len(phrase_text) == aux_len and phrase_text ~= orig_phrase_text then
            local match_all = true
            local char_idx = 1

            for _, code_pt in utf8.codes(phrase_text) do
              local char = utf8.char(code_pt)
              if
                  not check_char_aux_match(env, pure_pinyin_parts[char_idx], aux_chunks[char_idx], char)
              then
                match_all = false
                break
              end
              char_idx = char_idx + 1
            end

            if match_all then
              local new_text = replace_text_range(current_text, w_start, w_end, phrase_text)
              return new_text, aux_len, w_start - 1
            end
          end
        end
      end
    end
  end

  return nil
end

-- [词组纠错] 2. 尝试2字词双向辅助匹配
local function try_match_two_char_phrase(current_text, search_end_idx, env, syllables, aux_chunk, syl_offset)
  if search_end_idx < 2 or not env.main_translator then
    return nil
  end

  for w_start = search_end_idx - 1, 1, -1 do
    local w_end = w_start + 1
    local pure_pinyin_parts = {}
    local valid_window = true

    for k = 0, 1 do
      local syl = syllables[w_start + k + syl_offset]
      if not syl then
        valid_window = false
        break
      end
      if #syl > 2 then
        syl = string.sub(syl, 1, 2)
      end
      table.insert(pure_pinyin_parts, syl)
    end

    if valid_window then
      local query_str = pure_pinyin_parts[1] .. pure_pinyin_parts[2]
      local seg_trans = Segment(0, #query_str)
      seg_trans.tags = Set({ "abc" })

      local ok, translation = pcall(function()
        return env.main_translator:query(query_str, seg_trans)
      end)

      if ok and translation then
        local orig_phrase_text = get_utf8_string_range(current_text, w_start, w_end)
        for c in translation:iter() do
          if get_utf8_len(c.text) == 2 and c.text ~= orig_phrase_text then
            local char1 = get_utf8_char_at(c.text, 1)
            local char2 = get_utf8_char_at(c.text, 2)
            local orig_char1 = get_utf8_char_at(orig_phrase_text, 1)
            local orig_char2 = get_utf8_char_at(orig_phrase_text, 2)

            local case_a = false
            if char2 == orig_char2 then
              case_a = check_char_aux_match(env, pure_pinyin_parts[1], aux_chunk, char1)
            end

            local case_b = false
            if char1 == orig_char1 then
              case_b = check_char_aux_match(env, pure_pinyin_parts[2], aux_chunk, char2)
            end

            if case_a or case_b then
              local new_text = replace_text_range(current_text, w_start, w_end, c.text)
              return new_text, 1, w_start - 1
            end
          end
        end
      end
    end
  end

  return nil
end

-- [词组纠错] 3. 尝试单字逐个回溯替换
local function try_match_single_chars(
    current_text,
    search_end_idx,
    env,
    syllables,
    aux_chunks,
    syl_offset,
    match_count
)
  local chars = text_to_chars(current_text)
  local current_end = search_end_idx
  local m_count = match_count
  local changed = false

  for c_idx = #aux_chunks, 1, -1 do
    local chunk_aux = aux_chunks[c_idx]
    local best_pos = nil
    local best_char = nil
    local perfect_match_idx = nil
    local max_weight = -10000

    for i = current_end, 1, -1 do
      local orig_char = chars[i]
      local pinyin_code = syllables[i + syl_offset]

      if not pinyin_code or not orig_char then
        goto next_i
      end

      if #pinyin_code > 2 then
        pinyin_code = string.sub(pinyin_code, 1, 2)
      end

      local probe_code = pinyin_code .. chunk_aux
      local is_orig_valid = false
      local local_best_cand = nil
      local local_max_weight = -10000

      if env.mem:dict_lookup(probe_code, true, 200) then
        for entry in env.mem:iter_dict() do
          if get_utf8_len(entry.text) == 1 then
            if entry.text == orig_char then
              is_orig_valid = true
              break
            end
            if (entry.weight or 0) > local_max_weight then
              local_max_weight = entry.weight or 0
              local_best_cand = entry.text
            end
          end
        end
      end

      if not is_orig_valid and env.mem:user_lookup(probe_code, true) then
        for entry in env.mem:iter_user() do
          if get_utf8_len(entry.text) == 1 then
            if entry.text == orig_char then
              is_orig_valid = true
              break
            end
            if ((entry.weight or 0) + 500) > local_max_weight then
              local_max_weight = (entry.weight or 0) + 500
              local_best_cand = entry.text
            end
          end
        end
      end

      if is_orig_valid then
        if not perfect_match_idx then
          perfect_match_idx = i
        end
        goto next_i
      elseif local_best_cand then
        if local_max_weight > max_weight then
          max_weight = local_max_weight
          best_pos = i
          best_char = local_best_cand
        end
      end
      ::next_i::
    end

    if best_pos then
      m_count = m_count + 1
      if best_char ~= chars[best_pos] then
        chars[best_pos] = best_char
        changed = true
      end
      current_end = best_pos - 1
    elseif perfect_match_idx then
      m_count = m_count + 1
      current_end = perfect_match_idx - 1
    end
  end

  if changed then
    return chars_to_text(chars), m_count
  end
  return current_text, m_count
end

-- 组装引导模式的主词组/单字纠错逻辑
local function attempt_phrase_correction(cand, cand_len, env, syllables, aux_chunks, syl_offset)
  if #aux_chunks == 0 then
    return nil
  end

  local current_text = cand.text
  local match_count = 0
  local search_end_idx = cand_len

  local new_text, count, next_end =
      try_match_long_phrase(current_text, cand_len, env, syllables, aux_chunks, syl_offset)

  if new_text then
    current_text = new_text
    match_count = count
    search_end_idx = next_end
  elseif #aux_chunks == 1 then
    new_text, count, next_end =
        try_match_two_char_phrase(current_text, search_end_idx, env, syllables, aux_chunks[1], syl_offset)
    if new_text then
      current_text = new_text
      match_count = count
      search_end_idx = next_end
    end
  end

  if match_count == 0 then
    current_text, match_count =
        try_match_single_chars(current_text, search_end_idx, env, syllables, aux_chunks, syl_offset, match_count)
  end

  if match_count == #aux_chunks then
    if current_text ~= cand.text then
      local fixed_cand = Candidate(cand.type, cand.start, cand._end, current_text, cand.comment or "")
      fixed_cand.quality = cand.quality
      fixed_cand.preedit = cand.preedit
      return fixed_cand
    else
      return cand
    end
  end

  return nil
end

-- 综合匹配判断引擎 (引导模式使用)
local function check_explicit_match(raw_data, cand_len, clean_aux)
  local codes_seq = raw_data.csv
  if not codes_seq then
    return false
  end

  if cand_len == 1 then
    return group_match(codes_seq[1], clean_aux)
  else
    local memo = {}
    return match_fuzzy_recursive(codes_seq, 1, clean_aux, 1, memo, false)
  end
end

-- 8. 模式分发调度控制器 (主干函数)

-- A. 引导模式 (Explicit Mode) 控制器
local function handle_explicit_mode(input, env, pure_code, explicitly_aux)
  if not env.mem then
    env.mem = Memory(env.engine, env.engine.schema)
  end

  if not env.main_translator and Component and Component.Translator then
    pcall(function()
      env.main_translator = Component.Translator(env.engine, "translator", "script_translator")
    end)
  end

  local ctx = env.engine.context
  local clean_aux, aux_chunks = parse_aux_rules(explicitly_aux)

  local if_single_char_first = ctx:get_option("char_priority")
  local buckets = {}
  local long_word_cands = {}
  local max_len = 0
  local is_first_cand = true

  -- 获取输入音节片段；历史切分只读不改，直接复用原表。
  local syllables
  if pure_code == env.history_input and env.history_parts and #env.history_parts > 0 then
    syllables = env.history_parts
  else
    syllables = get_script_text_parts(ctx, env.search_key_str)
  end

  for cand in input:iter() do
    local cand_len = get_utf8_len(cand.text)

    -- 首个候选修正：多字纠错
    if is_first_cand then
      is_first_cand = false
      local syl_offset = get_syl_offset(cand, ctx)

      if
          ((cand.type == "sentence" and cand_len > 1) or (cand.type == "phrase" and cand_len > 3))
          and #syllables >= (cand_len + syl_offset)
      then
        local corr_cand = attempt_phrase_correction(cand, cand_len, env, syllables, aux_chunks, syl_offset)
        if corr_cand then
          yield(corr_cand)
          goto skip
        end
      end
    end

    -- 数据校验与匹配判定
    if cand.type == "sentence" or not cand_len or cand_len == 0 then
      goto skip
    end
    if string.byte(cand.text, 1) and string.byte(cand.text, 1) < 128 then
      goto skip
    end

    local raw_data = build_candidate_raw_data(cand, env)

    if
        raw_data and check_explicit_match(raw_data, cand_len, clean_aux)
    then
      if if_single_char_first and cand_len > 1 then
        table.insert(long_word_cands, cand)
      else
        if not buckets[cand_len] then
          buckets[cand_len] = {}
        end
        table.insert(buckets[cand_len], cand)
        if cand_len > max_len then
          max_len = cand_len
        end
      end
    end

    ::skip::
  end

  -- 输出匹配结果 (依单字优先策略不同排序输出)
  if if_single_char_first then
    if buckets[1] then
      for _, c in ipairs(buckets[1]) do
        yield(c)
      end
    end
    for l = max_len, 2, -1 do
      if buckets[l] then
        for _, c in ipairs(buckets[l]) do
          yield(c)
        end
      end
    end
  else
    for l = max_len, 1, -1 do
      if buckets[l] then
        for _, c in ipairs(buckets[l]) do
          yield(c)
        end
      end
    end
  end

  for _, c in ipairs(long_word_cands) do
    yield(c)
  end
end

-- 9. Rime 暴露接口 (Init / Func / Fini)
local f = {}

function f.init(env)
  local config = env.engine.schema.config

  env.aux_file_path = config:get_string("wanxiang_lookup/aux_file") or "flypy_aux.csv"
  local aux_store, aux_store_sig, aux_built = connect_aux_store(env.engine.schema.schema_id or "", env.aux_file_path)
  env.aux_store = aux_store
  env.aux_store_sig = aux_store_sig
  if aux_built then collectgarbage("collect") end

  env.search_key_str = config:get_string("wanxiang_lookup/key") or "`"
  env.search_key_alt = alt_lua_punc(env.search_key_str)

  local tag = config:get_list("wanxiang_lookup/tags")
  if tag and tag.size > 0 then
    env.tag = {}
    for i = 0, tag.size - 1 do
      table.insert(env.tag, tag:get_value_at(i).value)
    end
  else
    env.tag = { "abc" }
  end

  env.notifier = env.engine.context.select_notifier:connect(function(ctx)
    local input = ctx.input
    local code = split_lookup_input(input, env.search_key_str)
    if not code or #code == 0 then
      return
    end

    local preedit = ctx:get_preedit()
    local no_search_string = code

    local preedit_text = ""
    if preedit and preedit.text then
      preedit_text = preedit.text
    end

    local edit = select(1, split_lookup_input(preedit_text, env.search_key_str))
    if edit and edit:match("[%w/]") then
      ctx.input = no_search_string .. env.search_key_str
    else
      ctx.input = no_search_string
      ctx:commit()
    end
  end)

  env.history_parts = {}
  env.history_input = ""
  -- 专为引导模式(Explicit)的监听器，用于在敲击反查引导符前，保留完美的拼音切分案底
  env.update_conn = env.engine.context.update_notifier:connect(function(ctx)
    if not ctx:is_composing() then
      env.history_parts = {}
      env.history_input = ""
      return
    end
    local raw_in = ctx.input or ""
    if raw_in == "" then
      return
    end

    if env.search_key_str and raw_in:find(env.search_key_str, 1, true) then
      return
    end

    local parts = get_script_text_parts(ctx, env.search_key_str)
    if parts and #parts > 0 then
      env.history_parts = parts
      env.history_input = raw_in
    end
  end)
end

function f.tags_match(seg, env)
  for _, v in ipairs(env.tag) do
    if seg.tags[v] then
      return true
    end
  end
  return false
end

function f.func(input, env)
  local context = env.engine.context
  local seg = context.composition:back()

  if not seg or not f.tags_match(seg, env) or not env.aux_store or #env.aux_store.data == 0 then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  local ctx_input = context.input
  local pure_code, explicitly_aux, s_start = split_lookup_input(ctx_input, env.search_key_str)

  if s_start then
    if not explicitly_aux or #explicitly_aux == 0 then
      -- 只输入反查引导符时原样透传，不创建整候选 raw_data 预热表。
      for cand in input:iter() do
        yield(cand)
      end
      return
    end
    return handle_explicit_mode(input, env, pure_code, explicitly_aux)
  else
    for cand in input:iter() do
      yield(cand)
    end
    return
  end
end

function f.fini(env)
  if env.update_conn then
    env.update_conn:disconnect()
  end
  if env.notifier then
    env.notifier:disconnect()
  end
  if env.mem then
    env.mem:disconnect()
  end

  release_aux_store(env)
  env.history_parts = nil

  collectgarbage("collect")
end

return f
