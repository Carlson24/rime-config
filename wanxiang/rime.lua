if rime_api and rime_api.get_user_data_dir then
  local so = rime_api.get_user_data_dir() .. "/lua/clib/utf8ext.so"
  local init, err = package.loadlib(so, "luaopen_utf8")
  if init then
    _G.utf8 = init()
  end
end
