if rime_api then
  local roots = {}
  if rime_api.get_user_data_dir then
    roots[#roots + 1] = rime_api.get_user_data_dir()
  end
  -- get_shared_data_dir 可能不存在于旧版 Rime，需守卫
  if rime_api.get_shared_data_dir then
    roots[#roots + 1] = rime_api.get_shared_data_dir()
  end
  for _, root in ipairs(roots) do
    local so = root .. "/lua/clib/utf8ext.so"
    local init, err = package.loadlib(so, "luaopen_utf8")
    if init then
      _G.utf8 = init()
      break
    end
  end
end
if utf8.sub then
  log.info("lua-utf8 loaded: utf8.sub('这是一个中文测试',2,3) = " .. utf8.sub("这是一个中文测试", 7, 8))
else
  log.warning("lua-utf8 NOT loaded — falling back to standard utf8")
end
