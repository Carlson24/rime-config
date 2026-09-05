--[[

万象英文辅助模块
作者：amzxyz
项目：https://github.com/amzxyz/rime-wanxiang
功能说明：

T（Translator）
调用 wanxiang_english 词典，负责英文候选输出，
以及单字母当前大小写和相反大小写候选的派生。

F（Filter）
负责英文候选格式化，包括大小写转换、句内空格恢复；
在中英混合方案中，还负责清理明确英文候选之后的无效补全候选。

]]

local byte = string.byte
local find = string.find
local gsub = string.gsub
local lower = string.lower
local upper = string.upper
local sub = string.sub
local gmatch = string.gmatch
local tonumber = tonumber
local concat = table.concat

local function is_single_ascii_letter(input)
  if not input or #input ~= 1 then
    return false
  end

  local code = byte(input, 1)

  return (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
end

local function make_single_candidate(text, input, seg, quality)
  local start_pos = seg and seg.start or 0
  local end_pos = seg and seg._end or #input

  local cand = Candidate("completion", start_pos, end_pos, text, "")

  cand.preedit = input
  cand.quality = quality

  return cand
end

local function build_single_candidates(input, seg)
  if not is_single_ascii_letter(input) then
    return nil, nil
  end

  local code = byte(input, 1)
  local input_is_upper = code >= 65 and code <= 90

  local current_case = input
  local opposite_case = input_is_upper and lower(input) or upper(input)

  local current_candidate = make_single_candidate(current_case, input, seg, 1.602)
  local opposite_candidate = make_single_candidate(opposite_case, input, seg, 1.601)

  return current_candidate, opposite_candidate
end

local function update_single_candidate_quality(current_candidate, opposite_candidate, anchor_quality)
  local base_quality = tonumber(anchor_quality) or 1.6

  if current_candidate then
    current_candidate.quality = base_quality + 0.002
  end

  if opposite_candidate then
    opposite_candidate.quality = base_quality + 0.001
  end
end

local T = {}
local function release_eng_translator(env)
  local translator = env.eng_translator
  if not translator then return end

  translator:disconnect()
  env.eng_translator = nil
end

function T.init(env)
  release_eng_translator(env)

  if not Component or type(Component.TableTranslator) ~= "function" then
    return
  end

  env.eng_translator = Component.TableTranslator(env.engine, "wanxiang_english", "table_translator")
end

function T.func(input, seg, env)
  input = input or ""

  if input == "" or not env.eng_translator then
    return
  end

  local single_letter = is_single_ascii_letter(input)

  local current_candidate = nil
  local opposite_candidate = nil

  if single_letter then
    current_candidate, opposite_candidate = build_single_candidates(input, seg)
  end

  local translation = env.eng_translator:query(input, seg)

  if not translation then
    if current_candidate then
      yield(current_candidate)
    end

    if opposite_candidate then
      yield(opposite_candidate)
    end

    return
  end

  if single_letter then
    local input_lower = lower(input)
    local next_candidate, iterator_state = translation:iter()
    local first_native = nil

    while true do
      local cand = next_candidate(iterator_state)

      if not cand then
        break
      end

      local cand_text = cand.text or ""
      local is_single_duplicate = #cand_text == 1 and lower(cand_text) == input_lower

      if not is_single_duplicate then
        first_native = cand
        break
      end
    end

    update_single_candidate_quality(current_candidate, opposite_candidate, first_native and first_native.quality)

    if current_candidate then
      yield(current_candidate)
    end

    if opposite_candidate then
      yield(opposite_candidate)
    end

    if first_native then
      yield(first_native)
    end

    while true do
      local cand = next_candidate(iterator_state)

      if not cand then
        break
      end

      local cand_text = cand.text or ""
      local is_single_duplicate = #cand_text == 1 and lower(cand_text) == input_lower

      if not is_single_duplicate then
        yield(cand)
      end
    end

    return
  end

  for cand in translation:iter() do
    yield(cand)
  end
end

function T.fini(env)
  release_eng_translator(env)
end

local pure_memo = {}
local function pure(s)
  local cached = pure_memo[s]
  if cached ~= nil then
    return cached
  end
  cached = gsub(s, "[^a-zA-Z]", ""):lower()
  pure_memo[s] = cached
  return cached
end

local function trim_spaces(text)
  text = gsub(text, "^%s+", "")
  return gsub(text, "%s+$", "")
end

local allowed_ascii_symbols = {
  [32] = true,   -- space
  [33] = true,   -- !
  [39] = true,   -- '
  [44] = true,   -- ,
  [45] = true,   -- -
  [43] = true,   -- +
  [46] = true,   -- .
  [48] = true,
  [49] = true,
  [50] = true,
  [51] = true,
  [52] = true,
  [53] = true,
  [54] = true,
  [55] = true,
  [56] = true,
  [57] = true,
}

-- 必须包含至少一个英文字母，否则纯数字/符号直接返回 false
local function is_ascii_phrase_fast(s)
  if not s or s == "" then
    return false
  end
  local len = #s
  local has_alpha = false
  for i = 1, len do
    local b = byte(s, i)
    local is_upper = (b >= 65 and b <= 90)
    local is_lower = (b >= 97 and b <= 122)
    local is_allowed_sym = allowed_ascii_symbols[b]

    if is_upper or is_lower then
      has_alpha = true
    elseif not is_allowed_sym then
      return false
    end
  end
  return has_alpha
end

local EnglishPrefixCleanup = {}

local CLEANUP_KEEP = 0
local CLEANUP_STOP = 1
local CLEANUP_KEEP_AND_STOP = 2

local CLEANUP_MIN_CODE_LENGTH = 4
local CLEANUP_MIN_ENGLISH_PREFIX = 3

local function get_candidate_type(cand)
  local cand_type = cand.type

  if cand_type and cand_type ~= "" then
    return cand_type
  end

  local genuine = cand.get_genuine and cand:get_genuine() or nil

  return genuine and genuine.type or ""
end

local function is_exact_table_type(cand_type)
  return cand_type == "table" or cand_type == "user_table" or cand_type == "fixed"
end

function EnglishPrefixCleanup.new(schema_id, code_len)
  if schema_id == "wanxiang_english" or code_len < CLEANUP_MIN_CODE_LENGTH then
    return nil
  end

  return {
    detecting = true,
    active = false,
    english_count = 0,
    english_seen = {},
  }
end

function EnglishPrefixCleanup.check(state, cand)
  local text = trim_spaces(cand.text or "")
  local is_english = is_ascii_phrase_fast(text)

  if not state.active then
    if not state.detecting then
      return CLEANUP_KEEP
    end

    if not is_english then
      state.detecting = false
      state.english_seen = nil
      return CLEANUP_KEEP
    end

    local english_key = lower(text)

    if not state.english_seen[english_key] then
      state.english_seen[english_key] = true
      state.english_count = state.english_count + 1
    end

    if state.english_count >= CLEANUP_MIN_ENGLISH_PREFIX then
      state.active = true
      state.detecting = false
      state.english_seen = nil
    end

    return CLEANUP_KEEP
  end

  if is_english then
    return CLEANUP_KEEP
  end

  local cand_type = get_candidate_type(cand)

  if is_exact_table_type(cand_type) then
    return CLEANUP_KEEP_AND_STOP
  end

  return CLEANUP_STOP
end

local function has_letters(s)
  return find(s, "[a-zA-Z]")
end

local function ascii_lower_byte(code)
  if code >= 65 and code <= 90 then
    return code + 32
  end

  return code
end

local function find_target_in_text(text, start_pos, target_fp)
  local text_len = #text
  local target_len = #target_fp

  if target_len == 0 then
    return nil, nil
  end

  local target_index = 1
  local scan_pos = start_pos
  local match_start = nil

  while scan_pos <= text_len and target_index <= target_len do
    local text_byte = ascii_lower_byte(byte(text, scan_pos))
    local target_byte = byte(target_fp, target_index)

    if text_byte == target_byte then
      if target_index == 1 then
        match_start = scan_pos
      end

      target_index = target_index + 1
    end

    scan_pos = scan_pos + 1
  end

  if target_index > target_len then
    return match_start, scan_pos - 1
  end

  return nil, nil
end

local function restore_sentence_spacing(cand, split_pattern, check_pattern)
  local guide = cand.preedit or ""

  if not find(guide, check_pattern) then
    return cand
  end

  local text = cand.text
  local starts = {}
  local search_pos = 1
  local start_count = 0

  for segment in gmatch(guide, split_pattern) do
    local target = pure(segment)

    if target ~= "" then
      local match_start, match_end = find_target_in_text(text, search_pos, target)

      if not match_start then
        return cand
      end

      start_count = start_count + 1
      starts[start_count] = match_start
      search_pos = match_end + 1
    end
  end

  if start_count == 0 then
    return cand
  end

  local chunks = {}
  local chunk_count = 0

  if starts[1] > 1 then
    chunk_count = chunk_count + 1
    chunks[chunk_count] = sub(text, 1, starts[1] - 1)
  end

  for index = 1, start_count do
    local current_start = starts[index]
    local next_start = starts[index + 1]
    local chunk_end = next_start and (next_start - 1) or #text

    chunk_count = chunk_count + 1
    chunks[chunk_count] = sub(text, current_start, chunk_end)
  end

  local output = {}

  if chunk_count > 0 then
    output[1] = chunks[1]
  end

  for index = 2, chunk_count do
    local previous_chunk = chunks[index - 1]
    local last_char = sub(previous_chunk, -1)

    if last_char == "'" or last_char == "-" then
      output[index] = chunks[index]
    else
      output[index] = " " .. chunks[index]
    end
  end

  local new_text = concat(output)
  new_text = gsub(new_text, "%s%s+", " ")

  if new_text == "" or new_text == text then
    return cand
  end

  local nc = Candidate(cand.type, cand.start, cand._end, new_text, cand.comment)
  nc.preedit = cand.preedit
  nc.quality = cand.quality

  return nc
end

local NBSP = string.char(0xC2, 0xA0)

local function apply_segment_formatting(text, input_code)
  if not input_code or input_code == "" or not find(input_code, "%u") then
    return text
  end
  local parts = {}
  local p_code = 1
  for word in gmatch(text, "%S+") do
    local out_word = word
    local clean_word = pure(word)
    local w_len = #clean_word
    if w_len > 0 then
      if find(word, "[\128-\255]") then
        local input_remain = #input_code - p_code + 1
        if input_remain > 0 then
          local check_len = (w_len < input_remain) and w_len or input_remain
          p_code = p_code + check_len
        end
      else
        local input_remain = #input_code - p_code + 1
        if input_remain > 0 then
          local check_len = (w_len < input_remain) and w_len or input_remain
          local segment = sub(input_code, p_code, p_code + check_len - 1)
          local is_pure_alpha = not find(word, "[^a-zA-Z]")
          if find(segment, "^%u%u") and is_pure_alpha then
            out_word = upper(word)
          elseif find(segment, "^%u") then
            out_word = gsub(word, "^%a", upper)
          end
          p_code = p_code + check_len
        end
      end
    end
    parts[#parts + 1] = out_word
  end

  return concat(parts, " ")
end

local function apply_formatting(cand, code_ctx, preserve_letter_case)
  local text = cand.text
  if not text or text == "" then
    return cand
  end

  local changed = false

  if find(text, NBSP, 1, true) then
    text = gsub(text, NBSP, " ")
    changed = true
  end

  if is_ascii_phrase_fast(text) then
    if code_ctx.raw_input and not preserve_letter_case then
      local new_text = apply_segment_formatting(text, code_ctx.raw_input)

      if new_text ~= text then
        text = new_text
        changed = true
      end
    end
  end

  if not changed then
    return cand
  end

  local nc = Candidate(cand.type, cand.start, cand._end, text, cand.comment)

  nc.preedit = cand.preedit
  nc.quality = cand.quality

  return nc
end

local F = {}

function F.init(env)
  local cfg = env.engine.schema.config
  env.schema_id = env.engine.schema.schema_id
  local delimiter_str = " '"
  if cfg then
    delimiter_str = cfg:get_string("speller/delimiter") or delimiter_str
  end

  local escaped_delims = gsub(delimiter_str, "([%%%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

  env.split_pattern = "[^" .. escaped_delims .. "]+"

  env.delim_check_pattern = "[" .. escaped_delims .. "]"
end

function F.func(input, env)
  local ctx = env.engine.context

  local curr_input = ctx.input

  if not has_letters(curr_input) then
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  local code_len = #curr_input
  local single_letter_input = code_len == 1 and is_single_ascii_letter(curr_input)
  local input_lower = single_letter_input and lower(curr_input) or nil

  local code_ctx = {
    raw_input = curr_input,
  }

  local prefix_cleanup = EnglishPrefixCleanup.new(env.schema_id, code_len)

  for cand in input:iter() do
    local cleanup_action = CLEANUP_KEEP

    if prefix_cleanup then
      cleanup_action = EnglishPrefixCleanup.check(prefix_cleanup, cand)
    end

    if cleanup_action == CLEANUP_STOP then
      return
    end

    local good_cand = restore_sentence_spacing(cand, env.split_pattern, env.delim_check_pattern)

    local preserve_single_letter_case = single_letter_input
        and is_single_ascii_letter(good_cand.text)
        and lower(good_cand.text) == input_lower

    local fmt_cand = apply_formatting(good_cand, code_ctx, preserve_single_letter_case)

    if env.schema_id == "wanxiang_english" and fmt_cand.comment and find(fmt_cand.comment, "\226\152\175") then
      local original_quality = fmt_cand.quality
      local nc = Candidate(fmt_cand.type, fmt_cand.start, fmt_cand._end, fmt_cand.text, "")

      nc.preedit = fmt_cand.preedit
      nc.quality = original_quality
      fmt_cand = nc
    end

    yield(fmt_cand)

    if cleanup_action == CLEANUP_KEEP_AND_STOP then
      return
    end
  end
end

return {
  T = T,
  F = F,
}
