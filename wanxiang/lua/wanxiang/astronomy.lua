-- 万象时间 · 天文计算引擎
-- 角度变换、JDate、黄赤坐标、光行差、章动、日月位置、节气计算

local D = require("wanxiang/shijian_data")

local astronomy = {}

-- ====== 角度变换 ======
local rad = 180 * 3600 / math.pi
local RAD = 180 / math.pi

local function int2(v)
  v = math.floor(v)
  if v < 0 then
    return v + 1
  else
    return v
  end
end

local function rad2mrad(v)
  v = math.fmod(v, 2 * math.pi)
  if v < 0 then
    return v + 2 * math.pi
  else
    return v
  end
end

-- ====== 日历计算 ======
local J2000 = 2451545

-- 光行差参数（依赖 RAD/rad）
local GXC_p = { 102.93735 / RAD, 1.71946 / RAD, 0.00046 / RAD }
local GXC_l = {
  280.4664567 / RAD, 36000.76982779 / RAD, 0.0003032028 / RAD,
  1 / 49931000 / RAD, -1 / 153000000 / RAD
}
local GXC_k = 20.49552 / rad

local JDate = {
  Y = 2000, M = 1, D = 1, h = 12, m = 0, s = 0,
  dts = D.dts
}

function JDate.deltatT(self, y)
  local i
  local d = self.dts
  for x = 1, 100, 5 do
    if y < d[x + 5] or x == 96 then
      i = x
      break
    end
  end
  local t1 = (y - d[i]) / (d[i + 5] - d[i]) * 10
  local t2 = t1 * t1
  local t3 = t2 * t1
  return d[i + 1] + d[i + 2] * t1 + d[i + 3] * t2 + d[i + 4] * t3
end

function JDate.deltatT2(self, jd)
  return self:deltatT(jd / 365.2425 + 2000) / 86400.0
end

function JDate.toJD(self, UTC)
  local y = self.Y
  local m = self.M
  local n = 0
  if m <= 2 then
    m = m + 12
    y = y - 1
  end
  if self.Y * 372 + self.M * 31 + self.D >= 588829 then
    n = int2(y / 100)
    n = 2 - n + int2(n / 4)
  end
  n = n + int2(365.2500001 * (y + 4716))
  n = n + int2(30.6 * (m + 1)) + self.D
  n = n + ((self.s / 60 + self.m) / 60 + self.h) / 24 - 1524.5
  if UTC == 1 then
    return n + self:deltatT2(n - J2000)
  end
  return n
end

function JDate.setFromJD(self, jd, UTC)
  if UTC == 1 then
    jd = jd - self:deltatT2(jd - J2000)
  end
  jd = jd + 0.5
  local A = int2(jd)
  local F = jd - A
  local D
  if A > 2299161 then
    D = int2((A - 1867216.25) / 36524.25)
    A = A + 1 + D - int2(D / 4)
  end
  A = A + 1524
  self.Y = int2((A - 122.1) / 365.25)
  D = A - int2(365.25 * self.Y)
  self.M = int2(D / 30.6001)
  self.D = D - int2(self.M * 30.6001)
  self.Y = self.Y - 4716
  self.M = self.M - 1
  if self.M > 12 then
    self.M = self.M - 12
  end
  if self.M <= 2 then
    self.Y = self.Y + 1
  end
  F = F * 24
  self.h = int2(F)
  F = F - self.h
  F = F * 60
  self.m = int2(F)
  F = F - self.m
  F = F * 60
  self.s = F
end

function JDate.setFromStr(self, s)
  self.Y = tonumber(string.sub(s, 1, 4)) or 2000
  self.M = tonumber(string.sub(s, 5, 6)) or 1
  self.D = tonumber(string.sub(s, 7, 8)) or 1
  self.h = tonumber(string.sub(s, 10, 11)) or 12
  self.m = tonumber(string.sub(s, 12, 13)) or 0
  self.s = tonumber(string.sub(s, 14, 18)) or 0
end

function JDate.toStr(self)
  local Y = "     " .. self.Y
  local M = "0" .. self.M
  local D = "0" .. self.D
  local h = self.h
  local m = self.m
  local s = math.floor(self.s + .5)
  if s >= 60 then
    s = s - 60
    m = m + 1
  end
  if m >= 60 then
    m = m - 60
    h = h + 1
  end
  h = "0" .. h
  m = "0" .. m
  s = "0" .. s
  local Ylen = string.len(Y)
  local Mlen = string.len(M)
  local Dlen = string.len(D)
  local hlen = string.len(h)
  local mlen = string.len(m)
  local slen = string.len(s)
  Y = string.sub(Y, Ylen - 4, Ylen)
  M = string.sub(M, Mlen - 1, Mlen)
  D = string.sub(D, Dlen - 1, Dlen)
  h = string.sub(h, hlen - 1, hlen)
  m = string.sub(m, mlen - 1, mlen)
  s = string.sub(s, slen - 1, slen)
  return Y .. "-" .. M .. "-" .. D .. " " .. h .. ":" .. m .. ":" .. s
end

function JDate.JQ(self)
  local t = {}
  t.year = self.Y
  t.month = self.M
  t.day = self.D
  t.hour = self.h
  t.min = self.m
  t.sec = math.floor(self.s + .5)
  if t.sec >= 60 then
    t.sec = t.sec - 60
    t.min = t.min + 1
  end
  if t.min >= 60 then
    t.min = t.min - 60
    t.hour = t.hour + 1
  end
  return os.time(t)
end

function JDate.Dint_dec(self, jd, shiqu, int_dec)
  local u = jd + 0.5 - self:deltatT2(jd) + shiqu / 24
  if int_dec ~= 0 then
    return math.floor(u)
  else
    return u - math.floor(u)
  end
end

function JDate.d1_d2(self, d1, d2)
  local saveY = self.Y
  local saveM = self.M
  local saveD = self.D
  local saveh = self.h
  local savem = self.m
  local saves = self.s
  self:setFromStr(string.sub(d1, 1, 8) .. " 120000")
  local jd1 = self:toJD(0)
  self:setFromStr(string.sub(d2, 1, 8) .. " 120000")
  local jd2 = self:toJD(0)
  self.Y = saveY
  self.M = saveM
  self.D = saveD
  self.h = saveh
  self.m = savem
  self.s = saves
  if jd1 > jd2 then
    return math.floor(jd1 - jd2 + .0001)
  else
    return -math.floor(jd2 - jd1 + .0001)
  end
end

local function addPrece(jd, zb)
  local t = 1
  local v = 0
  local t1 = jd / 365250
  for i = 2, 8 do
    t = t * t1
    v = v + D.preceB[i] * t
  end
  zb[1] = rad2mrad(zb[1] + (v + 2.9965 * t1) / rad)
end

-- ====== 光行差 ======
local function addGxc(t, zb)
  local t1 = t / 36525
  local t2 = t1 * t1
  local t3 = t2 * t1
  local t4 = t3 * t1
  local L = GXC_l[1] + GXC_l[2] * t1 + GXC_l[3] * t2 + GXC_l[4] * t3 + GXC_l[5] * t4
  local p = GXC_p[1] + GXC_p[2] * t1 + GXC_p[3] * t2
  local e = D.GXC_e[1] + D.GXC_e[2] * t1 + D.GXC_e[3] * t2
  local dL = L - zb[1]
  local dP = p - zb[1]
  zb[1] = zb[1] - (GXC_k * (math.cos(dL) - e * math.cos(dP)) / math.cos(zb[2]))
  zb[2] = zb[2] - (GXC_k * math.sin(zb[2]) * (math.sin(dL) - e * math.sin(dP)))
  zb[1] = rad2mrad(zb[1])
end

-- ====== 章动 ======
local function nutation(t)
  local d = { Lon = 0, Obl = 0 }
  t = t / 36525
  local t1 = t
  local t2 = t1 * t1
  local t3 = t2 * t1
  local t4 = t3 * t1
  local t5 = t4 * t1
  for i = 1, #D.nutB, 9 do
    local c = D.nutB[i] + D.nutB[i + 1] * t1 + D.nutB[i + 2] * t2 + D.nutB[i + 3] * t3 + D.nutB[i + 4] * t4
    d.Lon = d.Lon + (D.nutB[i + 5] + D.nutB[i + 6] * t / 10) * math.sin(c)
    d.Obl = d.Obl + (D.nutB[i + 7] + D.nutB[i + 8] * t / 10) * math.cos(c)
  end
  d.Lon = d.Lon / (rad * 10000)
  d.Obl = d.Obl / (rad * 10000)
  return d
end

-- ====== 日月位置 ======
local EnnT = 0
local function Enn(F)
  local v = 0
  for i = 1, #F, 3 do
    v = v + F[i] * math.cos(F[i + 1] + EnnT * F[i + 2])
  end
  return v
end

local function earCal(jd)
  EnnT = jd / 365250
  local llr = {}
  local t1 = EnnT
  local t2 = t1 * t1
  local t3 = t2 * t1
  local t4 = t3 * t1
  local t5 = t4 * t1
  llr[1] = Enn(D.E10) + Enn(D.E11) * t1 + Enn(D.E12) * t2 + Enn(D.E13) * t3 + Enn(D.E14) * t4 + Enn(D.E15) * t5
  llr[2] = Enn(D.E20) + Enn(D.E21) * t1
  llr[3] = Enn(D.E30) + Enn(D.E31) * t1 + Enn(D.E32) * t2 + Enn(D.E33) * t3
  llr[1] = rad2mrad(llr[1])
  return llr
end

local MnnT = 0
local function Mnn(F)
  local v = 0
  local t1 = MnnT
  local t2 = t1 * t1
  local t3 = t2 * t1
  local t4 = t3 * t1
  for i = 1, #F, 6 do
    v = v + F[i] * math.sin(F[i + 1] + t1 * F[i + 2] + t2 * F[i + 3] + t3 * F[i + 4] + t4 * F[i + 5])
  end
  return v
end

local function moonCal(jd)
  MnnT = jd / 36525
  local t1 = MnnT
  local t2 = t1 * t1
  local t3 = t2 * t1
  local t4 = t3 * t1
  local llr = {}
  llr[1] = (Mnn(D.M10) + Mnn(D.M11) * t1 + Mnn(D.M12) * t2) / rad
  llr[2] = (Mnn(D.M20) + Mnn(D.M21) * t1) / rad
  llr[3] = (Mnn(D.M30) + Mnn(D.M31) * t1) * 0.999999949827
  llr[1] = llr[1] + D.M1n[1] + D.M1n[2] * t1 + D.M1n[3] * t2 + D.M1n[4] * t3 + D.M1n[5] * t4
  llr[1] = rad2mrad(llr[1])
  addPrece(jd, llr)
  return llr
end

-- ====== 定朔弦望计算 ======
local function jiaoCai(lx, t, jiao)
  local sun = earCal(t)
  sun[1] = sun[1] + math.pi
  sun[2] = -sun[2]
  addGxc(t, sun)
  if lx == 0 then
    local d = nutation(t)
    sun[1] = sun[1] + d.Lon
    return rad2mrad(jiao - sun[1])
  end
  local moon = moonCal(t)
  return rad2mrad(jiao - (moon[1] - sun[1]))
end

local function jiaoCal(t1, jiao, lx)
  local t2 = t1
  local t = 0
  if lx == 0 then
    t2 = t2 + 360
  else
    t2 = t2 + 25
  end
  jiao = jiao * math.pi / 180
  local v1 = jiaoCai(lx, t1, jiao)
  local v2 = jiaoCai(lx, t2, jiao)
  if v1 < v2 then
    v2 = v2 - 2 * math.pi
  end
  local k = 1
  for i = 1, 10 do
    local k2 = (v2 - v1) / (t2 - t1)
    if math.abs(k2) > 1e-15 then
      k = k2
    end
    t = t1 - v1 / k
    local v = jiaoCai(lx, t, jiao)
    if v > 1 then
      v = v - 2 * math.pi
    end
    if math.abs(v) < 1e-8 then
      break
    end
    t1 = t2
    v1 = v2
    t2 = t
    v2 = v
  end
  return t
end

-- ====== 节气计算 ======
local jqB = D.jqB_chunfen

function astronomy.JQtest(y)
  y = tostring(y)
  local jd = 365.2422 * (tonumber(string.sub(y, 1, 4)) - 2000)
  for i = 0, 23 do
    local q = jiaoCal(jd + i * 15.2, i * 15, 0) + J2000 + 8 / 24
    JDate:setFromJD(q, 1)
    local s1 = JDate:toStr()
    JDate:setFromJD(q, 0)
    local s2 = JDate:toStr()
    local jqData = s1:gsub("^( )", ""):sub(1, 10)
    jqData = jqData:gsub("-", "")
    if jqData == y then
      return "-" .. jqB[i + 1]
    end
  end
  return ""
end

function astronomy.GetNextJQ(y)
  y = tostring(y)
  local jd = 365.2422 * (tonumber(string.sub(y, 1, 4)) - 2000)
  local obj = {}
  for i = 0, 23 do
    local q = jiaoCal(jd + i * 15.2, i * 15, 0) + J2000 + 8 / 24
    JDate:setFromJD(q, 1)
    local s1 = JDate:toStr()
    JDate:setFromJD(q, 0)
    local s2 = JDate:toStr()
    local jqData = s1:gsub("^( )", ""):sub(1, 10)
    jqData = jqData:gsub("-", "")
    if jqData >= y then
      table.insert(obj, jqB[i + 1] .. " " .. s1:gsub("^( )", ""):sub(1, 10))
    end
  end
  return obj
end

function astronomy.getJQ(y)
  local jd = 365.2422 * (y - 2000)
  local jq = {}
  for i = 0, 23 do
    local q = jiaoCal(jd + i * 15.2, i * 15, 0) + J2000 + 8 / 24
    JDate:setFromJD(q, 1)
    jq[i + 1] = JDate:JQ()
  end
  return jq
end

function astronomy.getYearJQ(y)
  local jq1 = astronomy.getJQ(y - 1)
  local jq2 = astronomy.getJQ(y)
  local jq = {}
  for i = 1, 3 do
    jq[i] = jq1[i + 21]
  end
  for i = 1, 21 do
    jq[i + 3] = jq2[i]
  end
  return jq
end

function astronomy.GetNowTimeJq(date)
  date = tostring(date)
  if string.len(date) < 8 then
    return "无效日期"
  end
  local JQtable2 = astronomy.GetNextJQ(date)
  if tonumber(string.sub(date, 5, 8)) < 322 then
    local JQtable1 = astronomy.GetNextJQ(tonumber(string.sub(date, 1, 4)) - 1 .. "0101")
    if tonumber(string.sub(date, 5, 8)) < 108 then
      for i = 20, 24 do
        table.insert(JQtable2, i - 19, JQtable1[i])
      end
    elseif tonumber(string.sub(date, 5, 8)) < 122 then
      for i = 21, 24 do
        table.insert(JQtable2, i - 20, JQtable1[i])
      end
    elseif tonumber(string.sub(date, 5, 8)) < 206 then
      for i = 22, 24 do
        table.insert(JQtable2, i - 21, JQtable1[i])
      end
    elseif tonumber(string.sub(date, 5, 8)) < 221 then
      for i = 23, 24 do
        table.insert(JQtable2, i - 22, JQtable1[i])
      end
    else
      table.insert(JQtable2, 1, JQtable1[24])
    end
  end
  return JQtable2
end

return astronomy
