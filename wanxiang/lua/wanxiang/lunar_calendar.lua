-- 万象时间 · 农历/日期/节日模块
-- 进制转换、农历公历互转、日期格式化、节日/三伏天、QueryLunarInfo

local A  = require("wanxiang/astronomy")
local G  = require("wanxiang/ganzhi")
local D  = require("wanxiang/shijian_data")

local M = {}

-- ====== 进制转换 ======
local function Dec2bin(n)
  local t = {}
  n = tonumber(n)
  while math.floor(n / 2) >= 1 do
    local t1 = math.fmod(n, 2)
    if t1 > 0 then
      table.insert(t, 1, 1)
    else
      table.insert(t, 1, 0)
    end
    n = math.floor(n / 2)
    if n == 1 then
      table.insert(t, 1, 1)
    end
  end
  return string.gsub(table.concat(t), "^[0]+", "")
end

local function system(x, inPuttype, outputtype)
  if tonumber(inPuttype) == 2 then
    if tonumber(outputtype) == 10 then
      return tonumber(tostring(x), 2)
    elseif tonumber(outputtype) == 16 then
      return Dec2bin(tonumber(tostring(x), 2))
    end
  elseif tonumber(inPuttype) == 10 then
    if tonumber(outputtype) == 2 then
      return Dec2bin(tonumber(x))
    elseif tonumber(outputtype) == 16 then
      return string.format("%x", x)
    end
  elseif tonumber(inPuttype) == 16 then
    if tonumber(outputtype) == 2 then
      return Dec2bin(tonumber(tostring(x), 16))
    elseif tonumber(outputtype) == 10 then
      return tonumber(tostring(x), 16)
    end
  end
end

local function Analyze(Data)
  local rtn1 = system(string.sub(Data, 1, 3), 16, 2)
  while string.len(rtn1) < 12 do
    rtn1 = "0" .. rtn1
  end
  local rtn2 = string.sub(Data, 4, 4)
  local rtn3 = system(string.sub(Data, 5, 5), 16, 10)
  local rtn4 = system(string.sub(Data, -2, -1), 16, 10)
  if string.len(rtn4) == 3 then
    rtn4 = "0" .. system(string.sub(Data, -2, -1), 16, 10)
  end
  return { rtn1, rtn2, rtn3, rtn4 }
end

-- ====== 日期计算辅助 ======
function M.IsLeap(y)
  local year = tonumber(y)
  if math.floor(year % 400) ~= 0 and math.floor(year % 4) == 0 or math.floor(year % 400) == 0 then
    return 366
  else
    return 365
  end
end

local function leaveDate(y)
  local total = 0
  local day
  if M.IsLeap(tonumber(string.sub(y, 1, 4))) > 365 then
    day = D.DaysLeap
  else
    day = D.DaysNormal
  end
  if tonumber(string.sub(y, 5, 6)) > 1 then
    for i = 1, tonumber(string.sub(y, 5, 6)) - 1 do
      total = total + day[i]
    end
    total = total + tonumber(string.sub(y, 7, 8))
  else
    return tonumber(string.sub(y, 7, 8))
  end
  return tonumber(total)
end

function M.diffDate(date1, date2)
  date1 = tostring(date1)
  date2 = tostring(date2)
  if tonumber(date2) > tonumber(date1) then
    local n = tonumber(string.sub(date2, 1, 4)) - tonumber(string.sub(date1, 1, 4))
    local total = 0
    if n > 1 then
      for i = 1, n - 1 do
        total = total + M.IsLeap(tonumber(string.sub(date1, 1, 4)) + i)
      end
      total = total + leaveDate(tonumber(string.sub(date2, 1, 8))) + M.IsLeap(tonumber(string.sub(date1, 1, 4))) -
          leaveDate(tonumber(string.sub(date1, 1, 8)))
    elseif n == 1 then
      total = M.IsLeap(tonumber(string.sub(date1, 1, 4))) - leaveDate(tonumber(string.sub(date1, 1, 8))) +
          leaveDate(tonumber(string.sub(date2, 1, 8)))
    else
      total = leaveDate(tonumber(string.sub(date2, 1, 8))) - leaveDate(tonumber(string.sub(date1, 1, 8)))
    end
    return total
  elseif tonumber(date2) == tonumber(date1) then
    return 0
  else
    return -1
  end
end

-- ====== 公历转农历 ======
function M.Date2LunarDate(Gregorian)
  local cTianGan  = D.tiangan
  local cDiZhi    = D.dizhi
  local cShuXiang = D.cShuXiang
  local cDayName  = D.cDayName
  local cMonName  = D.cMonName
  local wNongliData = D.wNongliData

  Gregorian = tostring(Gregorian)
  local Year  = tonumber(string.sub(Gregorian, 1, 4))
  local Month = tonumber(string.sub(Gregorian, 5, 6))
  local Day   = tonumber(string.sub(Gregorian, 7, 8))

  if Year > 2100 or Year < 1899 or Month > 12 or Month < 1 or Day < 1 or Day > 31 or string.len(Gregorian) < 8 then
    return "无效日期"
  end

  local Pos   = Year - 1900 + 2
  local Data0 = wNongliData[Pos - 1]
  local Data1 = wNongliData[Pos]

  local tb1 = Analyze(Data1)
  local MonthInfo = tb1[1]
  local LeapInfo  = tb1[2]
  local Leap      = tb1[3]
  local Newyear   = tb1[4]

  local Date1 = Year .. Newyear
  local Date2 = Gregorian
  local Date3 = M.diffDate(Date1, Date2)

  if Date3 < 0 then
    tb1 = Analyze(Data0)
    Year = Year - 1
    MonthInfo = tb1[1]
    LeapInfo  = tb1[2]
    Leap      = tb1[3]
    Newyear   = tb1[4]
    Date1 = Year .. Newyear
    Date2 = Gregorian
    Date3 = M.diffDate(Date1, Date2)
  end

  Date3 = Date3 + 1
  local LYear = Year

  local thisMonthInfo
  if Leap > 0 then
    thisMonthInfo = string.sub(MonthInfo, 1, Leap) .. LeapInfo .. string.sub(MonthInfo, Leap + 1)
  else
    thisMonthInfo = MonthInfo
  end

  local LMonth, LDay, Isleap
  for i = 1, 13 do
    local thisMonth = string.sub(thisMonthInfo, i, i)
    local thisDays = 29 + thisMonth
    if Date3 > thisDays then
      Date3 = Date3 - thisDays
    else
      if Leap > 0 then
        if Leap >= i then
          LMonth = i
          Isleap = 0
        else
          LMonth = i - 1
          if i - Leap == 1 then
            Isleap = 1
          else
            Isleap = 0
          end
        end
      else
        LMonth = i
        Isleap = 0
      end
      LDay = math.floor(Date3)
      break
    end
  end

  local LunarMonth
  if Isleap > 0 then
    LunarMonth = "闰" .. cMonName[LMonth]
  else
    LunarMonth = cMonName[LMonth]
  end

  local LunarYear = cTianGan[math.fmod(LYear - 4, 10) + 1] .. cDiZhi[math.fmod(LYear - 4, 12) + 1] .. "年(" ..
      cShuXiang[math.fmod(LYear - 4, 12) + 1] .. ")" .. LunarMonth .. cDayName[LDay]
  return LunarYear
end

-- ====== 公历日期间隔计算 ======
local function GettotalDay(Date, dayCount)
  Date = tostring(Date)
  local Year  = tonumber(string.sub(Date, 1, 4))
  local Month = tonumber(string.sub(Date, 5, 6))
  local Day   = tonumber(string.sub(Date, 7, 8))
  local days
  if M.IsLeap(Year) > 365 then
    days = D.DaysLeap
  else
    days = D.DaysNormal
  end

  local total
  if dayCount > days[Month] - Day then
    total = dayCount - (days[Month] - Day)
    Month = Month + 1
    if Month > 12 then
      Month = 1
      Year = Year + 1
    end
    while total > days[Month] do
      total = total - days[Month]
      Month = Month + 1
      if Month > 12 then
        Month = 1
        Year = Year + 1
      end
    end
  else
    total = Day + dayCount
  end

  if string.len(Month) == 1 then
    Month = "0" .. Month
  end
  if string.len(total) == 1 then
    total = "0" .. total
  end
  return Year .. "年" .. Month .. "月" .. total .. "日"
end

-- ====== 农历转公历 ======
function M.LunarDate2Date(Gregorian, IsLeap)
  local LunarData = D.wNongliData
  Gregorian = tostring(Gregorian)
  local Year  = tonumber(string.sub(Gregorian, 1, 4))
  local Month = tonumber(string.sub(Gregorian, 5, 6))
  local Day   = tonumber(string.sub(Gregorian, 7, 8))

  if Year > 2100 or Year < 1900 or Month > 12 or Month < 1 or Day > 30 or Day < 1 or string.len(Gregorian) < 8 then
    return "无效日期"
  end

  local Pos  = (Year - 1899) + 1
  local Data = LunarData[Pos]
  local tb1  = Analyze(Data)
  local MonthInfo = tb1[1]
  local LeapInfo  = tb1[2]
  local Leap      = tb1[3]
  local Newyear   = tb1[4]

  local Sum = 0
  if Leap > 0 then
    local thisMonthInfo = string.sub(MonthInfo, 1, Leap) .. LeapInfo .. string.sub(MonthInfo, Leap + 1)
    if Leap ~= Month and tonumber(IsLeap) == 1 then
      return "该月不是闰月！"
    end
    if Month <= Leap and tonumber(IsLeap) == 0 then
      for i = 1, Month - 1 do
        Sum = Sum + 29 + string.sub(thisMonthInfo, i, i)
      end
    else
      for i = 1, Month do
        Sum = Sum + 29 + string.sub(thisMonthInfo, i, i)
      end
    end
  else
    if tonumber(IsLeap) == 1 then
      return "该年没有闰月！"
    end
    for i = 1, Month - 1 do
      Sum = Sum + 29 + string.sub(MonthInfo, i, i)
    end
  end

  Sum = math.floor(Sum + Day - 1)
  local GDate = Year .. Newyear
  GDate = GettotalDay(GDate, Sum)
  return GDate
end

-- ====== 日期是否存在 ======
function M.DateExists(year, month, day)
  local days
  if M.IsLeap(year) > 365 then
    days = D.DaysLeap
  else
    days = D.DaysNormal
  end
  return month >= 1 and month <= 12 and day >= 1 and day <= days[month]
end

-- ====== 农历倒计时 ======
local function nl_shengri(y, m, d)
  local date1 = os.date("%Y%m%d")
  local nlsrsj = y .. m .. d
  local year = string.sub(nlsrsj, 1, 4)

  local dates = {}
  for month = 1, 12 do
    local date = year .. string.format("%02d", month) .. "15"
    table.insert(dates, date)
  end

  local leap_month = nil
  for _, date in ipairs(dates) do
    local lunar_date = M.Date2LunarDate(tostring(date))
    if string.match(lunar_date, "闰") then
      local lunar_month = string.match(lunar_date, "(.-)月")
      leap_month = D.month_map[lunar_month]
    end
  end

  local lunar_month_str = string.sub(nlsrsj, 5, 6)
  local date2 = nil
  if leap_month and lunar_month_str == leap_month then
    date2 = M.LunarDate2Date(nlsrsj, 1)
  else
    date2 = M.LunarDate2Date(nlsrsj, 0)
  end

  local mm = string.match(date2, "年(.-)月")
  if #mm == 2 then
    date2 = string.gsub(date2, "年", "", 1)
  else
    date2 = string.gsub(date2, "年", "0", 1)
  end
  local dd = string.match(date2, "月(.-)日")
  if #dd == 2 then
    date2 = string.gsub(date2, "月", "", 1)
  else
    date2 = string.gsub(date2, "月", "0", 1)
  end
  date2 = string.gsub(date2, "日", "", 1)

  return M.diffDate(date1, date2)
end

local function nl_shengri2(y, m, d)
  while nl_shengri(y, m, d) == -1 do
    y = math.floor(y + 1)
  end
  return nl_shengri(y, m, d)
end

-- ====== 日期格式化 ======
function M.CnDate_translator(y)
  local cstr = D.cChineseDigits
  local t = ""
  for i = 1, string.len(y) do
    local t2 = cstr[tonumber(string.sub(y, i, i)) + 1]
    if i == 5 and t2 ~= "〇" then
      t2 = "年十"
    elseif i == 5 and t2 == "〇" then
      t2 = "年"
    end
    if i == 6 and t2 ~= "〇" then
      t2 = t2 .. "月"
    elseif i == 6 and t2 == "〇" then
      t2 = "月"
    end
    if i == 7 and tonumber(string.sub(y, 7, 7)) > 1 then
      t2 = t2 .. "十"
    elseif i == 7 and t2 == "〇" then
      t2 = ""
    elseif i == 7 and tonumber(string.sub(y, 7, 7)) == 1 then
      t2 = "十"
    end
    if i == 8 and t2 ~= "〇" then
      t2 = t2 .. "日"
    elseif i == 8 and t2 == "〇" then
      t2 = "日"
    end
    t = t .. t2
  end
  return t
end

function M.format_dt(dt, format_str)
  dt       = dt or {}
  dt.year  = tonumber(dt.year) or 0
  dt.month = tonumber(dt.month) or 1
  dt.day   = tonumber(dt.day) or 1
  dt.hour  = tonumber(dt.hour) or 0
  dt.min   = tonumber(dt.min) or 0
  dt.sec   = tonumber(dt.sec) or 0

  local s      = format_str or ""

  local blocks = {}
  s            = s:gsub("%[%[(.-)%]%]", function(txt)
    blocks[#blocks + 1] = txt
    return "\0BLK" .. #blocks .. "\0"
  end)

  local escs   = {}
  s            = s:gsub("\\(.)", function(c)
    escs[#escs + 1] = c
    return "\0ESC" .. #escs .. "\0"
  end)

  s            = s:gsub("Y", string.format("%04d", dt.year))
  s            = s:gsub("y", string.format("%02d", dt.year % 100))
  s            = s:gsub("m", string.format("%02d", dt.month))
  s            = s:gsub("d", string.format("%02d", dt.day))
  s            = s:gsub("n", tostring(dt.month))
  s            = s:gsub("j", tostring(dt.day))

  s            = s:gsub("H", string.format("%02d", dt.hour))
  s            = s:gsub("G", tostring(dt.hour))

  local h12    = dt.hour % 12
  if h12 == 0 then h12 = 12 end
  s = s:gsub("I", string.format("%02d", h12))
  s = s:gsub("l", tostring(h12))
  s = s:gsub("M", string.format("%02d", dt.min))
  s = s:gsub("S", string.format("%02d", dt.sec))

  local ampm = (dt.hour < 12) and "AM" or "PM"
  s = s:gsub("p", ampm:lower())
  s = s:gsub("P", ampm)

  local zh_period = ""
  local h = dt.hour
  if h < 6 then
    zh_period = "凌晨"
  elseif h < 12 then
    zh_period = "上午"
  elseif h < 13 then
    zh_period = "中午"
  elseif h < 18 then
    zh_period = "下午"
  else
    zh_period = "晚上"
  end
  s = s:gsub("A", zh_period)

  local raw_tz = os.date("%z") or "+0000"
  local tz_colon = raw_tz:sub(1, 3) .. ":" .. raw_tz:sub(4, 5)
  s = s:gsub("O", tz_colon)
  s = s:gsub("o", raw_tz)

  s = s:gsub("\0ESC(%d+)\0", function(i) return escs[tonumber(i)] or "" end)
  s = s:gsub("\0BLK(%d+)\0", function(i) return blocks[tonumber(i)] or "" end)

  return s
end

-- ====== 星期 ======
function M.chinese_weekday(wday)
  return D.cWeekdayShort[wday + 1]
end

function M.chinese_weekday2(week_day_num)
  return D.cWeekdayFull[week_day_num + 1]
end

function M.iso_week_number(year, month, day)
  local function get_iso_weekday(y, m, d)
    local t = os.time { year = y, month = m, day = d }
    local w = tonumber(os.date("%w", t))
    return (w == 0) and 7 or w
  end

  local t = os.time { year = year, month = month, day = day }
  local iso_day = get_iso_weekday(year, month, day)
  local thursday_time = t + (4 - iso_day) * 86400
  local thursday = os.date("*t", thursday_time)

  local first_thursday = os.time { year = thursday.year, month = 1, day = 4 }
  local first_thursday_weekday = get_iso_weekday(thursday.year, 1, 4)
  local start_of_week1 = first_thursday - (first_thursday_weekday - 1) * 86400

  local week_number = math.floor((thursday_time - start_of_week1) / (7 * 86400)) + 1
  return thursday.year, week_number
end

-- ====== 节日辅助 ======
local function get_nth_weekday(year, month, weekday, n)
  for day = 1, 31 do
    local current_date = os.time({ year = year, month = month, day = day })
    if os.date("%m", current_date) ~= string.format("%02d", month) then
      break
    end
    local week_day_str = M.chinese_weekday2(tonumber(os.date("%w", current_date)))
    if week_day_str == weekday then
      n = n - 1
      if n == 0 then
        return os.date("%Y%m%d", current_date)
      end
    end
  end
  return nil
end

local function days_until(target_date)
  local current_date = os.date("%Y%m%d")
  target_date = target_date:gsub("%D", "")
  return M.diffDate(current_date, target_date)
end

local function get_upcoming_holidays()
  local upcoming_holidays = {}
  local current_year = os.date("%Y")

  -- 公历节日
  for holiday, date in pairs(D.solar_holidays) do
    local target_date = current_year .. date
    local days_left = days_until(target_date)
    if days_left >= 0 then
      local mm, dd = target_date:sub(5, 6), target_date:sub(7, 8)
      local formatted_date = string.format("%s年%s月%s日", current_year, mm, dd)
      table.insert(upcoming_holidays, { holiday, formatted_date, days_left })
    end
  end

  -- 农历节日
  for holiday, lunar_date in pairs(D.lunar_holidays) do
    local days_ymd = os.date("%Y%m%d")
    local countdown = nl_shengri2(os.date("%Y"), lunar_date:sub(1, 2), lunar_date:sub(3, 4))
    if countdown < 0 then
      countdown = nl_shengri2(os.date("%Y") + 1, lunar_date:sub(1, 2), lunar_date:sub(3, 4))
    end
    local solar_date = GettotalDay(days_ymd, countdown)
    table.insert(upcoming_holidays, { holiday, solar_date, countdown })

    if holiday == "春节" then
      local year, month, day = solar_date:match("^(%d+)年(%d+)月(%d+)日")
      local previous_day = os.time {
        year = tonumber(year), month = tonumber(month), day = tonumber(day)
      } - 24 * 60 * 60
      local eve_date = os.date("%Y年%m月%d日", previous_day)
      table.insert(upcoming_holidays, { "除夕", eve_date, countdown - 1 })
    end
  end

  -- 感恩节
  local thanksgiving_date = get_nth_weekday(current_year, 11, "星期四", 4)
  local thanksgiving_days_left = days_until(thanksgiving_date)
  if thanksgiving_days_left and thanksgiving_days_left >= 0 then
    local formatted_date = thanksgiving_date:sub(1, 4) .. "年" .. thanksgiving_date:sub(5, 6) .. "月" ..
        thanksgiving_date:sub(7, 8) .. "日"
    table.insert(upcoming_holidays, { "感恩节", formatted_date, thanksgiving_days_left })
  end

  -- 母亲节
  local mothers_day_date = get_nth_weekday(current_year, 5, "星期日", 2)
  local mothers_day_days_left = days_until(mothers_day_date)
  if mothers_day_days_left and mothers_day_days_left >= 0 then
    local formatted_date = mothers_day_date:sub(1, 4) .. "年" .. mothers_day_date:sub(5, 6) .. "月" ..
        mothers_day_date:sub(7, 8) .. "日"
    table.insert(upcoming_holidays, { "母亲节", formatted_date, mothers_day_days_left })
  end

  -- 父亲节
  local fathers_day_date = get_nth_weekday(current_year, 6, "星期日", 3)
  local fathers_day_days_left = days_until(fathers_day_date)
  if fathers_day_days_left and fathers_day_days_left >= 0 then
    local formatted_date = fathers_day_date:sub(1, 4) .. "年" .. fathers_day_date:sub(5, 6) .. "月" ..
        fathers_day_date:sub(7, 8) .. "日"
    table.insert(upcoming_holidays, { "父亲节", formatted_date, fathers_day_days_left })
  end

  -- 清明节
  local jqs = A.GetNowTimeJq(os.date("%Y%m%d", os.time()))
  for _, jq_info in ipairs(jqs) do
    local jq_name, jq_date = jq_info:match("^(%S+)%s+(%d+%-%d+%-%d+)$")
    if jq_name == "清明" then
      local formatted_date = jq_date:gsub("%-", "")
      local days_left = days_until(formatted_date)
      formatted_date = jq_date:sub(1, 4) .. "年" .. jq_date:sub(6, 7) .. "月" .. jq_date:sub(9, 10) .. "日"
      table.insert(upcoming_holidays, { "清明节", formatted_date, days_left })
    end
  end

  table.sort(upcoming_holidays, function(a, b) return a[3] < b[3] end)
  return upcoming_holidays
end

M.get_upcoming_holidays = get_upcoming_holidays
M.days_until = days_until

-- ====== QueryLunarInfo ======
function M.QueryLunarInfo(env, date)
  local config = env.engine.schema.config
  date = tostring(date)
  local result = {}
  local str = date:gsub("^(%u+)", "")

  if string.match(str, "^(20)%d%d+$") ~= nil or string.match(str, "^(19)%d%d+$") ~= nil then
    if string.len(str) == 4 then
      str = str .. "010101"
    elseif string.len(str) == 5 then
      str = str .. "10101"
    elseif string.len(str) == 6 then
      str = str .. "0101"
    elseif string.len(str) == 7 then
      str = str .. "101"
    elseif string.len(str) == 8 then
      str = str .. "01"
    elseif string.len(str) == 9 then
      str = str .. "0"
    else
      str = string.sub(str, 1, 10)
    end

    if tonumber(string.sub(str, 5, 6)) > 12 or tonumber(string.sub(str, 5, 6)) < 1 or
        tonumber(string.sub(str, 7, 8)) > 31 or tonumber(string.sub(str, 7, 8)) < 1 or
        tonumber(string.sub(str, 9, 10)) > 24 then
      return result
    end

    local LunarDate = M.Date2LunarDate(str)
    local LunarGz = G.lunarJzl(str)
    local DateTime = M.LunarDate2Date(str, 0)
    local dateRQ = string.sub(str, 1, 4) .. "年" .. string.sub(str, 5, 6) .. "月" .. string.sub(str, 7, 8) .. "日"

    if LunarGz ~= nil then
      local y = tonumber(string.sub(str, 1, 4))
      local m = tonumber(string.sub(str, 5, 6))
      local d = tonumber(string.sub(str, 7, 8))

      local custom_formats = config:get_list("date_formats")
      local use_custom_format = custom_formats and custom_formats.size > 0

      if use_custom_format then
        result = {}
        for i = 1, custom_formats.size do
          local format_str = custom_formats:get_value_at(i - 1):get_string()
          local formatted_date = M.format_dt({ year = y, month = m, day = d }, format_str)
          if formatted_date then
            table.insert(result, { formatted_date, "" })
          end
        end
      else
        result = {
          { dateRQ, "" },
          { string.sub(str, 1, 4) .. "." .. string.sub(str, 5, 6) .. "." .. string.sub(str, 7, 8), "" },
          { string.sub(str, 1, 4) .. "-" .. string.sub(str, 5, 6) .. "-" .. string.sub(str, 7, 8), "" },
          { string.sub(str, 1, 4) .. "/" .. string.sub(str, 5, 6) .. "/" .. string.sub(str, 7, 8), "" },
          { string.format("%d年%d月%d日", y, m, d), "" },
          { string.format("%d月%d日", m, d), "" },
        }
      end

      table.insert(result, { LunarDate, "" })
      table.insert(result, { LunarGz, "" })

      if tonumber(string.sub(str, 7, 8)) < 31 then
        table.insert(result, { DateTime, "" })
        local leapDate = M.LunarDate2Date(str, 1) .. "（闰）"
        if string.match(leapDate, "^(%d+)") ~= nil then
          table.insert(result, { leapDate, "〔农历⇉公历〕" })
        end
      end
    end
  end
  return result
end

return M
