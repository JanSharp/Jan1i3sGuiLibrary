
pcall(require, "__debugadapter__/debugadapter.lua")

local consts = require("__Jan1i3sGuiLibrary__/consts")

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

script.on_event(defines.events.on_entity_died, function(event)
  game.print(event.entity.name)
end)
