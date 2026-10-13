---
name: lyraime-theme
description: LyraIME/Trime 键盘主题 Lua DSL 的中文参考与检查清单。编写或调试主题文件（如 theme.lua、NekoCatppuccin.lua）、preset_keyboards 键盘布局、preset_keys 预设按键、配色方案（preset_color_schemes）、液态键盘、侧栏布局时使用。字段级权威细节以 doc/theme-dsl.lua 为准。
---

<!-- @format -->

# LyraIME 键盘主题 DSL

中文导航与检查清单，覆盖 `themes/` 目录下的主题工作流。

## 权威参考（先读这里）

字段级细节（类型、默认值、回退链、完整字段表）全部以中文注释写在：

- **`doc/theme-dsl.lua`** —— 唯一权威的 DSL 类型/字段文档（约 1775 行）。
  使用前先 Read 该文件获取完整字段定义，不要在正文里臆造字段名。
- **`.luarc.json`** —— LuaLS 配置。`workspace.library: ["doc"]` 让 `doc/theme-dsl.lua`
  自动提供补全与悬停；`diagnostics.globals` 列出了全部 16 个沙箱注入的全局函数。

## 工作流

```text
主题文件 (theme.lua) → Lua 5.5 沙箱执行 → JSON 序列化 → Kotlin Theme 数据类
```

- 主题文件顶层必须调用 `theme { ... }` 并以 `return theme` 结尾。
- 模型代码：`app/src/main/java/com/osfans/trime/data/theme/model/`
- 沙箱代码：`app/src/main/jni/lua_theme_jni/lua_sandbox.cc`

## 目录结构

```text
themes/
├── *.lua                # 主题根文件（如 NekoCatppuccin.lua）
├── lib/                 # 可递归搜索的 Lua 模块（safe_require("nekocat.xxx")）
├── fonts/               # 自定义字体
├── backgrounds/         # 背景图片
├── build/               # 缓存 JSON 输出
└── doc/theme-dsl.lua    # 权威 DSL 文档（本技能引用）
```

## 全局 DSL 函数速查

| 函数                  | 用途                                                                     |
| --------------------- | ------------------------------------------------------------------------ |
| `theme(t)`            | 声明根主题表（顶层必须调用，返回 Theme）                                 |
| `style(t)`            | 声明全局样式 GeneralStyle                                                |
| `keyboard(t)`         | 声明键盘布局 TextKeyboard                                                |
| `row(t)`              | 声明键盘行 KeyboardRow                                                   |
| `key(t)`              | 声明按键 TextKey                                                         |
| `preedit(t)`          | 声明预编辑区样式 Preedit                                                 |
| `window(t)`           | 声明候选窗口样式 Window                                                  |
| `toolbar(t)`          | 声明工具栏 ToolBar                                                       |
| `btn(t)`              | 声明工具栏按钮 ToolBarButton                                             |
| `bg(t)`               | 声明按钮背景 ToolBarButtonBackground                                     |
| `fg(t)`               | 声明按钮前景 ToolBarButtonForeground                                     |
| `liquid(t)`           | 声明液态键盘 LiquidKeyboard                                              |
| `fallback(t)`         | 声明回退颜色映射（顶层字段名为 `fallback_colors`）                       |
| `scheme(id, t)`       | 声明配色方案（返回 `{ id, colors }`）                                    |
| `pk(id, t)`           | 声明预设按键（id 当前不嵌入返回值，按键靠 preset_keys 键名查找）         |
| `merge(a, b)`         | 深度合并两表；同键均表则递归合并，否则 b 覆盖 a                          |
| `insert(t, pos, val)` | 数组表指定位置插入（1-索引），返回新表                                   |
| `safe_require(name)`  | 沙箱模块加载（等价 require，搜索 lib/ 及其子目录 `?.lua`、`?/init.lua`） |

## 根主题 Theme

```lua
return theme {
  name = "主题名",                  -- 必填
  version = "1.0",                  -- 必填
  author = "作者",
  style = style { ... },            -- 必填（GeneralStyle）
  fallback_colors = { ... },
  preset_color_schemes = {          -- 必填（ColorScheme[]）
    scheme("light", { ... }),
  },
  preedit = preedit { ... },
  window = window { ... },
  tool_bar = toolbar { ... },
  candidates_tool = { ... },        -- nil 时隐藏候选工具栏
  liquid_keyboard = liquid { ... },
  preset_keys = { Space = pk("space", { ... }), ... },
  preset_keyboards = { default = keyboard { ... } },  -- 必填（ID → TextKeyboard）
}
```

## 配色方案

- `scheme(id, colors)` 返回 `{ id = id, colors = colors }`。
- `SchemeColors` 中 `text_color`、`back_color` 必须定义；其余字段可省略并按回退链解析。
- 高频回退链：`candidate_text_color → text_color`；`hilited_candidate_* → hilited_*`；
  `key_* → candidate_*/text_color`；`key_back_color → back_color`；
  `key_border_color → border_color`。
- `light_scheme` / `dark_scheme` 记录模式切换跳转目标；`name` 用于配色选择弹窗显示。
- 顶层 `fallback_colors` 提供额外的回退映射
  （如 `{ candidate_text_color = "text_color" }`），逐键回退映射可直接用
  `nekocat.colors._key_colors` 导出的 `fallback_colors`。
- 支持按键独立配色：`<key_id>_key_back_color`、
  `<key_id>_hilited_key_text_color` 等（key_id 见 `KeyColorStyles`，
  共 74 键 × 7 字段）。若使用此类逐键配色键值，
  必须先引用 `nekocat.colors._key_colors` 模块并配置 `fallback_colors`，见下节。
- 逐键配色回退链与生成器见下节「按键独立配色生成器」。
- 具体字段与回退链请 Read `doc/theme-dsl.lua` 中 `SchemeColors` 类注释。

## 按键独立配色生成器（lib/nekocat/colors/\_key_colors.lua）

为 63 个按键生成逐键配色引用，四级回退链：
`{key_id}_{field} → {row_group}_{field} → {func}_{field} → {field}`

> **前置条件（必须同时满足）**：若配色方案使用了逐键配色键值（`{key_id}_{field}`，
> 如 `a_key_back_color`、`num_row_key_back_color`），必须：
>
> 1. 引用该模块：`local S = safe_require("nekocat.colors._key_colors")`
> 2. 为主题根表配置回退映射：`fallback_colors = S.fallback_colors`
>    （或等效的完整回退映射，见 `M.fallback_colors`）
>
> 原因：逐键样式表中的颜色字段是键名字符串（如 `"num0_key_back_color"`），
> 需由主题引擎运行时经 `fallback_colors` 逐级回退解析为实际色值；
> 未配置则该键名无法解析，逐键配色不生效。

| key_id 组                                                                             | 回退分组           |
| ------------------------------------------------------------------------------------- | ------------------ |
| `q w e r t y u i o p`                                                                 | `top_row`          |
| `a s d f g h j k l`                                                                   | `home_row`         |
| `z x c v b n m`                                                                       | `bottom_row`       |
| `num0 ~ num9`                                                                         | `num_row`          |
| `kp0 ~ kp9`                                                                           | `mainkey`          |
| `shift/backspace/num/delete/comma/period/slash`                                       | `func`             |
| `semicolon/ctrl/alt/enter/switch/tab/capslock/escape/clear/up/down/left/right/lookup` | `func`             |
| `func/space/行分组(num_row/top_row/home_row/bottom_row/mainkey)`                      | 直接回退全局 field |

模块导出（返回 `M`，位于 `lib/nekocat/colors/_key_colors.lua`）：

- `M` —— 预建样式表，直接包含 63 个 `key()` 片段，无需 scheme_colors 即可用：

  ```lua
  local S = safe_require("nekocat.colors._key_colors")
  key(merge(S.a,     { click = "a", label = "a" })),
  key(merge(S.shift, { click = "Shift_L" })),
  key(merge(S.num0,  { click = "0", label = "0" })),
  -- 无独立配色的键（如 c）同样返回 key{}，回退全局色
  ```

- `M.make_letter_key_styles(scheme_colors)` —— 传入配色 colors 表，
  返回逐键精确覆盖样式表（与 `KeyColorStyles` 形状一致）。
  未显式定义 `{key_id}_{field}` 时按 `{row_group}_{field} → {field}` 解析。
- `M.fallback_colors` —— 构建好的回退映射表，可直接赋给主题根表 `fallback_colors`
  （如 `num0_key_back_color → num_row_key_back_color → key_back_color`；
  `shift_key_back_color → func_key_back_color → key_back_color`）。
- `M.build_fallback_colors` —— 重建该映射表的函数。

配色方案中按此约定定义行分组/逐键颜色：

```lua
scheme("my", {
  key_back_color         = "0x1e1e2e",
  a_key_back_color       = "0xFF0000",   -- 逐键覆盖（可选）
  num_row_key_back_color = "0x00FF00",   -- 行分组覆盖
  func_key_back_color    = "0x0000FF",   -- 功能键分组覆盖
})
```

## 预设按键 preset_keys + pk

```lua
preset_keys = {
  Shift = pk("Shift", {
    label = "⇧", command = "FUNCTION", select = ".default",
    shift_lock = "long",
  }),
  Space = pk("space", { label = " ", send = "space" }),
}
```

要点：

- `command`（Command 枚举）：
  `liquid_keyboard / menu_keyboard / clipboard_window / set_color_scheme` /
  `set_theme / set_schema / broadcast / clipboard / commit / date / run` /
  `apply / share_text / select_candidate / sidebar_clear / dynamic_clear`，
  参数放 `option`。
- `select`（Select 枚举）：
  `".default" / ".prior" / ".next" / ".last"` /
  `".previous" / ".last_lock" / ".ascii"` 或 preset_keyboards 中的自定义 ID。
- `send` 中可用 `"Control+x"` 等组合（经 parseSend 解析），但 click 等字段不能使用。
- 行为字段（KeyBehaviorKey）：
  `composing / has_menu / paging / combo / ascii / click / double_click` /
  `lazy_double_click / swipe_up / long_click / swipe_down / swipe_left` /
  `swipe_right / extra`，可在 PresetKey 与 TextKey 上配置。
- `states = {off_label, on_label}` 用于开关按键双态；`sticky` 为粘滞键。

## 键盘布局 keyboard > row > key

```lua
keyboard {
  name = "26键",
  ascii_mode = false,
  rows = {
    row { keys = { key { click = "q", label = { { text = "Q" } } } } },
  },
}
```

要点：

- `TextKey`：`width`（行内比例）、`spacer`（占位）、
  `click`、`label`（LabelSpec 分段）、`label_symbol`（右上角副标签）、
  `hint`（底部提示）、`popup`（弹窗键列表）、
  `key_text_color / key_back_color` 及 `hilited_*` 系列、
  各方向圆角 `round_corner_*`、
  行为字段（`composing / combo / long_click / swipe_*` 等）、`dynamic`（动态键盘关联键名）。
- `label` 支持三种格式：分段数组、单值样式、并行数组（text/color/scale/align/valign）。
  `text` 前缀 `"ic@"` 为图标（如 `"ic@arrow-left"`），`"\n"` 为换行。
- `KeyboardRow`：`height`（0=自动）、`split`（横屏分割行）、`keys`。
- `TextKeyboard` 可独立覆写 `keyboard_height / horizontal_gap / round_corner` /
  `key_border / key_text_offset_* / sidebar_*` 等；
  `sidebar_mode + sidebar_layout` 启用侧栏；
  `dynamic_mode + dynamic_original` 启用动态键盘。
- 复用与变体：
  - `keyboard(merge(base_kb, { ascii_mode = true }))` 基于基础布局改字段
  - 嵌套覆盖：
    `merge(base, { rows = { [3] = { keys = { [2] = { long_click = "x" } } } } })`
  - `insert(base.rows, pos, row { ... })` /
    `insert(base.rows[i].keys, pos, key { ... })`

## 颜色格式

字符串。支持 `0xAARRGGBB`、`0xRRGGBB`、`#AARRGGBB`、`#RRGGBB`、颜色名（如 `"red"`）、
或图片文件路径（如 `"background.png"`）。

## 常用枚举

- `CommentPosition`：`RIGHT / TOP / OVERLAY`
- `LabelTransform`：`NONE / UPPERCASE`
- `ShiftLock`：`long / click / ascii_long`
- `KeyBarPosition`：`TOP / LEFT / BOTTOM / RIGHT / NAVBAR`
- `LiquidKeyboardType`：`SINGLE / SYMBOL / TABS / HISTORY / VAR_LENGTH`
- `SidebarLayout`：`t9 / 14 / 18`，可加 `_zrm`（自然码）、`_flypy`（小鹤）
- `Align`：`left / center / right / justify`；`VerticalAlign`：
  `top / center / bottom / justify`

## 检查清单

1. 顶层为 `return theme { ... }`，
   且 `name / style / preset_color_schemes / preset_keyboards` 齐备。
2. 每个引用的 `safe_require("nekocat.xxx")` 模块在 `lib/` 下存在。
3. 字段名严格 snake_case，与 `doc/theme-dsl.lua` 类注释一致（勿自造字段）。
4. `click` 等字段不用 `Control+x` 格式；`send` 字段才可解析组合键。
5. 按键独立配色键名符合 `<key_id>_<field>` 命名。
6. 使用逐键配色键值（`{key_id}_{field}`）时，确认已 `safe_require("nekocat.colors._key_colors")`
   且主题根表配置了 `fallback_colors`。
7. 回退链字段只在必要时显式定义，其余靠回退，避免冗余。
8. 修改后按部署流程让主题在设备上重载，再核对渲染效果。

## 注意

- 沙箱中 `require` 已被置 nil，必须用 `safe_require`。
- `merge` / `insert` 均为纯函数，不修改原表。
- 本技能正文为速查；遇到未覆盖的字段或行为，务必回到 `doc/theme-dsl.lua` 查原文。
