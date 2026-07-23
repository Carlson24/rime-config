--[[
==============================================================================
  Rime 计算器插件功能参考
  移植自 super_calculator.lua，纯 C++ 实现
  Copyright © amzxyz — 完整功能文档
==============================================================================

==== 概述 ====

  计算器插件提供两种输入模式：

  1. V 模式（前缀触发）：输入大写 V 后跟表达式或函数名
     例：V1+2*3、Vsin(deg(80))、Vunit(100,'km','m')

  2. 数字提交模式：在中文模式下直接输入数字并提交到应用，
     随后输入运算符即可触发链式计算
     例：输入 84 → 按 + → 输入 5 → 得出 89

  常用特殊命令：
    Vhelp      列出全部函数及签名
    5!         阶乘简写，等价于 fact(5)

==== Schema 配置（完整模式：V 模式 + 数字提交） ====

  在 .schema.yaml 或自定义配置中添加：

    engine:
      processors:
        - digit_catcher          -- 必须放在 recognizer 之前
        - recognizer
      segmentors:
        - matcher                -- 必须
      translators:
        - calculator_translator  -- 建议放在 echo_translator 之前
        - echo_translator

    recognizer:
      patterns:
        calculator: "^(V.*|[0-9]+[\\+\\-\\*/\\^].*|[\\+\\-\\*/\\^].*)$"

    calculator:
      tag: calculator            -- 可选，默认 "calculator"
      prefix: "V"                -- 可选，触发前缀，默认从 pattern 中提取
      tips: "计算器"             -- 可选，候选窗提示文字

==== Schema 配置（仅 V 模式） ====

  仅保留 V 模式下触发计算器，数字键恢复为正常输入行为：

    engine:
      processors:
        - recognizer             -- 去掉 digit_catcher
        -- 其他 processor...
      segmentors:
        - matcher
        -- 其他 segmentor...
      translators:
        - calculator_translator
        - echo_translator        -- 可选，让未匹配的输入直通
        -- 其他 translator...

    recognizer:
      patterns:
        calculator: "^V.*$"      -- 只匹配 V 开头

    calculator:
      prefix: "V"
      tips: "计算器"

  与完整模式的区别：
    1. 去掉 digit_catcher，数字键不会自动提交到应用
    2. recognizer 模式从混合匹配简化为纯 V 前缀匹配
    3. 无法使用链式计算（V84+5 仍可直接计算，但不继承上次结果）

==== 全局常量 ====

  e   2.718281828459045    自然常数
  pi  3.141592653589793    圆周率
  b   100                  百
  q   1000                 千
  k   1000                 千
  w   10000                万
  tw  100000               十万
  m   1000000              百万
  tm  10000000             千万
  y   100000000            亿
  g   1000000000           十亿

==== 运算符 ====

  +  加                -  减
  *  乘                /  除
  %  取模              ^  幂（指数）
  () 括号              !  阶乘简写（如 5! 等价于 fact(5)）

  运算符优先级（从高到低）：
    ^                    右结合
    一元 -（取负）
    * / %
    + -

==== 基础数学函数 ====

  sin(x)              正弦函数，x 为弧度
  cos(x)              余弦函数，x 为弧度
  tan(x)              正切函数，x 为弧度
  asin(x)             反正弦，返回弧度
  acos(x)             反余弦，返回弧度
  atan(x)             反正切，返回弧度
  atan2(y, x)         返回点 (x,y) 相对于 x 轴的逆时针角度（弧度）
  sinh(x)             双曲正弦
  cosh(x)             双曲余弦
  tanh(x)             双曲正切
  deg(x)              弧度转角度
  rad(x)              角度转弧度
  exp(x)              返回 e^x
  ldexp(x, y)         返回 x * 2^y
  log(x, y)           以 x 为底求 y 的对数
  loge(x)             以 e 为底的对数（自然对数）
  logt(x)             以 10 为底的对数（常用对数）
  sqrt(x)             正数的算术平方根
  csqrt(a[, b])       复数的平方根，参数 1~2 个（实部、虚部）
  nroot(x, n)         计算 x 开 n 次方
  ceil(x)             向上取整
  floor(x)            向下取整

==== 幂和数列 ====

  sqsum(n)            前 n 个连续自然数的平方和（从 1 开始），公式: n(n+1)(2n+1)/6
  cbsum(n)            前 n 个连续自然数的立方和（从 1 开始），公式: [n(n+1)/2]²
  qpsum(n)            前 n 个连续自然数的 4 次方和（从 1 开始），公式: n(n+1)(2n+1)(3n²+3n-1)/30
  osqsum(n)           前 n 个奇数的平方和
  esqsum(n)           前 n 个偶数的平方和
  ocbsum(n)           前 n 个奇数的立方和
  ecbsum(n)           前 n 个偶数的立方和
  oqpsum(n)           前 n 个奇数的 4 次方和
  eqpsum(n)           前 n 个偶数的 4 次方和

==== 组合与数论 ====

  fact(n)             阶乘 n!（n 为非负整数）
  perm(n, r)          排列数 P(n,r) = n!/(n-r)!
  comb(n, r)          组合数 C(n,r) = n!/(r!(n-r)!)
  gcd(a, b, ...)      最大公因数，支持多个参数
  lcm(a, b, ...)      最小公倍数，支持多个参数
  mod(x, y)           取余函数（结果非负）

==== 数列 ====

  arith_sum(a1, d, n)    已知等差数列首项 a₁、公差 d，求前 n 项和
  geo_sum(a1, q, n)      已知等比数列首项 a₁、公比 q，求前 n 项和
  seq(i, ai, k, ak, b)   已知数列任意两项 aᵢ、aₖ 及对应项数 i、k，求通项公式，b=0 为等差数列，b=1 为等比数列

==== 统计 ====

  avg(a, b, ...)      计算多个数的平均值（参数个数不限）
  var(a, b, ...)      计算多个数的方差（参数个数不限）

==== 方程求解 ====

  eq1(a, b)             求解一元一次方程 ax + b = 0
  eq2(a, b, e, c, d, f) 求解二元一次方程组 ax+by=e, cx+dy=f
  eq2d(a, b, c)         求解一元二次方程 ax²+bx+c=0，支持实根和复根
  eq3(a, b, c, d)       求解一元三次方程 ax³+bx²+cx+d=0，支持实根和复根
  eq4(a, b, c, d, e)    求解一元四次方程 ax⁴+bx³+cx²+dx+e=0，支持实根和复根

==== 几何 — 直线 ====

  line_ps(k, x1, y1)               点斜式求一次函数解析式 y = kx + b
  line_2p(x1, y1, x2, y2)          两点式求一次函数解析式
  dist(x1, y1, x2, y2)             两点间距离
  pbisec(x1, y1, x2, y2)           两点间线段的垂直平分线方程
  rotate(x1, y1, x2, y2, angle)    点 P(x1,y1) 绕点 Q(x2,y2) 旋转 angle 度后的 P' 坐标
  lines(A1, B1, C1, A2, B2, C2)    判断两直线 Ax+By+C=0 的位置关系（重合/平行/相交）
  lsym(A1, B1, C1, A2, B2, C2)     直线 l₁ 关于 l₂ 的对称直线，及相反方向

==== 几何 — 点与直线 ====

  pld(x, y, A, B, C)                点到直线的距离，及点关于直线的对称点坐标
  plsl(x, y, A, B, C)               直线关于点的对称直线方程

==== 几何 — 二次函数 ====

  quad_v(x1, y1, x2, y2)           已知顶点 (x1,y1) 和另一点 (x2,y2)，求二次函数解析式
  quad_3p(x1, y1, x2, y2, x3, y3)  已知三个点（不共线），求二次函数解析式

==== 几何 — 圆 ====

  circle_r(h, k, r)                 已知圆心 (h,k) 和半径 r，求圆的标准方程和一般方程
  circle_c2p(h, k, x1, y1, x2, y2)  已知圆心和圆上两点，求圆方程
  circle_3p(x1, y1, x2, y2, x3, y3) 已知圆上三点，求圆方程
  circles(x1, y1, r1, x2, y2, r2)   已知两圆标准参数，判断位置关系（外离/内含/外切/内切/相交）
  circles_g(D1, E1, F1, D2, E2, F2) 已知两圆一般方程 x²+y²+Dx+Ey+F=0，判断位置关系

==== 几何 — 三角形 ====

  tri_sss(a, b, c)                   已知三边长，求三角形面积（海伦公式）
  tri_area(x1, y1, x2, y2, x3, y3)   已知三顶点坐标，求三角形面积
  tri_center(x1, y1, x2, y2, x3, y3) 已知三顶点坐标，求四心坐标（重心/内心/外心/垂心）
  tri_cr(a, b, c)                    已知三边长，求内切圆半径和外接圆半径
  tri_crp(x1, y1, x2, y2, x3, y3)    已知三顶点坐标，求内切圆半径和外接圆半径

==== 几何 — 正多边形 ====

  poly(n, a)              已知边数 n 和边长 a，计算正 n 边形面积

==== 行列式 ====

  det(a11, a12, ..., ann)   计算 n×n 行列式的值，参数个数需为完全平方数（如 4, 9, 16, ...），支持任意阶方阵递归展开

==== 随机数 ====

  rand()                          返回 0~1 之间的随机浮点数
  rand(max)                       返回 1~max 之间的随机整数
  rand(min, max)                  返回 min~max 之间的随机整数
  randn(digits, count, unique)    批量生成指定位数的随机数，digits: 位数（1~18），count: 数量，unique: 0=不重复 非0=可重复，结果以逗号分隔
  randn(min, max, count, unique)  批量生成指定范围的随机数，unique: 0=不重复 非0=可重复

==== 数论 ====

  pytha(m)               输入一条边 m，求勾股数；奇数 m≥3，偶数 m≥4
  pytha(a, b)            输入两条边 a、b，求第三边组成勾股数
  pfact(n)               质因数分解，输出格式如 2²×3×7
  primes(n)              找出 2~n 之间的所有质数（n≤26338）

==== 进制转换 ====

  base(number, toBase)             将十进制数字转换为 toBase 进制（2~36，支持小数）
  base(number, fromBase, toBase)   将 fromBase 进制的数字转换为 toBase 进制，参数需加引号如 base('1A', 16, 2)

==== 单位换算 ====

  unit(value, 'from', 'to')    将 value 从 from 单位换算为 to 单位，参数需加引号

  支持的单位代码：

    长度：
      ai    埃 1e-10 m        nm    纳米 1e-9 m        wm    微米 1e-6 m
      mm    毫米 0.001 m      cm    厘米 0.01 m        dm    分米 0.1 m
      m     米 1              km    千米 1000 m        li    里 500 m
      yc    英寸 0.0254 m     ft    英尺 0.3048 m      mile  英里 1609.344 m
      nmi   海里 1852 m       zhang 丈 10/3 m          chi   尺 1/3 m
      cun   寸 1/30 m         fen   分 1/300 m

    面积：
      mm2   平方毫米 1e-6 m²       cm2   平方厘米 1e-4 m²      dm2   平方分米 0.01 m²
      m2    平方米 1 m²            km2   平方千米 1e6 m²       pfyl  平方英里 2589988.1103 m²
      hm2   公顷 10000 m²          sq    亩 200000/3 m²        acre  英亩 4046.8648 m²
      sm    市亩 2000/3 m²         gm    公亩 100 m²

    体积：
      wl    微升 1e-9 m³      mm3   立方毫米 1e-9 m³     ml    毫升 1e-6 m³
      cm3   立方厘米 1e-6 m³  cl    厘升 1e-5 m³         dl    分升 1e-4 m³
      l     升 0.001 m³       dm3   立方分米 0.001 m³    hl    百升 0.1 m³
      m3    立方米 1 m³       ygl   英加仑 0.0045461 m³  mgl   美加仑 0.00378541 m³
      km3   立方千米 1e9 m³

    质量：
      wg    微克 1e-6 g       mg    毫克 0.001 g        g     克 1 g
      kg    千克 1000 g       t     吨 1e6 g            lb    磅 453.59237 g
      oz    盎司 28.34952 g   ct    克拉 0.2 g          gd    公担 1e5 g
      sd    市担 50000 g      jin   斤 500 g            liang 两 50 g
      qian  钱 5 g            dr    打兰 1.771845 g     gr    格令 0.06479891 g

==== 链式计算 ====

  在数字提交模式下，可直接用运算符连接多个计算：

    输入 84 → 按 + → 看到候选窗出现 84+ → 输入 5 → 得出 89
    继续输入 *2 → 使用上次结果 89 作为左操作数 → 得出 178
    继续输入 /4 → 使用结果 178 → 得出 44.5

  V 模式下也支持：
    V84+5  → 89
    V89*2  → 178（前一次计算结果不自动继承，除非使用链式）

  链式状态通过静态变量维护，随每次结果更新。

==== 其他说明 ====

  - 支持函数嵌套运算，如 Vsin(deg(80))、Vsqrt(1+3*5)
  - 所有三角函数参数为弧度制，可使用 deg()/rad() 进行与角度的互换
  - 表达式中可直接引用全局常量，如 Vsin(pi/2) → 1
  - 除数不能为零，计算器会返回相应错误提示
  - 返回结果自动去除尾部多余零，如 4.0 显示为 4
  - 大数或极小数的单位换算结果以科学计数法上标形式显示

==============================================================================
--]]

local S = safe_require("key_style") -- 按键样式

return keyboard(merge(S.offset, keyboard {
  name = "计算器",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { label = { { text = "avg" } }, click = "Avg", label_symbol = { { text = "sum" } }, popup = { "Sqsum", "Cbsum", "Qpsum", "Osqsum", "Esqsum", "Ocbsum", "Ecbsum", "Oqpsum", "Eqpsum", "Arithsum", "Geosum" } },
        key { label = { { text = "null" } } },
        key { label = { { text = "sin" } }, click = "Sin", label_symbol = { { text = "asin" } }, popup = { "Asin" } },
        key { label = { { text = "cos" } }, click = "Cos", label_symbol = { { text = "acos" } }, popup = { "Acos" } },
        key { label = { { text = "tan" } }, click = "Tan", label_symbol = { { text = "atan" } }, popup = { "Atan", "Atan2" } },
        key(merge(S.backspace, key { label = { { text = "返回" } }, click = "KeyboardDefault" })),
        key { spacer = true, width = 0.02 }
      }
    },
    row {
      keys = {
        key { spacer = true, width = 0.02 },
        key { label = { { text = "log" } }, click = "Log", label_symbol = { { text = "ldexp" } }, popup = { "Ldexp" } },
        key { label = { { text = "ln" } }, click = "Loge", label_symbol = { { text = "exp" } }, popup = { "Exp" } },

      }
    }
  }
}))
