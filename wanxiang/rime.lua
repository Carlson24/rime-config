if rime_api and rime_api.get_user_data_dir then
  local so = rime_api.get_user_data_dir() .. "/lua/clib/utf8ext.so"
  local init, err = package.loadlib(so, "luaopen_utf8")
  if init then
    _G.utf8 = init()
  end
end
if utf8.sub then
  log.info("lua-utf8 loaded: utf8.sub('中文测试',2,3) = " .. utf8.sub("中文测试", 2, 3))
else
  log.warning("lua-utf8 NOT loaded — falling back to standard utf8")
end
