---@type KeyColorStyles
local S = safe_require("nekocat.colors._key_colors")

local keyboard = keyboard {
  name = "编辑键盘",
  author = "Carlson24(鹤衔春雪)",
  ascii_mode = false,
  label_transform = "NONE",
  lock = false,
  rows = {
    row {
      keys = {
        key { label = { { text = "行首" } }, click = "Home" },
        key { label = { { text = "复制" } }, click = "Copy" },
        key { label = { { text = "全选" } }, click = "SelectAll" },
        key { label = { { text = "剪切" } }, click = "Cut" },
        key { label = { { text = "行尾" } }, click = "End" }
      }
    },
    row {
      keys = {
        key { label = { { text = "上页" } }, click = "Page_Up" },
        key { label = { { text = "粘贴" } }, click = "Paste" },
        key(merge(S.func, { click = "Up" })),
        key { label = { { text = "剪贴" } }, click = "WindowClipboard" },
        key { label = { { text = "下页" } }, click = "Page_Down" }
      }
    },
    row {
      keys = {
        key { label = { { text = "符号" } }, click = "LiquidHistory" },
        key(merge(S.func, { click = "Left" })),
        key { label = { { text = "ic@select-compare" } }, click = "Shift" },
        key(merge(S.func, { click = "Right" })),
        key { label = { { text = "退格" } }, click = "BackSpace" }
      }
    },
    row {
      keys = {
        key { label = { { text = "表情" } }, click = "LiquidEmoji" },
        key { label = { { text = "撤销" } }, click = "Undo" },
        key(merge(S.func, { click = "Down" })),
        key { label = { { text = "重做" } }, click = "Redo" },
        key { label = { { text = "删除" } }, click = "Delete" }

      }
    },
    row {
      keys = {
        key(merge(S.num, { label = { { text = "返回" } }, click = "KeyboardDefault" })),
        key { label = { { text = "数字" } }, click = "KeyboardNumber" },
        key { click = "Space" },
        key { label = { { text = "计算" } }, click = "KeyboardCalculator" },
        key(merge(S.enter, { label = { { text = "回车" } }, click = "Enter", key_text_size = 18 }))
      }
    },
    safe_require("nekocat.layouts._action_row")({}).extra
  }
}

return keyboard
