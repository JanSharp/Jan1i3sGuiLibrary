
local modname = "JanSharpsGuiLibrary"

return {
  modname = modname,
  client_funcs = {
    on_load = "on_load",
  },
  client_interface_name_id = "__" .. modname .. "_%d+",
}
