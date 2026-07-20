---@type { [string]: PresetKey }
return {
  -- 功能键
  Escape       = { label = "ic@keyboard-esc", send = "Escape" },
  Home         = { label = "ic@arrow-collapse-left", send = "Home" },
  End          = { label = "ic@arrow-collapse-right", send = "End" },
  Page_Up      = { label = "ic@page-first", send = "Page_Up" },
  Page_Down    = { label = "ic@page-last", send = "Page_Down" },
  Delete       = { label = "ic@delete-forever", send = "Delete" },
  BackSpace    = { label = "ic@backspace-outline", repeatable = true, send = "BackSpace" },
  Tab          = { label = "ic@keyboard-tab", repeatable = true, send = "Tab" },
  Enter        = { label = "ic@keyboard-return", send = "Return" },
  Shift        = { label = "ic@apple-keyboard-shift", functional = true, send = "Shift_L", shift_lock = "long" },
  CapsLock     = { label = "ic@apple-keyboard-caaps", functional = true, send = "Shift_L", shift_lock = "click" },
  Ctrl         = { label = "ic@apple-keyboard-command", send = "Control_L" },
  Alt          = { label = "ic@apple-keyboard-option", send = "Alt_L" },
  Space        = { label = "ic@keyboard-space", slide_cursor = true, send = "space" },
  Down         = { label = "ic@arrow-down-bold", repeatable = true, send = "Down" },
  Left         = { label = "ic@arrow-left-bold", repeatable = true, send = "Left" },
  Right        = { label = "ic@arrow-right-bold", repeatable = true, send = "Right" },
  Up           = { label = "ic@arrow-up-bold", repeatable = true, send = "Up" },

  -- App 功能
  VoiceAssist  = { label = "ic@microphone", send = "VOICE_ASSIST" },                                 -- 语音识别
  HideKeyboard = { label = "ic@keyboard-close", send = "BACK" },                                     -- 收起键盘
  ThemeReload  = { label = "ic@cookie-refresh-outline", command = "set_theme", option = "$reload" }, -- 刷新主题


  -- 编辑键
  SelectAll         = { label = "ic@select-all", send = "Control+a" },    -- 全选
  Cut               = { label = "ic@content-cut", send = "Control+x" },   -- 剪切
  Copy              = { label = "ic@content-copy", send = "Control+c" },  -- 复制
  Paste             = { label = "ic@content-paste", send = "Control+v" }, -- 粘贴

  -- 状态切换
  FloatingSwitch    = { toggle = "_floating_keyboard", send = "Mode_switch", states = { "停靠模式", "悬浮模式" } }, -- 悬浮键盘切换
  ModeSwitch        = { toggle = "ascii_mode", send = "Mode_switch", states = { "\u{F830}", "\u{F831}" } }, -- ASCII 模式切换
  OneHandSwitch     = { toggle = "_one_hand_mode", send = "Mode_switch", states = { "标准键盘", "单手键盘" } }, -- 单手键盘切换
  VoiceSwitch       = { toggle = "_voice_assist", send = "Mode_switch", states = { "开始识别", "停止识别" } }, -- 工具栏语音识别

  -- 键盘切换
  KeyboardMenu      = { label = "ic@apps", command = "menu_keyboard" },                                -- 菜单页面
  KeyboardClipboard = { label = "ic@clipboard-list-outline", command = "clipboard_window" },           -- 剪贴板
  KeyboardDefault   = { label = "ic@keyboard", send = "Eisu_toggle", select = ".default" },            -- 默认键盘
  KeyboardPrior     = { label = "ic@page-previous", send = "Eisu_toggle", select = ".prior" },         -- 上一个键盘
  KeyboardNext      = { label = "ic@page-next", send = "Eisu_toggle", select = ".next" },              -- 下一个键盘
  KeyboardCalculate = { label = "ic@calculator-variant", send = "Eisu_toggle", select = "calculate" }, -- 计算器键盘

  -- Rime 方案相关
  CandDelete        = { label = "ic@delete-forever", send = "Control+Delete" },                   -- 删除选中候选
  CandLeft          = { label = "ic@pan-left", send = "Control+j" },                              -- 提前选中候选位置
  CandRight         = { label = "ic@pan-right", send = "Control+k" },                             -- 推后选中候选位置
  CandReset         = { label = "ic@lock-reset", send = "Control+l" },                            -- 重置选中候选位置
  CandTop           = { label = "ic@pin", send = "Control+p" },                                   -- 置顶选中候选
  ReverseLookup     = { label = "ic@magnify", text = "`" },                                       -- 反查
  AddDict           = { label = "ic@pen-plus", text = "``" },                                     -- 造词
  Calculator        = { label = "ic@calculator-variant", actions = { "KeyboardCalculate", "V" } } -- 计算器
}
