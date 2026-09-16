local function calc_func(name, label)
  local lbl = label or name
  if #lbl < 5 then lbl = lbl .. string.rep(" ", 5 - #lbl) end
  return { popup_label = lbl, text = name .. "(){Left}" }
end

-- ========================================================================
-- 预设按键 (PresetKey)
-- 按键行为定义，键盘布局中引用键名
-- ========================================================================

---@type { [string]: PresetKey }
local pk = {
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
  Space              = { label = "ic@keyboard-space", send = "space" },
  Down               = { label = "ic@arrow-down-bold", repeatable = true, send = "Down" },
  Left               = { label = "ic@arrow-left-bold", repeatable = true, send = "Left" },
  Right              = { label = "ic@arrow-right-bold", repeatable = true, send = "Right" },
  Up                 = { label = "ic@arrow-up-bold", repeatable = true, send = "Up" },
  Clear              = { label = "ic@close-octagon-outline", send = "Escape" },                     -- 清空输入
  SidebarClear       = { label = "ic@close-octagon-outline", command = "sidebar_clear" },           -- 侧边栏布局专用清空
  DynamicClear       = { label = "ic@close-octagon-outline", command = "dynamic_clear" },           -- 动态布局专用清空
  SlideCursor        = { slide_cursor = true },                                                     -- 软光标
  AltLeft            = { label = "ic@arrow-left-bold-outline", repeatable = true, send = "Up" },    -- 上一个候选
  AltRight           = { label = "ic@arrow-right-bold-outline", repeatable = true, send = "Down" }, -- 下一个候选

  -- App 功能
  VoiceAssist        = { label = "ic@microphone", send = "VOICE_ASSIST" },                                                                         -- 语音识别
  HideKeyboard       = { label = "ic@keyboard-close", send = "BACK" },                                                                             -- 收起键盘
  ThemeReload        = { label = "ic@cookie-refresh-outline", command = "set_theme", option = "$reload" },                                         -- 刷新主题
  Deploy             = { label = "ic@archive-refresh-outline", command = "apply", option = "DEPLOY" },                                             -- 重新部署方案
  Sync               = { label = "ic@sync", command = "apply", option = "SYNC_USER_DATA" },                                                        -- 同步用户数据
  Restart            = { label = "ic@restart", command = "apply", option = "RESTART_RIME" },                                                       -- 重启 Rime
  Settings           = { label = "ic@cog-outline", send = "SETTINGS" },                                                                            -- 设置
  SchemeList         = { label = "ic@list-box-outline", send = "MENU" },                                                                           -- 方案列表
  ThemeList          = { label = "ic@palette-swatch-outline", send = "SETTINGS", option = "theme" },                                               -- 主题列表
  ColorList          = { label = "ic@palette-outline", send = "PROG_RED" },                                                                        -- 配色列表
  KeyboardList       = { label = "ic@keyboard", send = "PROG_GREEN" },                                                                             -- 布局列表
  IMESwitch          = { label = "ic@web", send = "LANGUAGE_SWITCH" },                                                                             -- 输入法切换
  OpenLogcat         = { label = "ic@information-outline", command = "run", option = "com.carlson.lyraime/com.osfans.trime.ui.main.LogActivity" }, -- LogCat
  ZiTools            = { label = "ic@ideogram-cjk", command = "run", option = "https://zi.tools/zi/%1$s" },                                        -- 字统网查字

  -- 编辑键
  SelectAll          = { label = "ic@select-all", send = "Control+a" },    -- 全选
  Cut                = { label = "ic@content-cut", send = "Control+x" },   -- 剪切
  Copy               = { label = "ic@content-copy", send = "Control+c" },  -- 复制
  Paste              = { label = "ic@content-paste", send = "Control+v" }, -- 粘贴
  Undo               = { label = "ic@rotate-left", send = "Control+z" },   -- 撤销
  Redo               = { label = "ic@rotate-right", send = "Control+y" },  -- 重做

  -- 状态切换
  FloatingSwitch     = { toggle = "_floating_keyboard", send = "SWITCH_CHARSET", states = { "停靠模式", "悬浮模式" } }, -- 悬浮键盘切换
  ModeSwitch         = { toggle = "ascii_mode", send = "SWITCH_CHARSET", states = { "\u{F830}", "\u{F831}" } }, -- ASCII 模式切换
  OneHandSwitch      = { toggle = "_one_hand_mode", send = "SWITCH_CHARSET", states = { "标准键盘", "单手键盘" } }, -- 单手键盘切换
  VoiceSwitch        = { toggle = "_voice_assist", send = "SWITCH_CHARSET", states = { "开始识别", "停止识别" } }, -- 工具栏语音识别
  HintSwitch         = { toggle = "_hide_key_hint", send = "SWITCH_CHARSET", states = { "显示助记", "隐藏助记" } }, -- j键盘助记

  -- 键盘切换
  KeyboardDefault    = { label = "ic@keyboard", send = "Eisu_toggle", select = ".default" },             -- 默认键盘
  KeyboardPrior      = { label = "ic@page-previous", send = "Eisu_toggle", select = ".prior" },          -- 上一个键盘
  KeyboardNext       = { label = "ic@page-next", send = "Eisu_toggle", select = ".next" },               -- 下一个键盘
  KeyboardCalculator = { label = "ic@calculator-variant", send = "Eisu_toggle", select = "calculator" }, -- 计算器键盘
  KeyboardEditor     = { label = "ic@square-edit-outline", send = "Eisu_toggle", select = "editor" },    -- 编辑键盘
  KeyboardNumber     = { label = "ic@numeric", send = "Eisu_toggle", select = "number" },                -- 数字键盘
  KeyboardSettings   = { label = "ic@cogs", send = "Eisu_toggle", select = "settings" },                 -- 设置键盘
  KeyboardLayouts    = { label = "ic@keyboard-variant", send = "Eisu_toggle", select = "layouts" },      -- 布局界面
  Keyboard45Eng      = { label = "\u{F840}", send = "Eisu_toggle", select = "english" },                 -- 英文布局
  KeyboardT9Number   = { label = "ic@numeric", send = "Eisu_toggle", select = "t9_number" },             -- T9 用数字
  Keyboardzrm        = { label = "\u{F842}", send = "Eisu_toggle", select = "wanxiang_zrm" },            -- 自然码布局
  Keyboardzrm18keys  = { label = "\u{F844}", send = "Eisu_toggle", select = "wanxiang_zrm_18keys" },     -- 自然码 18 键
  Keyboardzrm14keys  = { label = "\u{F846}", send = "Eisu_toggle", select = "wanxiang_zrm_14keys" },     -- 自然码 14 键
  Keyboardl17keys    = { label = "\u{F845}", send = "Eisu_toggle", select = "wanxiang_l17keys" },        -- 乱序 17

  -- 方案切换
  SchemaEnglish      = { label = "\u{F840}", command = "set_schema", option = "wanxiang_english" },      -- 万象英文
  Schemaflypy        = { label = "\u{F842}", command = "set_schema", option = "wanxiang_flypy" },        -- 万象小鹤
  Schemaflypy18keys  = { label = "\u{F844}", command = "set_schema", option = "wanxiang_flypy_18keys" }, -- 万象小鹤 18 键
  Schemaflypy14keys  = { label = "\u{F846}", command = "set_schema", option = "wanxiang_flypy_14keys" }, -- 万象小鹤 14 键
  Schemal17keys      = { label = "\u{F845}", command = "set_schema", option = "wanxiang_l17keys" },      -- 万象乱序 17
  Schemayoemin       = { label = "\u{F847}", command = "set_schema", option = "wanxiang_yoemin" },       -- 鸢鸣万象
  Schemalssp         = { label = "\u{F847}", command = "set_schema", option = "triple_pinyin_lssp" },    -- 李氏三拼
  Schema9keys        = { label = "\u{F849}", command = "set_schema", option = "wanxiang_t9" },           -- 万象 9 键

  -- 窗口切换
  WindowMenu         = { label = "ic@tune-variant", command = "menu_keyboard" },              -- 方案开关页面
  WindowClipboard    = { label = "ic@clipboard-list-outline", command = "clipboard_window" }, -- 剪贴板

  -- 流体键盘
  LiquidHistory      = { label = "ic@symbol", command = "liquid_keyboard", option = "history" },    -- 符号历史记录
  LiquidEmoji        = { label = "ic@cat", command = "liquid_keyboard", option = "emoji_smileys" }, -- emoji 符号

  -- Rime 方案相关
  CandDelete         = { label = "ic@delete-forever", send = "Control+Delete" }, -- 删除选中候选
  CandLeft           = { label = "ic@pan-left", send = "Control+j" }, -- 万象提前选中候选位置
  CandRight          = { label = "ic@pan-right", send = "Control+k" }, -- 万象推后选中候选位置
  CandReset          = { label = "ic@lock-reset", send = "Control+l" }, -- 万象重置选中候选位置
  CandTop            = { label = "ic@pin", send = "Control+p" }, -- 万象置顶选中候选
  ReverseLookup      = { label = "ic@magnify", text = "`" }, -- 万象反查
  AddDict            = { label = "ic@pen-plus", text = "``" }, -- 万象造词
  CandPin            = { label = "ic@pin", send = "Control+t" }, -- 魔然置顶/取消置顶选中候选
  CandUp             = { label = "ic@pan-up", send = "Control+equal" }, -- 魔然上移选中的 pin 候选
  CandDown           = { label = "ic@pan-down", send = "Control+plus" }, -- 魔然下移选中的 pin 候选
  Calculator         = { label = "ic@calculator-variant", actions = { "KeyboardCalculator", "V" } }, -- 计算器
  CommitPreedit      = { label = "ic@marker", send = "Control+Return" }, -- 上屏 Preedit
  SelectCandOne      = { label = "〡", send = "1" }, -- 选择第一个候选
  SelectCandTwo      = { label = "〢", send = "2" }, -- 选择第二个候选
  SelectCandThree    = { label = "〣", send = "3" }, -- 选择第三个候选
  SelectCandFour     = { label = "〤", send = "4" }, -- 选择第四个候选
  SelectCandFive     = { label = "〥", send = "5" }, -- 选择第五个候选
  SelectToneOne      = { label = "\u{F821}", send = "6" }, -- 音调一声
  SelectToneTwo      = { label = "\u{F822}", send = "7" }, -- 音调二声
  SelectToneThree    = { label = "\u{F823}", send = "8" }, -- 音调三声
  SelectToneFour     = { label = "\u{F824}", send = "9" }, -- 音调四声
  SelectToneNull     = { label = "\u{F825}", send = "0" }, -- 音调无声
  Semicolon          = { label = "ic@numeric-2-box-outline", send = ";" }, -- 分号用于次选

  -- 计算器函数

  -- ==== ASCII 处理 ====
  Slash              = { label = "/", commit = "/" }, -- 除号
  Period             = { label = ".", commit = "." }, -- 句号
  Colon              = { label = ":", commit = ":" }, -- 冒号
  ParenCommit        = { commit = "()" }, -- 括号
  Paren              = { label = "( )", actions = { "ParenCommit", "Left" } }, -- 括号
  BracketCommit      = { commit = "[]" }, -- 中括号
  Bracket            = { label = "[ ]", actions = { "BracketCommit", "Left" } }, -- 中括号
  Formula            = { label = "算式", actions = { "End", "space" } }, -- 输出算式

  -- ==== 基础数学 ====
  Sin                = calc_func("sin"),   -- 正弦
  Cos                = calc_func("cos"),   -- 余弦
  Tan                = calc_func("tan"),   -- 正切
  Asin               = calc_func("asin"),  -- 反正弦
  Acos               = calc_func("acos"),  -- 反余弦
  Atan               = calc_func("atan"),  -- 反正切
  Atan2              = calc_func("atan2"), -- 点(x,y)角度
  Deg                = calc_func("deg"),   -- 弧度→角度
  Rad                = calc_func("rad"),   -- 角度→弧度
  Exp                = calc_func("exp"),   -- e^x
  Ldexp              = calc_func("ldexp"), -- x·2^y
  Log                = calc_func("log"),   -- 对数(底x)
  Loge               = calc_func("loge"),  -- 自然对数
  Sqrt               = calc_func("sqrt"),  -- 平方根
  Nroot              = calc_func("nroot"), -- 开n次方
  Ceil               = calc_func("ceil"),  -- 向上取整
  Floor              = calc_func("floor"), -- 向下取整

  -- ==== 组合与数论 ====
  Fact               = calc_func("fact"), -- 阶乘
  Mod                = calc_func("mod"),  -- 取余

  -- ==== 数列 ====
  Arithsum           = calc_func("arith_sum", "aris"), -- 等差数列前n项和
  Geosum             = calc_func("geo_sum", "geos"),   -- 等比数列前n项和

  -- ==== 统计 ====
  Avg                = calc_func("avg"), -- 平均数
  Var                = calc_func("var"), -- 方差

  -- ==== 工具 ====
  Rand               = calc_func("rand"), -- 随机数
  Base               = calc_func("base"), -- 进制转换
  Unit               = calc_func("unit")  -- 单位换算
}

return pk
