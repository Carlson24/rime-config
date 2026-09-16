---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")

local settings = key {
  key_text_size = 42,
  symbol_text_size = 11,
  key_border_color = "0x00",
  key_back_color = "0x00"
}

local keyboard = keyboard {
  name = "设置与导航",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  navbar = true,
  rows = {
    row {
      height = 0.3,
      keys = {
        key { spacer = true, width = 0.1 },
        key(merge(settings, key { click = "SchemeList", hint = { { text = "方案" } } })),
        key(merge(settings, key { click = "ThemeList", hint = { { text = "主题" } } })),
        key(merge(settings, key { click = "ColorList", hint = { { text = "配色" } } })),
        key(merge(settings, key { click = "WindowMenu", hint = { { text = "开关" } } })),
        key(merge(settings, key { click = "Settings", hint = { { text = "设置" } } })),
        key { spacer = true, width = 0.1 }
      }
    },
    row {
      height = 0.3,
      keys = {
        key { spacer = true, width = 0.1 },
        key(merge(settings, key { click = "Deploy", hint = { { text = "部署" } } })),
        key(merge(settings, key { click = "Sync", hint = { { text = "同步" } } })),
        key(merge(settings, key { click = "ThemeReload", hint = { { text = "刷新" } } })),
        key(merge(settings, key { click = "Restart", hint = { { text = "重启" } } })),
        key(merge(settings, key { click = "OpenLogcat", hint = { { text = "日志" } } })),
        key { spacer = true, width = 0.1 }
      }
    },
    row {
      height = 0.3,
      keys = {
        key { spacer = true, width = 0.1 },
        key(merge(settings, key { click = "Schemaflypy", hint = { { text = "小鹤" } } })),
        key(merge(settings, key { click = "Schemaflypy18keys", hint = { { text = "小鹤18键" } } })),
        key(merge(settings, key { click = "Schemaflypy14keys", hint = { { text = "小鹤14键" } } })),
        key(merge(settings, key { click = "Schemayoemin", hint = { { text = "鸢鸣万象" } } })),
        key(merge(settings, key { click = "Schema9keys", hint = { { text = "T9" } } })),
        key { spacer = true, width = 0.1 }
      }
    }
  }
}

return keyboard
