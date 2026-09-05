--@amzxyz https://github.com/amzxyz/rime-wanxiang


local wanxiang       = require('wanxiang')

local utf8_codepoint = utf8.codepoint
local utf8_len       = utf8.len
local utf8_sub       = utf8.sub
local insert         = table.insert
local concat         = table.concat

local upper_map      = {
  ['A'] = 'Ⓐ',
  ['B'] = 'Ⓑ',
  ['C'] = 'Ⓒ',
  ['D'] = 'Ⓓ',
  ['E'] = 'Ⓔ',
  ['F'] = 'Ⓕ',
  ['G'] = 'Ⓖ',
  ['H'] = 'Ⓗ',
  ['I'] = 'Ⓘ',
  ['J'] = 'Ⓙ',
  ['K'] = 'Ⓚ',
  ['L'] = 'Ⓛ',
  ['M'] = 'Ⓜ',
  ['N'] = 'Ⓝ',
  ['O'] = 'Ⓞ',
  ['P'] = 'Ⓟ',
  ['Q'] = 'Ⓠ',
  ['R'] = 'Ⓡ',
  ['S'] = 'Ⓢ',
  ['T'] = 'Ⓣ',
  ['U'] = 'Ⓤ',
  ['V'] = 'Ⓥ',
  ['W'] = 'Ⓦ',
  ['X'] = 'Ⓧ',
  ['Y'] = 'Ⓨ',
  ['Z'] = 'Ⓩ',
}

-- ----------------------
-- 部件组字返回的注释
-- ----------------------
local function get_charset_label(text)
  if not text or text == "" then return nil end
  local cp = utf8_codepoint(text)
  if not cp then return nil end

  -- 按照 Unicode 区块频率排序
  if cp >= 0x4E00 and cp <= 0x9FFF then return "基本" end
  if cp >= 0x3400 and cp <= 0x4DBF then return "扩A" end
  if cp >= 0x20000 and cp <= 0x2A6DF then return "扩B" end
  if cp >= 0x2A700 and cp <= 0x2B73F then return "扩C" end
  if cp >= 0x2B740 and cp <= 0x2B81F then return "扩D" end
  if cp >= 0x2B820 and cp <= 0x2CEAF then return "扩E" end
  if cp >= 0x2CEB0 and cp <= 0x2EBEF then return "扩F" end
  if cp >= 0x2EBF0 and cp <= 0x2EE5F then return "扩I" end
  if cp >= 0x30000 and cp <= 0x3134F then return "扩G" end
  if cp >= 0x31350 and cp <= 0x323AF then return "扩H" end

  -- 兼容区
  if cp >= 0xF900 and cp <= 0xFAFF then return "兼容" end
  if cp >= 0x2F800 and cp <= 0x2FA1F then return "兼容" end

  return nil
end

local function get_az_comment(cand, env, initial_comment)
  local inner_parts = {}

  -- 音形注释拆解逻辑
  if initial_comment and initial_comment ~= "" then
    local segments = {}
    for segment in string.gmatch(initial_comment, "[^%s]+") do
      table.insert(segments, segment)
    end

    if #segments > 0 then
      local pinyins = {}
      local aux_code = nil

      for _, segment in ipairs(segments) do
        local pinyin = string.match(segment, "^[^;~]+")
        local aux = string.match(segment, ";(.+)$")

        if pinyin then
          table.insert(pinyins, wanxiang.tone_number_to_mark(pinyin))
        end
        if not aux_code and aux and aux ~= "" then aux_code = aux end
      end

      if #pinyins > 0 then
        local pinyin_str = table.concat(pinyins, ",")
        table.insert(inner_parts, string.format("音%s", pinyin_str))

        if aux_code then
          table.insert(inner_parts, string.format("辅%s", aux_code))
        end
      end
    end
  end

  if cand and cand.text then
    local label = get_charset_label(cand.text)
    if label then
      table.insert(inner_parts, label)
    end
  end

  if #inner_parts == 0 then
    return "〔无〕"
  end
  -- 使用间隔号连接
  return "〔" .. table.concat(inner_parts, "・") .. "〕"
end
-- ----------------------
-- # 辅助码提示或带调全拼注释模块 (Fuzhu)
-- ----------------------
local function get_aux_comment(cand, env, initial_comment)
  local length = utf8_len(cand.text)
  if length > env.settings.candidate_length then
    return ""
  end
  local auto_delimiter = env.settings.auto_delimiter or " "
  local segments = {}
  for segment in string.gmatch(initial_comment, env.settings.aux_seg_pattern) do
    table.insert(segments, segment)
  end

  -- 根据 option 动态决定是否强制使用 tone
  local is_tone = env.engine.context:get_option("tone_hint")
  local is_toneless = env.engine.context:get_option("toneless_hint") and not is_tone
  local aux_type = (is_tone or is_toneless) and "tone" or "aux"

  local first_segment = segments[1] or ""
  local _, semicolon_count = first_segment:gsub(";", "")
  local aux_comments = {}
  -- 没有分号的情况
  if semicolon_count == 0 then
    return initial_comment:gsub(auto_delimiter, " ")
  else
    -- 有分号：按类型提取
    for _, segment in ipairs(segments) do
      if aux_type == "tone" then
        -- 取第一个分号“前”的内容
        local before = segment:match("^(.-);")
        if before and before ~= "" then
          if is_toneless then
            table.insert(aux_comments, wanxiang.tone_number_to_plain(before))
          else
            table.insert(aux_comments, wanxiang.tone_number_to_mark(before))
          end
        end
      else -- "aux"
        -- 统一格式：pinyin;aux（单分号），取分号后内容
        local after = segment:match(";(.+)$")
        if after and after ~= "" then
          after = after:gsub(",", "/")
          table.insert(aux_comments, after)
        end
      end
    end
  end

  -- aux用 `,`，tone用 /连接
  if #aux_comments > 0 then
    return table.concat(aux_comments, ", ")
  else
    return ""
  end
end

-- 对 cand.preedit 应用 tone_preedit/0..9 的映射（数字 -> 上标等）
-- 对 cand.preedit 应用转换：数字转上标，且隐藏双大写辅助码
local function apply_tone_preedit(env, cand)
  if not cand or not cand.preedit or cand.preedit == "" then
    return
  end

  local engine = env.engine
  local ctx = engine and engine.context
  local input = ctx and ctx.input or ""
  local is_t9_key = input:match("^%d") ~= nil

  -- 如果是九键场景，或者包含连续数字（如电脑小键盘），直接跳过不转换
  if is_t9_key or input:match("%d%d") then return end

  -- 判断首选是否为纯英文（通过匹配是否全由英文字符组成且不含中文）
  if cand.text:match("^[%a%p%s]+$") then
    return
  end

  do
    local preedit = cand.preedit
    local converted = preedit:gsub("()([A-Z][A-Z]+)", function(pos, upper)
      if pos <= 3 then return upper end
      if preedit:sub(1, pos - 1):match("[A-Z]") then return upper end
      return "›"
    end)
    cand.preedit = converted
  end
  -- 数字映射逻辑 (上标转换)
  if not env.tone_map then
    env.tone_map = {
      ['6'] = '①',
      ['7'] = '②',
      ['8'] = '③',
      ['9'] = '④',
      ['0'] = '⑤',
    }
  end

  local final_pre = cand.preedit:gsub("([^%d%s]+)(%d+)", function(body, digits)
    local mapped = digits:gsub("%d", function(d)
      return env.tone_map[d] or d
    end)
    return body .. mapped
  end)

  final_pre = final_pre:gsub("[A-Z]", function(u)
    return upper_map[u] or u
  end)

  cand.preedit = final_pre
end

-- ----------------------
-- 主函数：根据优先级处理候选词的注释和preedit
-- ----------------------
local ZH = {}
function ZH.init(env)
  local config = env.engine.schema.config
  local delimiter = config:get_string('speller/delimiter') or " '"
  local auto_delimiter = delimiter:sub(1, 1)
  local manual_delimiter = delimiter:sub(2, 2)
  env.settings = {
    delimiter = delimiter,
    auto_delimiter = auto_delimiter,
    manual_delimiter = manual_delimiter,
    candidate_length = tonumber(config:get_string("super_comment/candidate_length")) or 1,
    visual_delim = config:get_string("speller/visual_delimiter") or " ",
    tone_isolate = config:get_bool("speller/tone_isolate"),
    aux_seg_pattern = "[^" .. auto_delimiter .. "]+",
    py_seg_pattern = "[^" .. auto_delimiter .. manual_delimiter .. "]+",
  }
end

function ZH.fini(env)
end

function ZH.func(input, env)
  local context = env.engine.context
  local input_str = context.input or ""
  local is_t9_key = input_str:match("^%d") ~= nil
  local is_radical_mode = wanxiang.is_in_radical_mode(env)
  local should_skip_candidate_comment = wanxiang.is_function_mode_active(context) or input_str == ""
  local is_tone_comment = context:get_option("tone_hint")
  local is_toneless_comment = context:get_option("toneless_hint")
  local is_comment_hint = context:get_option("aux_hint")
  --preedit相关声明
  local auto_delimiter = env.settings.auto_delimiter
  local manual_delimiter = env.settings.manual_delimiter
  local visual_delim = env.settings.visual_delim
  local tone_isolate = env.settings.tone_isolate
  local is_tone_display = context:get_option("tone_display")
  local is_full_pinyin = context:get_option("full_pinyin")

  local cached_input_parts = nil
  local last_preedit = nil

  for cand in input:iter() do
    local genuine_cand = cand:get_genuine()
    if genuine_cand.type == "datetime" then
      yield(genuine_cand)
      goto continue
    end
    local preedit = genuine_cand.preedit or ""
    local initial_comment = genuine_cand.comment
    local final_comment = initial_comment

    -- preedit相关处理只跳过 preedit，不影响注释
    if is_radical_mode then
      goto after_preedit
    end
    if not is_tone_display and not is_full_pinyin then
      goto after_preedit
    end
    if (not initial_comment or initial_comment == "") then
      goto after_preedit
    end
    do
      -- 拆分逻辑 — 相同的 preedit 只拆分一次
      local input_parts
      if preedit == last_preedit then
        input_parts = cached_input_parts
      else
        input_parts = {}
        local buf, bn = {}, 0
        for char in preedit:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
          if char == auto_delimiter or char == manual_delimiter then
            if bn > 0 then
              insert(input_parts, concat(buf, "", 1, bn))
              bn = 0
            end
            insert(input_parts, char)
          else
            bn = bn + 1
            buf[bn] = char
          end
        end
        if bn > 0 then
          insert(input_parts, concat(buf, "", 1, bn))
        end
        cached_input_parts = input_parts
        last_preedit = preedit
      end

      -- 拆分拼音段（comment）
      local pinyin_segments = {}
      for segment in string.gmatch(initial_comment, env.settings.py_seg_pattern) do
        local pinyin = segment:match("^[^;]+")
        if pinyin then
          pinyin = pinyin:gsub("[%[%]]", "") --去掉英文词库编码中的[]
          pinyin = is_full_pinyin and wanxiang.tone_number_to_plain(pinyin) or wanxiang.tone_number_to_mark(pinyin)
          insert(pinyin_segments, pinyin)
        end
      end

      -- 替换逻辑
      local pinyin_index = 1
      for i, part in ipairs(input_parts) do
        if part == auto_delimiter or part == manual_delimiter then
          input_parts[i] = visual_delim
        else
          local py = pinyin_segments[pinyin_index]

          if py then
            if is_t9_key then
              -- 场景 A：九宫格 (T9) 数字输入逻辑
              local py_first_char = utf8_sub(py, 1, 1)
              local part_tail = utf8_sub(part, 2)
              part = py_first_char .. part_tail

              if i == #input_parts and #part == 1 then
                local prefix = utf8_sub(py, 1, 2)
                local first_char = part:sub(1, 1):lower()
                if first_char == "s" or first_char == "c" or first_char == "z" then
                  input_parts[i] = part
                else
                  if prefix == "zh" or prefix == "ch" or prefix == "sh" then
                    input_parts[i] = prefix
                  else
                    input_parts[i] = part
                  end
                end
              else
                local upper_tail = part:match("([A-Z]+)$") or ""
                input_parts[i] = py .. upper_tail
                pinyin_index = pinyin_index + 1
              end
            else
              -- 场景 B：常规 26键 字母输入逻辑

              if i == #input_parts and #part == 1 then
                local prefix = utf8_sub(py, 1, 2)
                local first_char = part:sub(1, 1):lower()
                if first_char == "s" or first_char == "c" or first_char == "z" then
                  input_parts[i] = part
                else
                  if prefix == "zh" or prefix == "ch" or prefix == "sh" then
                    input_parts[i] = prefix
                  else
                    input_parts[i] = part
                  end
                end
              else
                local upper_tail_tone = part:match("([A-Z0-9]+)$") or ""
                input_parts[i] = py .. upper_tail_tone
                pinyin_index = pinyin_index + 1
              end
            end
          end
        end
      end

      genuine_cand.preedit = table.concat(input_parts)
    end
    ::after_preedit::
    if should_skip_candidate_comment then
      yield(genuine_cand)
      goto continue
    end
    apply_tone_preedit(env, genuine_cand)
    -- 进入注释处理阶段
    -- ① 辅助码注释或者声调注释
    if initial_comment and (string.find(initial_comment, "~") or string.find(initial_comment, "\226\152\175") or cand.type == "datetime") then
      final_comment = initial_comment

      -- 2. 常规的辅助码提示模式
    elseif is_comment_hint then
      local aux_comment = get_aux_comment(cand, env, initial_comment)
      if aux_comment then
        final_comment = aux_comment
      end

      -- 3. 常规的带调拼音模式
    elseif is_tone_comment then
      local aux_comment = get_aux_comment(cand, env, initial_comment)
      if aux_comment then
        final_comment = aux_comment
      end

      -- 4. 常规的无调拼音模式
    elseif is_toneless_comment then
      local aux_comment = get_aux_comment(cand, env, initial_comment)
      if aux_comment then
        final_comment = aux_comment
      end

      -- 5. 其他情况一律清空注释
    else
      final_comment = ""
    end

    -- ② 反查模式提示
    if is_radical_mode then
      local az_comment = get_az_comment(cand, env, initial_comment)
      if az_comment and az_comment ~= "" then
        final_comment = az_comment
      end
    end

    -- 应用注释
    if final_comment ~= initial_comment then
      genuine_cand.comment = final_comment
    end

    if cand.type ~= genuine_cand.type then
      local nc = Candidate(cand.type, cand.start, cand._end, genuine_cand.text, genuine_cand.comment)
      nc.preedit = genuine_cand.preedit
      nc.quality = cand.quality
      yield(nc)
    else
      yield(genuine_cand)
    end
    ::continue::
  end
end

return ZH
