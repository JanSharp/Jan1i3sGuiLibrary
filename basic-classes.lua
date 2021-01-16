
local gui_handler = require("__JanSharpsGuiLibrary__.gui-handler")
local class_names = require("__JanSharpsGuiLibrary__.basic-class-names")
local event_name_map = require("__JanSharpsGuiLibrary__.basic-class-event-map")

local all_full_event_names = {}
local all_fuller_event_names = {}
for class_name, event_names in pairs(event_name_map) do
  local full_event_names = {}
  all_full_event_names[class_name] = full_event_names
  local fuller_event_names = {}
  all_fuller_event_names[class_name] = fuller_event_names

  for _, event_name in pairs(event_names) do
    local full_name = "on_" .. event_name
    full_event_names[#full_event_names+1] = full_name
    fuller_event_names[#fuller_event_names+1] = full_name .. '_'
  end
end

-- create and register classes
for _, class_name in pairs(class_names) do
  local full_event_names = all_full_event_names[class_name]
  local fuller_event_names = all_fuller_event_names[class_name]

  local class = {
    class_name = class_name,
    create = function(data, passed_data) -- 'data' is basically the same data you would define in a custom create function ...
      data = data or {} -- (data can be nil)
      data.type = class_name -- ... except the type is predetermined (of course)
      return data, passed_data -- passed_data is simply passed through
    end,
    event_conditions = {},

    on_elem_created = function(self) -- init parent_event_names so they only get evaluated once
      local name_for_events = self.name_for_events or self.name
      if not name_for_events then return end -- without a name, events will never be passed through
      self.name_for_events = name_for_events
      local parent_event_names = {}
      self.parent_event_names = parent_event_names
      for _, event_name in ipairs(fuller_event_names) do
        parent_event_names[#parent_event_names+1] = event_name .. name_for_events
      end
    end,
  }

  for i, event_name in ipairs(full_event_names) do -- event conditions and event handlers
    class.event_conditions[event_name] = function(self) -- this means event handlers only get subscribed if the passed_parent actually defines a handler for it and self has a name
      if self.name_for_events then
        local passed_parent = self.passed_parent
        return passed_parent and passed_parent[self.parent_event_names[i]]
      end
      return false
    end
    class[event_name] = function(self, event) -- the event handler, no checks thanks to event_conditions
      local passed_parent = self.passed_parent
      passed_parent[self.parent_event_names[i]](passed_parent, self, event)
    end
  end

  gui_handler.register_class(class)
end
