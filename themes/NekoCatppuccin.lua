-- SPDX-FileCopyrightText: 2015 - 2026 Rime community
--
-- SPDX-License-Identifier: GPL-3.0-or-later

-- LyraIME 主题 NekoCatppuccin
-- 亮色模式：Catppuccin Latte  暗色模式：Catppuccin Mocha

local font_combo = {
  "MonaspaceXenon.ttf", "LXGWWenKaiMono.ttf",
  "OpenMoji.ttf", "CarlsonFont.ttf",
  "SourceHanSans.otf", "PlangothicP1.otf", "PlangothicP2.otf"
}

local lattescheme = safe_require("colors.latte")
local mochascheme = safe_require("colors.mocha")
local frappescheme = safe_require("colors.frappe")
local macchiatoscheme = safe_require("colors.macchiato")

local theme = theme {
  -- ========================================================================
  -- 元数据
  -- ========================================================================
  name = "NekoCatppuccin",
  version = "5.0",
  author = "Carlson24(鹤衔春雪)",

  -- ========================================================================
  -- 全局样式 (GeneralStyle)
  -- 每个属性后注释说明其类型和用途，可注释掉使用默认值
  -- ========================================================================
  style = style {
    -- 键盘
    keyboard_height = 250,      -- [int] 竖屏键盘高度 (px)
    keyboard_height_land = 150, -- [int] 横屏键盘高度 (px)
    horizontal_gap = 3,         -- [int] 键水平间距 (px)
    vertical_gap = 3,           -- [int] 键盘行距 (px)
    round_corner = 6,           -- [float] 按键圆角半径
    shadow_radius = 1.0,        -- [float] 按键阴影半径
    key_border = 1,             -- [int] 按键边框宽度
    keyboard_padding_left = 40,

    -- 键盘边距（竖屏）
    keyboard_padding = 2,        -- [int] 左右与屏幕的距离离
    keyboard_padding_bottom = 5, -- [int] 底部距离（避免触发全面屏手势）
    keyboard_padding_top = 3,    -- [int] 顶部距离

    -- 键盘边距（横屏）
    keyboard_padding_land = 40,       -- [int] 横屏左右距离
    keyboard_padding_land_bottom = 0, -- [int] 横屏底部距离

    -- 候选栏
    candidate_view_height = 35,         -- [int] 候选区高度
    candidate_padding = 4,              -- [int] 候选项内边距
    candidate_spacing = 1.0,            -- [float] 候选间距
    candidate_text_vertical_bias = 1.0, -- [float] 候选文本垂直偏移
    candidate_border = 0,               -- [int] 候选边框
    candidate_border_round = 0,         -- [float] 候选边框圆角
    candidate_corner_radius = 0,        -- [float] 候选项圆角半径

    -- 编码注释
    comment_height = 0,           -- [int] 编码提示区高度
    comment_vertical_bias = 0.0,  -- [float] 注释垂直偏移 (overlay 模式)
    comment_position = "OVERLAY", -- [CommentPosition] 位置: RIGHT | TOP | OVERLAY

    -- 悬浮提示
    popup_bottom_margin = 68, -- [int] 底部边距
    popup_width = 38,         -- [int] 宽度
    popup_height = 50,        -- [int] 高度
    popup_key_height = 52,    -- [int] 键高度

    -- 回车键文本
    enter_label_mode = 3, -- [int] ActionLabel 模式: 0=不使用 1=仅action 2=优先 3=fallback
    enter_labels = {      -- [EnterLabel] 回车键文本
      go = "ic@web",
      done = "ic@check",
      next = "ic@keyboard_return",
      pre = "ic@keyboard_return",
      search = "ic@magnify",
      send = "ic@keyboard_return",
      default = "ic@keyboard_return"
    },

    -- T9 侧栏
    t9_side_round_corner = -1, -- [float] T9 侧栏圆角 (-1 = 跟随 round_corner)

    -- 其他
    auto_caps = false,                        -- [bool] 自动句首大写
    -- background_folder = "backgrounds",     -- [string] 背景图存放子目录
    reset_ascii_mode_on_focus_change = false, -- [bool] 焦点变更时重置 ascii 模式

    -- 字体/字号
    fonts = {
      candidate = font_combo,
      candidate_size = 20,
      comment = font_combo,
      comment_size = 9,
      key = font_combo,
      key_size = 22,
      key_long_size = 16,
      label = font_combo,
      label_size = 22,
      latin = font_combo,
      symbol = font_combo,
      symbol_size = 10,
      text = font_combo,
      hint = font_combo,
      hint_size = 10,
      hanb = font_combo,
      popup = font_combo,
      popup_size = 20,
      t9_side = font_combo,
      t9_side_size = 6,
      clipboard = font_combo,
      clipboard_size = 13,
      clipboard_category = font_combo,
      clipboard_category_size = 14,
      -- 字体变体
      variations = { cpct = true },
      display = {
        ["，"] = "\u{FF0C}\u{FE01}",
        ["。"] = "\u{3002}\u{FE01}",
        ["？"] = "\u{FF1F}\u{FE01}",
        ["！"] = "\u{FF01}\u{FE01}",
        ["、"] = "\u{3001}\u{FE01}",
        ["："] = "\u{FF1A}\u{FE01}",
        ["；"] = "\u{FF1B}\u{FE01}"
      }
    }
  },

  -- ========================================================================
  -- 配色方案 (ColorScheme)
  -- 使用 Catppuccin 调色板：Latte (亮色) + Mocha (暗色)
  -- ========================================================================
  preset_color_schemes = {
    scheme("default", lattescheme),
    scheme("Catppuccin Latte", lattescheme), -- 默认浅色
    scheme("Catppuccin Mocha", mochascheme), -- 默认深色
    scheme("Catppuccin Frappe", frappescheme),
    scheme("Catppuccin Macchiato", macchiatoscheme)
  },

  -- ========================================================================
  -- 预编辑区 (Preedit)
  -- ========================================================================
  preedit = preedit {
    horizontal_padding = 8, -- [int] 横向内边距
    top_end_radius = 5,     -- [float] 上端圆角
    alpha = 0.8,            -- [float] 透明度 (0.0～1.0)
    foreground = {          -- [Foreground] 前景样式
      font_size = 16        -- [float] 字号
    }
  },

  -- ========================================================================
  -- 候选窗口 / 悬浮窗 (Window)
  -- ========================================================================
  window = window {
    insets = { vertical = 2, horizontal = 2 }, -- [Padding] 窗口内边距
    item_padding = { horizontal = 4 },         -- [Padding] 候选项内边距
    min_width = 0,                             -- [int] 最小宽度
    corner_radius = 5,                         -- [float] 窗口圆角
    border = 1,                                -- [int] 边框宽度
    shadow = 10,                               -- [float] 阴影半径
    alpha = 0.85,                              -- [float] 透明度 (0.0～1.0)
    foreground = {                             -- [Foreground] 前景样式
      label_font_size = 16,                    -- [float] 序号字号
      text_font_size = 18,                     -- [float] 文本字号
      comment_font_size = 12                   -- [float] 注释字号
    }
  },

  -- ========================================================================
  -- 候选工具栏 (CandidatesTool)
  -- ========================================================================
  candidates_tool = {
    -- 候选页面
    nav_width = 41,            -- [int] 侧边栏宽度
    button_font = font_combo,  -- [string[]] 侧边栏字体
    background = "back_color", -- [string] 侧边栏背景色
    buttons = {
      { action = "Up",               foreground = { style = "ic@arrow-up-bold", font_size = 12 } },
      { action = "Down",             foreground = { style = "ic@arrow-down-bold", font_size = 12 } },
      { action = "BackSpace",        foreground = { style = "ic@backspace-outline", font_size = 12 } },
      { action = "CommitScriptText", foreground = { style = "ic@keyboard-return", font_size = 12 } }
    },

    -- 候选词长按菜单
    popup_width = 60,                      -- [int] 长按菜单宽度
    popup_font = font_combo,               -- [string[]] 长按菜单字体
    popup_text_size = 18,                  -- [int] 长按菜单字号
    popup_text_color = "text_color",       -- [string] 长按菜单字体颜色
    popup_background_color = "back_color", -- [string] 长按菜单背景颜色
    popup = {
      { action = "CandLeft", label = "提前" },
      { action = "CandRight", label = "推后" },
      { action = "CandTop", label = "置顶" },
      { action = "CandReset", label = "重置" },
      { action = "CandDelete", label = "删除" }
    }
  },

  -- ========================================================================
  -- 工具栏 (ToolBar)
  -- ========================================================================
  tool_bar = toolbar {
    button_font = font_combo,
    back_style = "ic@chevron-triple-left",
    primary_button = {
      action = "KeyboardMenu",
      background = {
        type = "circle",
        corner_radius = 10,
        highlight = "hilited_candidate_button_color",
        normal = "none",
        vertical_inset = 4,
        horizontal_inset = 0
      },
      foreground = {
        font_size = 18,
        padding = 2,
        normal = "text_color",
        style = "ic@apps"
      }
    },
    buttons = {
      {
        action = "Hide",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@keyboard-close"
        }
      },
      {
        action = "VoiceSwitch",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          option_styles = { "ic@microphone", "ic@stop-circle" }
        }
      },
      {
        action = "KeyboardLiquidHistory",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@sticker-emoji"
        }
      },
      {
        action = "KeyboardClipboard",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@clipboard-list-outline"
        }
      },
      {
        action = "KeyboardEdit",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@cursor-move"
        }
      },
      {
        action = "Redo",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@rotate-right"
        }
      },
      {
        action = "Undo",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@rotate-left"
        }
      },
      {
        action = "FloatingKeyboardSwitch",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          option_styles = { "ic@dock-window", "ic@keyboard-outline" }
        }
      },
      {
        action = "KeyboardSettings",
        foreground = {
          font_size = 18,
          padding = 2,
          normal = "text_color",
          style = "ic@cogs"
        }
      }
    }
  },

  -- ========================================================================
  -- 预设按键 (PresetKey)
  -- 按键行为定义，键盘布局中引用键名
  -- ========================================================================
  preset_keys = safe_require("preset_keys"),

  preset_keyboards = {
    default    = safe_require("layouts.45keys"),
    calculator = safe_require("layouts.calculator")
  }
}

return theme
