-- amzxyz@https://github.com/amzxyz/rime-wanxiang
-- input_stats.lua
-- Rime 统计增强版 (LevelDB / 滚动时间窗口 / 效率仪表盘 / 汉字提纯)

local wanxiang          = require("wanxiang")

local utf8_codes        = utf8.codes
local utf8_len          = utf8.len

local raw_software_name = rime_api.get_distribution_code_name()
local _db_pool

local function pack_value(val)
  return string.format("c=%d d=0.0 t=%d", val, os.time())
end

local function unpack_value(str)
  if not str then return 0 end
  local c = str:match("c=(%-?%d+)")
  return tonumber(c) or 0
end

local function get_device_id()
  local user_dir = rime_api.get_user_data_dir()
  if not user_dir or user_dir == "" then return "unknown" end
  local f = io.open(user_dir .. "/installation.yaml", "r")
  if not f then return "unknown" end
  for line in f:lines() do
    local key, val = line:match("^%s*([%w_]+)%s*:%s*(.+)$")
    if key and val then
      val = val:gsub('^%s*"(.*)"%s*$', "%1"):gsub("^%s*'(.*)'%s*$", "%1"):gsub("^%s+", ""):gsub("%s+$", "")
      if key == "installation_id" then
        f:close()
        return val
      end
    end
  end
  f:close()
  return "unknown"
end

local function get_db(env)
  local db_name = "user_inputstats"
  if not _db_pool then _db_pool = {} end
  if not _db_pool[db_name] then
    _db_pool[db_name] = UserDb(db_name, "userdb")
  end
  local db = _db_pool[db_name]
  if db and not db:loaded() then
    if not db:open() then return nil end
  end
  return db
end

local function process_platform_info(name, ver)
  name = name or ""
  ver = ver or ""
  ver = ver:match("^([vV]?%d+%.%d+%.%d+)") or ver
  if name == "Weasel" then name = "小狼毫" end
  if name == "trime" then name = "同文输入法" end
  if name == "hamster3" then name = "元书输入法" end
  if name == "hamster" then name = "仓输入法" end
  if name == "lyraime" then name = "灵韵输入法" end
  if name == "xime" then name = "曦码输入法" end
  if name == "default" then name = "超越输入法" end
  return name, ver
end

local function is_chinese_code(c)
  return (c >= 0x4E00 and c <= 0x9FFF) or (c >= 0x3400 and c <= 0x4DBF) or
      (c >= 0x20000 and c <= 0x2A6DF) or (c >= 0x2A700 and c <= 0x2B73F) or
      (c >= 0x2B740 and c <= 0x2B81F) or (c >= 0x2B820 and c <= 0x2CEAF) or
      (c >= 0x2CEB0 and c <= 0x2EBEF) or (c >= 0x30000 and c <= 0x3134F) or
      (c >= 0x31350 and c <= 0x323AF) or (c >= 0x2EBF0 and c <= 0x2EE5F) or
      (c >= 0xF900 and c <= 0xFAFF) or (c >= 0x2F800 and c <= 0x2FA1F) or
      (c >= 0x2E80 and c <= 0x2EFF) or (c >= 0x2F00 and c <= 0x2FDF)
end

local function get_pure_chinese_length(text)
  local count = 0
  for _, code in utf8_codes(text) do
    if is_chinese_code(code) then count = count + 1 end
  end
  return count
end

local speed_buffer = {}
local last_cleanup_ts = 0
local pending_stats = {}      -- { [day_key] = { ["_len"]=N, ["_cnt"]=N, ... } }
local pending_max_speeds = {} -- { [day_key] = { ["_spd"]=N } }
local BATCH_INTERVAL = 5      -- 最多每5秒落盘一次
local MAX_PENDING_WORDS = 200 -- 积累超过200字时强制刷盘
local last_flush_ts = 0
local KEY_SEP = " \t"

local function get_current_kpm(now)
  if now - last_cleanup_ts > 5 then
    local new_buf = {}
    local threshold = now - 60
    for _, item in ipairs(speed_buffer) do
      if item.ts > threshold then table.insert(new_buf, item) end
    end
    speed_buffer = new_buf
    last_cleanup_ts = now
  end
  local total = 0
  local threshold = now - 60
  for _, item in ipairs(speed_buffer) do
    if item.ts > threshold then total = total + item.len end
  end
  return total
end

local function pending_accum(day_key, suffix, amount)
  if not pending_stats[day_key] then pending_stats[day_key] = {} end
  pending_stats[day_key][suffix] = (pending_stats[day_key][suffix] or 0) + amount
end

local function pending_max(day_key, suffix, new_val)
  if not pending_max_speeds[day_key] then pending_max_speeds[day_key] = {} end
  local old = pending_max_speeds[day_key][suffix] or 0
  if new_val > old then pending_max_speeds[day_key][suffix] = new_val end
end

local function do_flush(env)
  if not pending_stats or next(pending_stats) == nil then return end
  local db = get_db(env)
  if not db or not db:loaded() then return end
  local dev_id = env.device_id or "unknown"

  for day_key, fields in pairs(pending_stats) do
    for suffix, amount in pairs(fields) do
      local d_key = day_key .. suffix .. KEY_SEP .. dev_id
      local old_val = unpack_value(db:fetch(d_key))
      db:update(d_key, pack_value(old_val + amount))
    end
  end

  for day_key, max_fields in pairs(pending_max_speeds) do
    for suffix, new_val in pairs(max_fields) do
      local d_key = day_key .. suffix .. KEY_SEP .. "_"
      local old_val = unpack_value(db:fetch(d_key))
      if new_val > old_val then db:update(d_key, pack_value(new_val)) end
    end
  end

  pending_stats = {}
  pending_max_speeds = {}
  last_flush_ts = os.time()
end

local function try_flush(env)
  local now = os.time()
  local total_words = 0
  for _, fields in pairs(pending_stats) do
    total_words = total_words + (fields["_len"] or 0)
  end
  if total_words >= MAX_PENDING_WORDS or now - last_flush_ts >= BATCH_INTERVAL then
    do_flush(env)
  end
end

local function record_stats_mem(env, cjk_len, code_len)
  local now = os.time()
  local t = os.date("*t", now)
  local day_key = string.format("d_%04d%02d%02d", t.year, t.month, t.day)

  local current_kpm = 0
  if cjk_len <= 30 then table.insert(speed_buffer, { ts = now, len = cjk_len }) end
  current_kpm = get_current_kpm(now)

  pending_accum(day_key, "_len", cjk_len)
  pending_accum(day_key, "_cnt", 1)
  pending_accum(day_key, "_code", code_len)

  if cjk_len == 1 then
    pending_accum(day_key, "_l1", 1)
  elseif cjk_len == 2 then
    pending_accum(day_key, "_l2", 1)
  elseif cjk_len == 3 then
    pending_accum(day_key, "_l3", 1)
  elseif cjk_len == 4 then
    pending_accum(day_key, "_l4", 1)
  elseif cjk_len > 4 then
    pending_accum(day_key, "_l_gt4", 1)
  end

  pending_max(day_key, "_spd", current_kpm)
end

local function db_get(db, key)
  return unpack_value(db:fetch(key))
end

local CUMULATIVE_STEMS = { "_len", "_cnt", "_code", "_l1", "_l2", "_l3", "_l4", "_l_gt4" }

local function aggregate_by_day_keys(env, day_keys)
  local db = get_db(env)
  if not db or not db:loaded() then return nil end
  local res = { len = 0, cnt = 0, code = 0, spd = 0, l1 = 0, l2 = 0, l3 = 0, l4 = 0, l_gt4 = 0 }
  local has_data = false

  for _, day_key in ipairs(day_keys) do
    for _, stem in ipairs(CUMULATIVE_STEMS) do
      local prefix = day_key .. stem .. KEY_SEP
      for key, value in db:query(prefix):iter() do
        if not key:match("^" .. prefix) then break end
        local v = unpack_value(value)
        if stem == "_len" then
          res.len = res.len + v; has_data = true
        elseif stem == "_cnt" then
          res.cnt = res.cnt + v
        elseif stem == "_code" then
          res.code = res.code + v
        elseif stem == "_l1" then
          res.l1 = res.l1 + v
        elseif stem == "_l2" then
          res.l2 = res.l2 + v
        elseif stem == "_l3" then
          res.l3 = res.l3 + v
        elseif stem == "_l4" then
          res.l4 = res.l4 + v
        elseif stem == "_l_gt4" then
          res.l_gt4 = res.l_gt4 + v
        end
      end
    end
    local daily_spd = unpack_value(db:fetch(day_key .. "_spd" .. KEY_SEP .. "_"))
    if daily_spd > res.spd then res.spd = daily_spd end
  end

  if not has_data then return nil end
  return res
end

local function aggregate_stats(env, days_lookback)
  if days_lookback == 0 then
    local db = get_db(env)
    if not db or not db:loaded() then return nil end
    local day_set = {}
    for key, _ in db:query("d_"):iter() do
      local day_match = key:match("^(d_%d%d%d%d%d%d%d%d)")
      if day_match then day_set[day_match] = true end
    end
    local day_keys = {}
    for dk, _ in pairs(day_set) do table.insert(day_keys, dk) end
    if #day_keys == 0 then return nil end
    return aggregate_by_day_keys(env, day_keys)
  end

  local day_keys = {}
  local now_ts = os.time()
  for i = 0, days_lookback - 1 do
    local target_ts = now_ts - (i * 86400)
    local t = os.date("*t", target_ts)
    table.insert(day_keys, string.format("d_%04d%02d%02d", t.year, t.month, t.day))
  end
  return aggregate_by_day_keys(env, day_keys)
end

local function get_user_title(env)
  local db = get_db(env)
  if not db or not db:loaded() then return "初学乍练" end

  local current_len = 0
  for key, value in db:query("d_"):iter() do
    if key:match("_len" .. KEY_SEP) then
      current_len = current_len + unpack_value(value)
    end
  end

  for _, item in ipairs(env.titles) do
    if current_len >= item.threshold then return item.name end
  end
  return "初学乍练"
end

local function draw_bar(percent)
  local length = 10
  local filled_len = math.floor((percent / 100) * length)
  local empty_len = length - filled_len
  return string.rep("▓", filled_len) .. string.rep("░", empty_len)
end

local function format_summary(title, subtitle, data, env)
  if not data or data.cnt == 0 then return "※ " .. title .. "暂无数据" end

  local avg_code = 0
  if data.len > 0 then avg_code = data.code / data.len end

  local phrase_rate = 0
  if data.len > 0 then phrase_rate = (data.len - data.l1) / data.len * 100 end

  local estimated_avg_spd = 0
  if data.cnt > 0 then
    estimated_avg_spd = math.floor(data.len / ((data.cnt * 2) / 60))
    if estimated_avg_spd > data.spd then estimated_avg_spd = math.floor(data.spd * 0.8) end
    if estimated_avg_spd == 0 and data.len > 0 then estimated_avg_spd = data.len end
  end

  local p1 = (data.l1 / data.cnt) * 100
  local p2 = (data.l2 / data.cnt) * 100
  local p3 = (data.l3 / data.cnt) * 100
  local p4 = (data.l4 / data.cnt) * 100
  local p_gt4 = (data.l_gt4 / data.cnt) * 100

  local raw_ver = rime_api.get_distribution_version() or ""
  local clean_name, clean_ver = process_platform_info(raw_software_name, raw_ver)
  local user_achievement = get_user_title(env)
  local finger_style = wanxiang.get_input_method_type(env)
  local finger_style_map = {
    ["pinyin"] = "全拼",
    ["zrm"] = "自然码",
    ["flypy"] = "小鹤双拼",
    ["mspy"] = "微软双拼",
    ["sogou"] = "搜狗双拼",
    ["abc"] = "智能ABC",
    ["ziguang"] = "紫光双拼",
    ["pyjj"] = "拼音加加",
    ["gbpy"] = "国标双拼",
    ["zrlong"] = "自然龙",
    ["hxlong"] = "汉心龙",
    ["ltsp"] = "蓝天双拼",
    ["lxsq"] = "乱序17",
    ["sdpy"] = "首道双拼",
    ["t9"] = "九键"
  }
  local finger_label = finger_style_map[finger_style] or finger_style
  local header = string.format("※ %s统计 · 效率仪表盘\n", title)
  if subtitle and subtitle ~= "" then
    header = header .. string.format("📅 %s\n", subtitle)
  end
  local zwsp = "\226\128\139"
  return header .. string.format(
    "───────────────" .. zwsp .. "\n" ..
    "📊 综合数据" .. zwsp .. "\n" ..
    "  均速:%-5d 上屏:%d" .. zwsp .. "\n" ..
    "  峰速:%-5d 字数:%d" .. zwsp .. "\n" ..
    "🏆 段位：%s" .. zwsp .. "\n" ..
    "───────────────" .. zwsp .. "\n" ..
    "⚡ 核心效率" .. zwsp .. "\n" ..
    "  平均编码：%.2f 键/字" .. zwsp .. "\n" ..
    "  词组连打：%.1f %%" .. zwsp .. "\n" ..
    "───────────────" .. zwsp .. "\n" ..
    "📈 字词分布" .. zwsp .. "\n" ..
    "  [1] %3d%% %s" .. zwsp .. "\n" ..
    "  [2] %3d%% %s" .. zwsp .. "\n" ..
    "  [3] %3d%% %s" .. zwsp .. "\n" ..
    "  [4] %3d%% %s" .. zwsp .. "\n" ..
    "  [+] %2d%% %s" .. zwsp .. "\n" ..
    "───────────────" .. zwsp .. "\n" ..
    "◉ 方案：%s" .. zwsp .. "\n" ..
    "◉ 编码：%s" .. zwsp .. "\n" ..
    "◉ 前端：%s %s" .. zwsp,
    math.floor(estimated_avg_spd), math.floor(data.cnt),
    math.floor(data.spd), math.floor(data.len),
    user_achievement,
    avg_code, phrase_rate,
    math.floor(p1), draw_bar(p1),
    math.floor(p2), draw_bar(p2),
    math.floor(p3), draw_bar(p3),
    math.floor(p4), draw_bar(p4),
    math.floor(p_gt4), draw_bar(p_gt4),
    env.schema_name, finger_label, clean_name, clean_ver
  )
end

local function yield_msg(seg, text, icon)
  yield(Candidate("stat", seg.start, seg._end, text, icon or "🕰️"))
end

local function clear_all_data(env)
  local db = get_db(env)
  if not db or not db:loaded() then return false end

  local keys = {}
  for key, _ in db:query("d_"):iter() do
    table.insert(keys, key)
  end
  for _, key in ipairs(keys) do
    db:erase(key)
  end
  speed_buffer = {}
  pending_stats = {}
  pending_max_speeds = {}
  return true
end

local function init(env)
  local config = env.engine.schema.config
  env.schema_name = env.engine.schema.schema_name or "万象方案"
  env.device_id = get_device_id()

  local db = get_db(env)
  if db and db:loaded() then
    db:update("_stat_init", pack_value(0))
    db:erase("_stat_init")
  end

  env.triggers = {
    clear = "/qctj",
    today = "/rtj",
    week  = "/ztj",
    month = "/ytj",
    year  = "/ntj",
    total = "/tj",
  }

  env.titles = {
    { threshold = 5000000, name = "⌨️·天人合一" },
    { threshold = 1000000, name = "⌨️·登峰造极" },
    { threshold = 500000, name = "✨·出神入化" },
    { threshold = 100000, name = "💨·行云流水" },
    { threshold = 50000, name = "🚀·运指如飞" },
    { threshold = 10000, name = "🌟·渐入佳境" },
    { threshold = 0, name = "🌱·初学乍练" }
  }
  table.sort(env.titles, function(a, b) return a.threshold > b.threshold end)

  if env.stat_notifier then env.stat_notifier:disconnect() end
  local ctx = env.engine.context

  env.stat_notifier = ctx.commit_notifier:connect(function(ctx)
    local commit_text = ctx:get_commit_text()
    if not commit_text or commit_text == "" then return end
    if commit_text:sub(1, 1) == "/" then return end
    if commit_text:find("^[※◉🏆📊⚡📈]") then return end

    local cjk_len = get_pure_chinese_length(commit_text)
    if cjk_len == 0 then return end
    local raw_input = ctx.input or ""
    local code_len = string.len(raw_input)
    if code_len == 0 then code_len = cjk_len * 2 end

    record_stats_mem(env, cjk_len, code_len)
    try_flush(env)
  end)
end

local function fini(env)
  do_flush(env)
  local db = get_db(env)
  if db and db:loaded() then db:close() end
  if env.stat_notifier then
    env.stat_notifier:disconnect()
    env.stat_notifier = nil
  end
end

local function translator(input, seg, env)
  if input:sub(1, 1) ~= "/" then
    return
  end
  try_flush(env)
  local summary = ""
  local data = nil
  local title = ""

  if input == env.triggers.clear then
    if clear_all_data(env) then
      yield_msg(seg, "※ 统计数据已全部清空。", "🗑️")
    else
      yield_msg(seg, "※ 数据清空失败，请检查权限。", "❌")
    end
    return
  end

  if input == env.triggers.today then
    title = "今日"; data = aggregate_stats(env, 1)
  elseif input == env.triggers.week then
    title = "七日"; data = aggregate_stats(env, 7)
  elseif input == env.triggers.month then
    title = "卅日"; data = aggregate_stats(env, 30)
  elseif input == env.triggers.year then
    title = "本年"; data = aggregate_stats(env, 365)
  elseif input == env.triggers.total then
    title = "生涯"; data = aggregate_stats(env, 0)
  end

  if data then
    summary = format_summary(title, nil, data, env)
    yield(Candidate("stat", seg.start, seg._end, summary, "📊"))
  end
end

return { init = init, func = translator, fini = fini }
