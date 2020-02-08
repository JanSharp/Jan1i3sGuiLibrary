
if script.active_mods["debugadapter"] then require('__debugadapter__/debugadapter.lua') end

local consts = require("__JanSharpsGuiLibrary__/consts.lua")

for _, func_name in pairs(consts.client_funcs) do
  script[func_name](function()
    for interface_name, _ in pairs(remote.interfaces) do
      local start, stop = string.find(interface_name, consts.client_interface_name_id)
      if start == 1 and stop == string.len(interface_name) then
        remote.call(interface_name, func_name)
      end
    end
  end)
end
