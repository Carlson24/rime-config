---@type { [string]: PresetKey }
return {
  -- 功能键
  Escape             = { label = "ic@keyboard-esc", send = "Escape" },
  Home               = { label = "ic@arrow-collapse-left", send = "Home" },
  End                = { label = "ic@arrow-collapse-right", send = "End" },
  Page_Up            = { label = "ic@page-first", send = "Page_Up" },
  Page_Down          = { label = "ic@page-last", send = "Page_Down" },
  Delete             = { label = "ic@delete-forever", send = "Delete" },
  BackSpace          = { label = "ic@backspace-outline", repeatable = true, send = "BackSpace" },
  Tab                = { label = "ic@keyboard-tab", repeatable = true, send = "Tab" },
  Enter              = { label = "ic@keyboard-return", send = "Return" },
  Shift              = { label = "ic@apple-keyboard-shift", functional = true, send = "Shift_L", shift_lock = "long" },
  CapsLock           = { label = "ic@apple-keyboard-caps", functional = true, send = "Shift_L", shift_lock = "click" },
  Ctrl               = { label = "ic@apple-keyboard-command", send = "Control_L" },
  Alt                = { label = "ic@apple-keyboard-option", send = "Alt_L" },
  Space              = { label = "ic@keyboard-space", slide_cursor = true, send = "space" },
  Down               = { label = "ic@arrow-down-bold", repeatable = true, send = "Down" },
  Left               = { label = "ic@arrow-left-bold", repeatable = true, send = "Left" },
  Right              = { label = "ic@arrow-right-bold", repeatable = true, send = "Right" },
  Up                 = { label = "ic@arrow-up-bold", repeatable = true, send = "Up" },

  -- App 功能
  VoiceAssist        = { label = "ic@microphone", send = "VOICE_ASSIST" },                                 -- 语音识别
  HideKeyboard       = { label = "ic@keyboard-close", send = "BACK" },                                     -- 收起键盘
  ThemeReload        = { label = "ic@cookie-refresh-outline", command = "set_theme", option = "$reload" }, -- 刷新主题
  ZiTools            = { label = "ic@magnify", command = "run", option = "https://zi.tools/zi/%1$s" },     -- 字统网查字
  Deploy             = { label = "ic@archive-refresh-outline", command = "apply", option = "DEPLOY" },     -- 重新部署方案
  SchemeList         = { label = "ic@list-box-outline", send = "Menu" },                                   -- 方案列表
  IMESwitch          = { label = "ic@web", send = "LANGUAGE_SWITCH" },                                     -- 输入法切换
  ThemeSwitch        = { label = "ic@palette-swatch-outline", send = "SETTINGS", option = "theme" },       -- 主题列表

  -- 编辑键
  SelectAll          = { label = "ic@select-all", send = "Control+a" },    -- 全选
  Cut                = { label = "ic@content-cut", send = "Control+x" },   -- 剪切
  Copy               = { label = "ic@content-copy", send = "Control+c" },  -- 复制
  Paste              = { label = "ic@content-paste", send = "Control+v" }, -- 粘贴

  -- 状态切换
  FloatingSwitch     = { toggle = "_floating_keyboard", send = "Mode_switch", states = { "停靠模式", "悬浮模式" } }, -- 悬浮键盘切换
  ModeSwitch         = { toggle = "ascii_mode", send = "Mode_switch", states = { "\u{F830}", "\u{F831}" } }, -- ASCII 模式切换
  OneHandSwitch      = { toggle = "_one_hand_mode", send = "Mode_switch", states = { "标准键盘", "单手键盘" } }, -- 单手键盘切换
  VoiceSwitch        = { toggle = "_voice_assist", send = "Mode_switch", states = { "开始识别", "停止识别" } }, -- 工具栏语音识别
  HintSwitch         = { toggle = "_hide_key_hint", send = "Mode_switch", states = { "显示助记", "隐藏助记" } }, -- j键盘助记

  -- 键盘切换
  KeyboardMenu       = { label = "ic@apps", command = "menu_keyboard" },                                 -- 菜单页面
  KeyboardClipboard  = { label = "ic@clipboard-list-outline", command = "clipboard_window" },            -- 剪贴板
  KeyboardDefault    = { label = "ic@keyboard", send = "Eisu_toggle", select = ".default" },             -- 默认键盘
  KeyboardPrior      = { label = "ic@page-previous", send = "Eisu_toggle", select = ".prior" },          -- 上一个键盘
  KeyboardNext       = { label = "ic@page-next", send = "Eisu_toggle", select = ".next" },               -- 下一个键盘
  KeyboardCalculator = { label = "ic@calculator-variant", send = "Eisu_toggle", select = "calculator" }, -- 计算器键盘
  KeyboardEdit       = { label = "ic@square-edit-outline", send = "Eisu_toggle", select = "edit" },      -- 编辑键盘
  KeyboardNumber     = { label = "ic@numeric", send = "Eisu_toggle", select = "number" },                -- 数字键盘
  KeyboardSettings   = { label = "ic@cogs", send = "Eisu_toggle", select = "settings" },                 -- 设置键盘

  -- Rime 方案相关
  CandDelete         = { label = "ic@delete-forever", send = "Control+Delete" },                     -- 删除选中候选
  CandLeft           = { label = "ic@pan-left", send = "Control+j" },                                -- 提前选中候选位置
  CandRight          = { label = "ic@pan-right", send = "Control+k" },                               -- 推后选中候选位置
  CandReset          = { label = "ic@lock-reset", send = "Control+l" },                              -- 重置选中候选位置
  CandTop            = { label = "ic@pin", send = "Control+p" },                                     -- 置顶选中候选
  ReverseLookup      = { label = "ic@magnify", text = "`" },                                         -- 反查
  AddDict            = { label = "ic@pen-plus", text = "``" },                                       -- 造词
  Calculator         = { label = "ic@calculator-variant", actions = { "KeyboardCalculator", "V" } }, -- 计算器

  -- 计算器函数
  -- ==== 基础数学 ====
  Sin                = { popup_label = "sin  ", text = "sin(){Left}" },   -- 正弦
  Cos                = { popup_label = "cos  ", text = "cos(){Left}" },   -- 余弦
  Tan                = { popup_label = "tan  ", text = "tan(){Left}" },   -- 正切
  Asin               = { popup_label = "asin ", text = "asin(){Left}" },  -- 反正弦
  Acos               = { popup_label = "acos ", text = "acos(){Left}" },  -- 反余弦
  Atan               = { popup_label = "atan ", text = "atan(){Left}" },  -- 反正切
  Atan2              = { popup_label = "atan2", text = "atan2(){Left}" }, -- 点(x,y)角度
  Sinh               = { popup_label = "sinh ", text = "sinh(){Left}" },  -- 双曲正弦
  Cosh               = { popup_label = "cosh ", text = "cosh(){Left}" },  -- 双曲余弦
  Tanh               = { popup_label = "tanh ", text = "tanh(){Left}" },  -- 双曲正切
  Deg                = { popup_label = "deg  ", text = "deg(){Left}" },   -- 弧度→角度
  Rad                = { popup_label = "rad  ", text = "rad(){Left}" },   -- 角度→弧度
  Exp                = { popup_label = "exp  ", text = "exp(){Left}" },   -- e^x
  Ldexp              = { popup_label = "ldexp", text = "ldexp(){Left}" }, -- x·2^y
  Log                = { popup_label = "log  ", text = "log(){Left}" },   -- 对数(底x)
  Loge               = { popup_label = "loge ", text = "loge(){Left}" },  -- 自然对数
  Logt               = { popup_label = "logt ", text = "logt(){Left}" },  -- 常用对数
  Sqrt               = { popup_label = "sqrt ", text = "sqrt(){Left}" },  -- 平方根
  Csqrt              = { popup_label = "csqrt", text = "csqrt(){Left}" }, -- 复数平方根
  Nroot              = { popup_label = "nroot", text = "nroot(){Left}" }, -- 开n次方
  Ceil               = { popup_label = "ceil ", text = "ceil(){Left}" },  -- 向上取整
  Floor              = { popup_label = "floor", text = "floor(){Left}" }, -- 向下取整

  -- ==== 幂方求和 ====
  Sqsum              = { popup_label = "sqs  ", text = "sqsum(){Left}" },  -- 自然数平方和
  Cbsum              = { popup_label = "cbs  ", text = "cbsum(){Left}" },  -- 自然数立方和
  Qpsum              = { popup_label = "qps  ", text = "qpsum(){Left}" },  -- 自然数四次方和
  Osqsum             = { popup_label = "osqs ", text = "osqsum(){Left}" }, -- 奇数平方和
  Esqsum             = { popup_label = "esqs ", text = "esqsum(){Left}" }, -- 偶数平方和
  Ocbsum             = { popup_label = "ocbs ", text = "ocbsum(){Left}" }, -- 奇数立方和
  Ecbsum             = { popup_label = "ecbs ", text = "ecbsum(){Left}" }, -- 偶数立方和
  Oqpsum             = { popup_label = "oqps ", text = "oqpsum(){Left}" }, -- 奇数四次方和
  Eqpsum             = { popup_label = "eqps ", text = "eqpsum(){Left}" }, -- 偶数四次方和

  -- ==== 组合与数论 ====
  Fact               = { popup_label = "fact ", text = "fact(){Left}" }, -- 阶乘
  Perm               = { popup_label = "perm ", text = "perm(){Left}" }, -- 排列数
  Comb               = { popup_label = "comb ", text = "comb(){Left}" }, -- 组合数
  Gcd                = { popup_label = "gcd  ", text = "gcd(){Left}" },  -- 最大公因数
  Lcm                = { popup_label = "lcm  ", text = "lcm(){Left}" },  -- 最小公倍数
  Mod                = { popup_label = "mod  ", text = "mod(){Left}" },  -- 取余

  -- ==== 数列 ====
  Arithsum           = { popup_label = "aris ", text = "arith_sum(){Left}" }, -- 等差数列前n项和
  Geosum             = { popup_label = "geos ", text = "geo_sum(){Left}" },   -- 等比数列前n项和
  Seq                = { popup_label = "seq  ", text = "seq(){Left}" },       -- 数列通项公式

  -- ==== 统计 ====
  Avg                = { popup_label = "avg  ", text = "avg(){Left}" }, -- 平均数
  Var                = { popup_label = "var  ", text = "var(){Left}" }, -- 方差

  -- ==== 方程求解 ====
  Eq1                = { popup_label = "eq1  ", text = "eq1(){Left}" },  -- 一元一次方程
  Eq2                = { popup_label = "eq2  ", text = "eq2(){Left}" },  -- 二元一次方程组
  Eq2D               = { popup_label = "eq2d ", text = "eq2d(){Left}" }, -- 一元二次方程
  Eq3                = { popup_label = "eq3  ", text = "eq3(){Left}" },  -- 一元三次方程
  Eq4                = { popup_label = "eq4  ", text = "eq4(){Left}" },  -- 一元四次方程

  -- ==== 几何 — 直线 ====
  LinePS             = { popup_label = "lnps ", text = "line_ps(){Left}" }, -- 点斜式求直线
  Line2P             = { popup_label = "ln2p ", text = "line_2p(){Left}" }, -- 两点式求直线
  Dist               = { popup_label = "dist ", text = "dist(){Left}" },    -- 两点间距离
  Pbisec             = { popup_label = "pbis ", text = "pbisec(){Left}" },  -- 垂直平分线
  Rotate             = { popup_label = "rotat", text = "rotate(){Left}" },  -- 点绕点旋转
  Lines              = { popup_label = "lines", text = "lines(){Left}" },   -- 两直线位置关系
  Lsym               = { popup_label = "lsym ", text = "lsym(){Left}" },    -- 直线对称

  -- ==== 几何 — 点与直线 ====
  Pld                = { popup_label = "pld  ", text = "pld(){Left}" },  -- 点到直线距离/对称
  Plsl               = { popup_label = "plsl ", text = "plsl(){Left}" }, -- 线关于点对称

  -- ==== 几何 — 二次函数 ====
  QuadV              = { popup_label = "qdv  ", text = "quad_v(){Left}" },  -- 顶点式求二次函数
  Quad3P             = { popup_label = "qd3p ", text = "quad_3p(){Left}" }, -- 三点求二次函数

  -- ==== 几何 — 圆 ====
  CircleR            = { popup_label = "ccr  ", text = "circle_r(){Left}" },   -- 圆心半径求圆
  CircleC2P          = { popup_label = "cc2p ", text = "circle_c2p(){Left}" }, -- 圆心两点求圆
  Circle3P           = { popup_label = "c3p  ", text = "circle_3p(){Left}" },  -- 三点求圆
  Circles            = { popup_label = "circ  ", text = "circles(){Left}" },   -- 两圆关系(标准)
  CirclesG           = { popup_label = "cclg ", text = "circles_g(){Left}" },  -- 两圆关系(一般)

  -- ==== 几何 — 三角形 ====
  TriSSS             = { popup_label = "tsss ", text = "tri_sss(){Left}" },    -- 三边求面积
  TriArea            = { popup_label = "trar ", text = "tri_area(){Left}" },   -- 顶点求面积
  TriCenter          = { popup_label = "tcen ", text = "tri_center(){Left}" }, -- 四心坐标
  TriCR              = { popup_label = "tcr  ", text = "tri_cr(){Left}" },     -- 内外半径(边长)
  TriCRP             = { popup_label = "tcrp ", text = "tri_crp(){Left}" },    -- 内外半径(顶点)

  -- ==== 几何 — 正多边形 ====
  Poly               = { popup_label = "poly ", text = "poly(){Left}" }, -- 正n边形面积

  -- ==== 行列式 ====
  Det                = { popup_label = "det  ", text = "det(){Left}" }, -- 行列式

  -- ==== 随机数 ====
  Rand               = { popup_label = "rand ", text = "rand(){Left}" },  -- 随机数
  RandN              = { popup_label = "randn", text = "randn(){Left}" }, -- 批量随机数

  -- ==== 数论 ====
  Pytha              = { popup_label = "pytha", text = "pytha(){Left}" },  -- 勾股数
  Pfact              = { popup_label = "pfact", text = "pfact(){Left}" },  -- 质因数分解
  Primes             = { popup_label = "prims", text = "primes(){Left}" }, -- 找质数

  -- ==== 工具 ====
  Base               = { popup_label = "base ", text = "base(){Left}" }, -- 进制转换
  Unit               = { popup_label = "unit ", text = "unit(){Left}" }, -- 单位换算
}
