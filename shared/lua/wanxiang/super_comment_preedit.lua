--@amzxyz https://github.com/amzxyz/rime-wanxiang


local wanxiang       = require("wanxiang")

local utf8_len       = utf8.len
local insert         = table.insert
local concat         = table.concat

local upper_map      = {
  ["A"] = "Ⓐ",
  ["B"] = "Ⓑ",
  ["C"] = "Ⓒ",
  ["D"] = "Ⓓ",
  ["E"] = "Ⓔ",
  ["F"] = "Ⓕ",
  ["G"] = "Ⓖ",
  ["H"] = "Ⓗ",
  ["I"] = "Ⓘ",
  ["J"] = "Ⓙ",
  ["K"] = "Ⓚ",
  ["L"] = "Ⓛ",
  ["M"] = "Ⓜ",
  ["N"] = "Ⓝ",
  ["O"] = "Ⓞ",
  ["P"] = "Ⓟ",
  ["Q"] = "Ⓠ",
  ["R"] = "Ⓡ",
  ["S"] = "Ⓢ",
  ["T"] = "Ⓣ",
  ["U"] = "Ⓤ",
  ["V"] = "Ⓥ",
  ["W"] = "Ⓦ",
  ["X"] = "Ⓧ",
  ["Y"] = "Ⓨ",
  ["Z"] = "Ⓩ"
}

-- ----------------------
-- # 辅助码提示注释模块 (Fuzhu)
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

  local first_segment = segments[1] or ""
  local _, semicolon_count = first_segment:gsub(";", "")
  local aux_comments = {}
  -- 没有分号的情况
  if semicolon_count == 0 then
    return initial_comment:gsub(auto_delimiter, " ")
  else
    -- 有分号：统一格式 pinyin;aux（单分号），取分号后辅助码
    for _, segment in ipairs(segments) do
      local after = segment:match(";(.+)$")
      if after and after ~= "" then
        after = after:gsub(",", "/")
        table.insert(aux_comments, after)
      end
    end
  end

  if #aux_comments > 0 then
    return table.concat(aux_comments, ", ")
  else
    return ""
  end
end

-- 对 cand.preedit 中的大写字母应用带圈字母映射
local function apply_upper_preedit(cand)
  if not cand or not cand.preedit or cand.preedit == "" then
    return
  end

  -- 判断首选是否为纯英文（通过匹配是否全由英文字符组成且不含中文）
  if cand.text:match("^[%a%p%s]+$") then
    return
  end

  cand.preedit = cand.preedit:gsub("[A-Z]", function(u)
    return upper_map[u] or u
  end)
end

-- ----------------------
-- 主函数：根据优先级处理候选词的注释和preedit
-- ----------------------
local ZH = {}
function ZH.init(env)
  local config = env.engine.schema.config
  local delimiter = config:get_string("speller/delimiter") or " '"
  local auto_delimiter = delimiter:sub(1, 1)
  env.settings = {
    delimiter = delimiter,
    auto_delimiter = auto_delimiter,
    candidate_length = tonumber(config:get_string("super_comment/candidate_length")) or 1,
    aux_seg_pattern = "[^" .. auto_delimiter .. "]+"
  }
end

function ZH.fini(env)
end

function ZH.func(input, env)
  local context = env.engine.context
  local input_str = context.input or ""
  local should_skip_candidate_comment = wanxiang.is_function_mode_active(context) or input_str == ""
  local is_comment_hint = context:get_option("aux_hint")

  for cand in input:iter() do
    local genuine_cand = cand:get_genuine()
    if genuine_cand.type == "datetime" then
      yield(genuine_cand)
      goto continue
    end
    local initial_comment = genuine_cand.comment
    local final_comment = initial_comment

    if should_skip_candidate_comment then
      yield(genuine_cand)
      goto continue
    end
    apply_upper_preedit(genuine_cand)
    -- 进入注释处理阶段
    -- 辅助码注释
    if initial_comment and (string.find(initial_comment, "~") or string.find(initial_comment, "\226\152\175") or cand.type == "datetime") then
      final_comment = initial_comment

      -- 常规的辅助码提示模式
    elseif is_comment_hint then
      local aux_comment = get_aux_comment(cand, env, initial_comment)
      if aux_comment then
        final_comment = aux_comment
      end

      -- 其他情况一律清空注释
    else
      final_comment = ""
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
