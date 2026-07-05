-- 万象时间 · lua_translator
-- 提供日期/时间/农历/节气/节日等候选
-- 用法: schema.yaml 中 engine/translators 列表添加 - lua_translator@*shijian

local L = require("wanxiang/lunar_calendar")
local A = require("wanxiang/astronomy")
local G = require("wanxiang/ganzhi")
local D = require("wanxiang/shijian_data")

-- ====== 候选生成辅助 ======
local function generate_candidates(input, alias, seg, candidates)
  local prefix = ""
  if input:match("^%d") then
    prefix = "o"
  elseif input:match("^/%d") then
    prefix = "/"
  end
  for _, item in ipairs(candidates) do
    local candidate = Candidate("shijian", seg.start, seg._end, item[1], item[2])
    candidate.quality = 1000000
    if prefix ~= "" then
      candidate.preedit = prefix .. alias
    end
    yield(candidate)
  end
end

local function set_prompt_if_invalid(context, msg)
  local segment = context.composition:back()
  if segment then
    segment.prompt = msg
  end
end

-- ====== Translator ======
---@param input string
---@param seg Segment
---@param env Env
local function translator(input, seg, env)
  local engine  = env.engine
  local context = engine.context
  local config  = engine.schema.config
  local segment = context.composition:back()

  local function set_ndate_tag(context, on)
    local comp = context and context.composition
    if not comp or comp:empty() then return end
    local s = comp:back()
    if not s then return end
    if on then
      s.tags = s.tags + Set({ "Ndate" })
    else
      s.tags = s.tags - Set({ "Ndate" })
    end
  end

  -- ===== N日期功能 =====
  if input:sub(1, 1) == "N" then
    local n           = input:sub(2)
    local len         = #n
    local only_digits = (n:match("^%d*$") ~= nil)
    local ndate_mode  = (only_digits and len >= 1 and len <= 8)
    local handled     = false

    set_ndate_tag(context, ndate_mode)

    if ndate_mode then
      local yr = os.date("%Y")

      -- NMMDD
      if (len == 4) and not (n:match("^19%d%d$") or n:match("^20%d%d$")) then
        context:set_property("sequence_adjustment_code", "Nmmdd")
        local mm = tonumber(n:sub(1, 2))
        local dd = tonumber(n:sub(3, 4))
        local ok = (mm and dd and mm >= 1 and mm <= 12 and dd >= 1 and dd <= 31)
        if ok then
          ok = L.DateExists(tonumber(yr), mm, dd)
        end
        if not ok then
          set_prompt_if_invalid(context, " 〔日期不存在〕")
        else
          set_prompt_if_invalid(context, " 〔" .. yr .. "年" .. "〕")
          local mm_str = string.format("%02d", mm)
          local dd_str = string.format("%02d", dd)
          local date_str = yr .. mm_str .. dd_str .. "01"
          local lunar = L.QueryLunarInfo(env, date_str)
          if #lunar > 0 then
            local candidates = {
              { string.format("%d月%d日", mm, dd), "" },
              { string.format("%02d月%02d日", mm, dd), "" }
            }
            for _, cand in ipairs(lunar) do
              local text = cand[1]
              if not text:match("%d") then
                if text:find("%b()") then
                  text = text:gsub("%b()", "")
                end
                local processed = text:match("年(.+)") or text
                table.insert(candidates, { processed, "" })
              end
            end
            generate_candidates(input, "shijian", seg, candidates)
            handled = true
          end
        end
      end

      -- NYYYY...
      if not handled and (n:match("^20%d%d") or n:match("^19%d%d")) then
        context:set_property("sequence_adjustment_code", "N")
        if len >= 8 then
          local yyyy = tonumber(n:sub(1, 4))
          local mm   = tonumber(n:sub(5, 6))
          local dd   = tonumber(n:sub(7, 8))
          if not L.DateExists(yyyy, mm, dd) then
            set_prompt_if_invalid(context, " 〔日期不存在〕")
          end
        end
        local lunar = L.QueryLunarInfo(env, n)
        if #lunar > 0 then
          local candidates = {}
          for i = 1, #lunar do
            candidates[#candidates + 1] = { lunar[i][1], lunar[i][2] }
          end
          generate_candidates(input, "shijian", seg, candidates)
          handled = true
        end
      end
    end

    if handled then return end
  end

  -- ===== shijian_keys 触发功能 =====
  local shijian_keys_config = config:get_list("key_binder/shijian_keys")
  local is_sijian_input = false
  local command = ""

  if not shijian_keys_config then
    return
  end

  for i = 0, shijian_keys_config.size - 1 do
    local key = shijian_keys_config:get_value_at(i).value
    local key_length = string.len(key)
    if string.sub(input, 1, key_length) == key then
      is_sijian_input = true
      command = string.sub(input, key_length + 1)
      break
    end
  end

  if is_sijian_input ~= true or command == "" then
    return
  end

  segment.tags = segment.tags + Set({ "shijian" })

  -- /rq 日期
  if command == "rq" or command == "77" then
    context:set_property("sequence_adjustment_code", "/rq")
    local today = os.date("*t")
    local ymd = os.date("%Y%m%d")
    local ymdh = os.date("%Y%m%d%H")
    local num_year = string.format(" 〔%03d/%d〕", today.yday, L.IsLeap(today.year))
    local candidates = {
      { string.format("%d 年 %d 月 %d 日", today.year, today.month, today.day), "" },
      { string.format("%d 月 %d 日", today.month, today.day), "" },
      { os.date("%Y 年 %m 月 %d 日"), "" },
      { os.date("%m 月 %d 日"), "" },
      { os.date("%Y-%m-%d"), "" },
      { os.date("%m-%d"), "" },
      { os.date("%Y/%m/%d"), "" },
      { os.date("%m/%d"), "" },
      { L.CnDate_translator(ymd), "" },
      { G.lunarJzl(ymdh), "" },
      { L.Date2LunarDate(ymd) .. A.JQtest(ymd), "" },
      { L.Date2LunarDate(ymd) .. G.GetLunarSichen(os.date("%H"), 1), "" }
    }
    generate_candidates(input, "rq", seg, candidates)
    set_prompt_if_invalid(context, num_year)
    return
  end

  -- /rc 日期间隔
  local is_today = (command == "rc")
  local pending_num = string.match(command, "^rc(%d+)$")
  local finished_num, sign = string.match(command, "^rc(%d+)([-+=op])$")

  if is_today or pending_num or finished_num then
    segment.tags = segment.tags + Set({ "shijian" })
    context:set_property("sequence_adjustment_code", "/rc")

    if pending_num then
      local hint = string.format("差值%s天 (从前按 -/o，未来按 +/p/=)", pending_num)
      generate_candidates("shijian", seg, { { hint, "等待输入..." } })
      return
    end

    local offset = 0
    if finished_num then
      local num = tonumber(finished_num)
      if sign == "+" or sign == "=" or sign == "p" then
        offset = num
      else
        offset = -num
      end
    end

    local now_ts = os.time()
    local target_ts = now_ts + (offset * 24 * 3600)
    local today = os.date("*t", target_ts)
    local ymd = os.date("%Y%m%d", target_ts)
    local ymdh = os.date("%Y%m%d%H", target_ts)
    local num_year = string.format(" 〔%03d/%d〕", today.yday, L.IsLeap(today.year))

    local candidates = {}
    local custom_formats = config:get_list("date_formats")

    if custom_formats and custom_formats.size > 0 then
      for i = 1, custom_formats.size do
        local format_str = custom_formats:get_value_at(i - 1):get_string()
        local formatted_date = L.format_dt(today, format_str)
        if formatted_date and formatted_date ~= "" then
          table.insert(candidates, { formatted_date, "" })
        end
      end
    else
      candidates = {
        { os.date("%Y年%m月%d日", target_ts), "" },
        { os.date("%Y.%m.%d", target_ts), "" },
        { os.date("%Y-%m-%d", target_ts), "" },
        { os.date("%Y/%m/%d", target_ts), "" },
        { os.date("%Y%m%d", target_ts), "" },
        { os.date("%y年%m月%d日", target_ts), "" },
        { os.date("%y%m%d", target_ts), "" },
        { string.format("%d年%d月%d日", today.year, today.month, today.day), "" },
        { string.format("%d年%d月%d日", today.year % 100, today.month, today.day), "" },
        { string.format("%d月%d日", today.month, today.day), "" },
      }
    end

    table.insert(candidates, { L.CnDate_translator(ymd), "" })
    table.insert(candidates, { G.lunarJzl(ymdh), "" })
    table.insert(candidates, { L.Date2LunarDate(ymd) .. A.JQtest(ymd), "" })
    table.insert(candidates, { L.Date2LunarDate(ymd) .. G.GetLunarSichen(os.date("%H", target_ts), 1), "" })

    generate_candidates(input, "rc", seg, candidates)
    set_prompt_if_invalid(context, num_year)
    return
  end

  -- /sj 时间
  if command == "sj" or command == "75" then
    context:set_property("sequence_adjustment_code", "/sj")
    local time_discrpt = " 〔" .. G.GetLunarSichen(os.date("%H"), 1) .. "〕"
    local candidates = {
      { os.date("%H 时 %M 分"), "" },
      { os.date("%H:%M"), "" },
      { os.date("%H 时 %M 分 %S 秒"), "" },
      { os.date("%H:%M:%S"), "" },
      { G.GetLunarSichen(os.date("%H"), 1), "" }
    }
    generate_candidates(input, "sj", seg, candidates)
    set_prompt_if_invalid(context, time_discrpt)
    return
  end

  -- /utc 世界时钟
  if command == "utc" then
    segment.tags = segment.tags + Set({ "shijian" })
    context:set_property("sequence_adjustment_code", "/utc")

    local now = os.time()
    local utc_tab = os.date("!*t", now)
    local utc_str = string.format("%02d:%02d", utc_tab.hour, utc_tab.min)

    local local_tab = os.date("*t", now)
    local local_str = string.format("%02d:%02d", local_tab.hour, local_tab.min)

    local local_offset_sec = os.difftime(os.time(local_tab), os.time(utc_tab))
    local local_offset_hr = math.floor((local_offset_sec + 1800) / 3600)
    local local_sign = local_offset_hr >= 0 and "+" or ""

    local candidates = {
      { utc_str, "UTC (世界标准时间)" },
      { local_str, "Local (UTC" .. local_sign .. local_offset_hr .. ") [北京]" }
    }

    local zones_data = D.utc_zones

    local bj_ts = now + (8 * 3600)
    local bj_date = os.date("!*t", bj_ts)

    for _, z in ipairs(zones_data) do
      local target_ts = now + (z.offset * 3600)
      local target_str = os.date("!%H:%M", target_ts)
      local diff = z.offset - 8
      local diff_str = ""
      if diff > 0 then
        diff_str = "北京+" .. diff
      elseif diff == 0 then
        diff_str = "同频"
      else
        diff_str = "北京" .. diff
      end
      local target_date = os.date("!*t", target_ts)
      local day_hint = ""
      if target_date.day ~= bj_date.day then
        if diff < 0 then
          day_hint = " [昨天]"
        elseif diff > 0 then
          day_hint = " [明天]"
        end
      end
      local comment = string.format("%s (%s)%s", z.name, diff_str, day_hint)
      table.insert(candidates, { target_str, comment })
    end

    generate_candidates(input, "utc", seg, candidates)
    return
  end

  -- /dt 日期+时间
  if command == "dt" or command == "38" then
    context:set_property("sequence_adjustment_code", "/dt")
    local candidates = {
      { os.date("%Y 年 %m 月 %d 日 %H 时 %M 分"), "" },
      { os.date("%Y-%m-%d %H:%M:%S"), "" },
    }
    generate_candidates(input, "dt", seg, candidates)
    return
  end

  -- /tt 时间戳
  if command == "tt" or command == "88" then
    context:set_property("sequence_adjustment_code", "/tt")
    local now = os.date("*t")
    local epoch_s = os.time {
      year = now.year, month = now.month, day = now.day,
      hour = now.hour, min = now.min, sec = now.sec, isdst = now.isdst
    }
    local tz_raw = os.date("%z") or "+0000"
    local tz_colon = tz_raw:sub(1, 3) .. ":" .. tz_raw:sub(4, 5)
    local candidates = {
      { tostring(epoch_s), "〔Unix秒〕" },
      { tostring(epoch_s * 1000), "〔Unix毫秒〕" },
      { os.date("%Y-%m-%dT%H:%M:%S") .. tz_colon, "〔RFC3339 本地+偏移〕" },
      { os.date("%Y%m%d%H%M%S"), "〔YYYYMMDDHHMMSS〕" },
    }
    generate_candidates(input, "tt", seg, candidates)
    return
  end

  -- /nl 农历
  if command == "nl" or command == "65" then
    context:set_property("sequence_adjustment_code", "/nl")
    local yr = os.date("%Y")
    local year = "〔" .. yr .. "年" .. "〕"
    local candidates = {
      { L.Date2LunarDate(os.date("%Y%m%d")) .. A.JQtest(os.date("%Y%m%d")), "" },
      { G.lunarJzl(os.date("%Y%m%d%H")), "" },
      { L.Date2LunarDate(os.date("%Y%m%d")) .. G.GetLunarSichen(os.date("%H"), 1), "" }
    }
    generate_candidates(input, "nl", seg, candidates)
    set_prompt_if_invalid(context, year)
    return
  end

  -- /xq 星期
  if command == "xq" or command == "97" then
    context:set_property("sequence_adjustment_code", "/xq")
    local now = os.date("*t")
    local _, weekno = L.iso_week_number(now.year, now.month, now.day)
    local num_weekday = "〔第 " .. weekno .. " 周〕"
    local candidates = {
      { L.chinese_weekday2(os.date("%w")), num_weekday },
      { L.chinese_weekday(os.date("%w")), num_weekday }
    }
    generate_candidates(input, "xq", seg, candidates)
    return
  end

  -- /ww 第几周
  if command == "ww" or command == "99" then
    context:set_property("sequence_adjustment_code", "/ww")
    local now = os.date("*t")
    local _, weekno = L.iso_week_number(now.year, now.month, now.day)
    local weekno_str = tostring(weekno)
    local candidates = {
      { "W" .. weekno_str, "" },
      { "第" .. weekno_str .. "周", "" }
    }
    generate_candidates(input, "ww", seg, candidates)
    return
  end

  -- /jq 节气
  if command == "jq" or command == "55" then
    context:set_property("sequence_adjustment_code", "/jq")
    local jqs = A.GetNowTimeJq(os.date("%Y%m%d", os.time()))
    local candidates = {}
    for _, jq in ipairs(jqs) do
      local jieqi_name, date_str = jq:match("^(%S+)%s+(%d+-%d+-%d+)$")
      local days_diff = ""
      if date_str then
        local target_date = date_str:gsub("-", "")
        local diff = L.days_until(target_date)
        local _, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
        local month_day = month .. "月" .. day .. "日"
        local formatted_jq = jieqi_name .. " (" .. month_day .. ")"
        if diff >= 0 then
          if diff == 0 then
            days_diff = "〔今天〕"
          else
            days_diff = string.format("〔< %d 天〕", diff)
          end
          table.insert(candidates, { formatted_jq, days_diff })
        end
      else
        table.insert(candidates, { jq, "" })
      end
    end
    generate_candidates(input, "jq", seg, candidates)
    return
  end

  -- /jr 节日
  if command == "jr" or command == "57" then
    context:set_property("sequence_adjustment_code", "/jr")
    local upcoming_holidays = L.get_upcoming_holidays()
    local candidates = {}
    for _, holiday in ipairs(upcoming_holidays) do
      local year, month, day = holiday[2]:match("^(%d+)年(%d+)月(%d+)")
      if month and day then
        local formatted_date = string.format("%02d月%02d日", tonumber(month), tonumber(day))
        local holiday_summary = string.format("%s (%s)", holiday[1], formatted_date, holiday[3])
        local holiday_diff = string.format("〔< %d 天〕", holiday[3])
        table.insert(candidates, { holiday_summary, holiday_diff })
      end
    end
    generate_candidates(input, "jr", seg, candidates)
    return
  end

  -- 取消 tag
  segment.tags = segment.tags - Set({ "shijian" })
end

return translator
