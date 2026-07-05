-- 万象时间 · 干支历模块
-- GanZhiLi 类、lunarJzl、GetLunarSichen

local A = require("wanxiang/astronomy")
local D = require("wanxiang/shijian_data")

local ganzhi = {}

-- ====== 周期循环辅助 ======
local function calR2(n, round)
  local x = math.floor(math.fmod(n, round))
  if x == 0 then
    x = round
  end
  return x
end

-- ====== GanZhiLi 类 ======
local GanZhiLi = {}
GanZhiLi.__index = GanZhiLi

function GanZhiLi:new()
  local o = {}
  setmetatable(o, self)
  o:setTime(os.time())
  return o
end

function GanZhiLi:calRound(start, offset, round)
  if start > round or start <= 0 then
    return nil
  end
  offset = math.floor(math.fmod(start + offset, round))
  if offset >= 0 then
    if offset == 0 then
      offset = round
    end
    return offset
  else
    return round + offset
  end
end

function GanZhiLi:setTime(t)
  self.ttime = t
  self.tday = os.date('*t', t)
  self.jqs = A.getYearJQ(self.tday.year)
  self.ganZhiYearNum = self:calGanZhiYearNum()
  if self.ganZhiYearNum ~= self.tday.year then
    self.jqs = A.getYearJQ(self.ganZhiYearNum)
  end
  self.ganZhiMonNum = self:calGanZhiMonthNum()
  self.curJq = self:getCurJQ()
end

function GanZhiLi:getCurJQ()
  if self.ttime < self.jqs[1] then
    return nil
  end
  local x = 0
  for i = 1, 23 do
    if self.jqs[i] <= self.ttime and self.jqs[i + 1] > self.ttime then
      x = i
      break
    end
  end
  if x == 0 then
    x = 24
  end
  return x
end

function GanZhiLi:calGanZhiYearNum()
  if self.ttime < self.jqs[1] then
    return self.tday.year - 1
  else
    return self.tday.year
  end
end

function GanZhiLi:calGanZhiMonthNum()
  if self.ttime < self.jqs[1] then
    return nil
  end
  local x = 0
  for i = 1, 23 do
    if self.jqs[i] <= self.ttime and self.jqs[i + 1] > self.ttime then
      x = i
    end
  end
  if x == 0 then
    x = 24
  end
  return math.floor((x + 1) / 2)
end

function GanZhiLi:getYearGanZhi()
  local yeardiff = self.ganZhiYearNum - D.ganzhi_ref_jiazi_year
  return self:calRound(1, yeardiff, 60)
end

function GanZhiLi:getYearGan()
  return calR2(self:getYearGanZhi(), 10)
end

function GanZhiLi:getYearZhi()
  return calR2(self:getYearGanZhi(), 12)
end

function GanZhiLi:getMonGanZhi()
  local ck = D.ganzhi_ref_month
  local ydiff = self.ganZhiYearNum - ck.year
  local mdiff = self.ganZhiMonNum - 1
  if ydiff >= 0 then
    mdiff = ydiff * 12 + mdiff
  else
    mdiff = (ydiff + 1) * 12 + mdiff - 12
  end
  return self:calRound(D.ganzhi_ref_month_value, mdiff, 60)
end

function GanZhiLi:getMonGan()
  return calR2(self:getMonGanZhi(), 10)
end

function GanZhiLi:getMonZhi()
  return calR2(self:getMonGanZhi(), 12)
end

function GanZhiLi:getDayGanZhi()
  local DAYSEC = 24 * 3600
  local jiaziDayTime = os.time(D.ganzhi_ref_epoch)
  local daydiff = math.floor((self.ttime - jiaziDayTime) / DAYSEC)
  return self:calRound(1, daydiff, 60)
end

function GanZhiLi:getDayGan()
  return calR2(self:getDayGanZhi(), 10)
end

function GanZhiLi:getDayZhi()
  return calR2(self:getDayGanZhi(), 12)
end

function GanZhiLi:getHourGanZhi()
  local SHICHENSEC = 3600 * 2
  local jiaziShiTime = os.time(D.ganzhi_ref_epoch)
  local shiDiff = math.floor((self.ttime - jiaziShiTime) / SHICHENSEC)
  return self:calRound(1, shiDiff, 60)
end

function GanZhiLi:getShiGan()
  return calR2(self:getHourGanZhi(), 10)
end

function GanZhiLi:getShiZhi()
  return calR2(self:getHourGanZhi(), 12)
end

ganzhi.GanZhiLi = GanZhiLi

-- ====== 六十甲子 ======
local function get60JiaZiStr(i)
  local gan = i % 10
  if gan == 0 then
    gan = 10
  end
  local zhi = i % 12
  if zhi == 0 then
    zhi = 12
  end
  return D.tiangan[gan] .. D.dizhi[zhi]
end

-- ====== 干支历转换 ======
function ganzhi.lunarJzl(y)
  y = tostring(y)
  local x = GanZhiLi:new()
  x:setTime(os.time({
    year = tonumber(string.sub(y, 1, 4)),
    month = tonumber(string.sub(y, 5, -5)),
    day = tonumber(string.sub(y, 7, -3)),
    hour = tonumber(string.sub(y, 9, -1)),
    min = 4,
    sec = 5
  }))
  local yidx = x:getYearGanZhi()
  local midx = x:getMonGanZhi()
  local didx = x:getDayGanZhi()
  local hidx = x:getHourGanZhi()
  return get60JiaZiStr(yidx) .. '年' .. get60JiaZiStr(midx) .. '月' .. get60JiaZiStr(didx) .. '日' ..
      get60JiaZiStr(hidx) .. '时'
end

-- ====== 时辰 ======
function ganzhi.GetLunarSichen(time, t)
  time = tonumber(time)
  local sj
  if tonumber(t) == 1 then
    sj = math.floor((time + 1) / 2) + 1
  elseif tonumber(t) == 0 then
    sj = math.floor((time + 13) / 2) + 1
  end
  if sj > 12 then
    return D.LunarSichen[sj - 12]
  else
    return D.LunarSichen[sj]
  end
end

return ganzhi
