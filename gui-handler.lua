
local event_handler = require("event_handler")

local gui_handler = {} -- return value
local classes = {}
local cached_class_events = {}
local conditional_cached_class_events = {}
local event_handlers = {}

local event_names = require("lualib.gui.event-names")
for _, event_name in pairs(event_names) do
  event_handlers[event_name] = {}
end


--- adds the given inst to event_handlers.  
--- only for the events the inst actually handles.  
--- this is determined using clached_class_events and conditional_cached_class_events,  
--- which get supplied in register_class(class).  
---   
--- this is where the event conditions actually get checked.
---@param inst GuiClassInst
local function add_event_handlers(inst)
  local index = inst.elem.index
  for _, event_name in pairs(cached_class_events[inst.class_name]) do
    event_handlers[event_name][index] = inst
  end
  for event_name, condition in pairs(conditional_cached_class_events[inst.class_name]) do
    if condition(inst) then
      event_handlers[event_name][index] = inst
    end
  end
end

--- removes all handlers for the given inst from event_handlers
---@param inst GuiClassInst
local function remove_event_handlers(inst)
  local index = inst.elem.index
  for _, event_name in pairs(event_names) do
    event_handlers[event_name][index] = nil
  end
end

local add_child_int -- i think i don't actually need this, but for intelisense it's still nice

--- the actual create function, it does loads of stuff.
---@param parent_element LuaGuiElement
---@param parent GuiClassInst | nil
---@param class_name string
---@param name string | nil
---@param parent_pass_count integer
---@return GuiClassInst
local function create_base(parent_element, parent, class_name, name, parent_pass_count, ...)
  local class = classes[class_name]
  if not class then error("No class with the 'class_name' \"" .. class_name .. "\" registered.") end -- debug
  local inst, passed_data = class.create(...)
  local instances = global.gui_handler.instances
  instances[#instances+1] = inst
  setmetatable(inst, class)

  local children = inst.children
  inst.children = {} -- removing the reference to children before parent_element.add,
  -- because children may cause recursive tables

  inst.class_name = class_name
  inst.name = name
  inst.elem = parent_element.add(inst)
  inst.parent = parent
  if passed_data then
    for k, v in pairs(passed_data) do
      inst[k] = v
    end
  end

  if parent_pass_count > 0 then
    local left = parent_pass_count
    local p_parent = parent
    while p_parent and left > 0 do
      left = left - 1
      p_parent = p_parent.parent
    end
    inst.passed_parent = p_parent -- passed_parent is the like the main parent inst

    if parent then
      p_parent[name] = inst -- makes inst directly accessable on the passed_parent as well
    end
  else
    inst.passed_parent = parent
  end

  local mods = inst.elem_mods
  if mods then
    local elem = inst.elem
    for k, v in pairs(mods) do
      elem[k] = v
    end
  end

  mods = inst.style_mods
  if mods then
    local style = inst.elem.style
    for k, v in pairs(mods) do
      style[k] = v
    end
  end

  local on_elem_created = inst.on_elem_created
  if on_elem_created then on_elem_created(inst) end

  add_event_handlers(inst)

  if children then
    for _, child in pairs(children) do
      add_child_int(inst, child.class_name, child.name, child.parent_pass_count or 0, table.unpack(child))
    end
  end

  local on_create = inst.on_create
  if on_create then on_create(inst) end

  return inst
end

--- creates a new inst of a GuiClass with the given class_name.  
--- the inst will have the given name  
--- and the actual LuaGuiElement will be a child of the given parent_element.  
---   
--- all varargs are passed to the GuiClass.create(...) function.
---@param parent_element LuaGuiElement
---@param class_name string
---@param name string | nil
---@return GuiClassInst
function gui_handler.create(parent_element, class_name, name, ...)
  return create_base(parent_element, nil, class_name, name, 0, ...)
end

--- creates a new inst of a GuiClass with the given class_name.  
--- inst.name = name  
--- and it will be a child of the given parent (both the inst and the elem).  
---   
--- if parent_pass_count > 0 then inst.passed_parent will be evaluated.  
--- if it cannot pass sufficient parents expect errors.  
---   
--- all varargs are passed to the GuiClass.create(...) function.
---   
--- if name != nil then  
---   parent.children[name] = inst  
---   parent[name] = inst  
--- else  
---   table.insert(parent.children, inst)  
--- end
---@param parent GuiClassInst
---@param class_name string
---@param name string | nil
---@param parent_pass_count integer
---@return GuiClassInst
function add_child_int(parent, class_name, name, parent_pass_count, ...) -- this is already a local
  local inst = create_base(
    parent.elem,
    parent,
    class_name,
    name,
    parent_pass_count,
    ...)

  if name then
    parent.children[name] = inst
    parent[name] = inst
  else
    table.insert(parent.children, inst)
  end
  return inst
end

--- creates a new inst of a GuiClass with the given class_name.  
--- inst.name = name  
--- and it will be a child of the given parent (both the inst and the elem).  
---   
--- all varargs are passed to the GuiClass.create(...) function.
---   
--- if name != nil then  
---   parent.children[name] = inst  
---   parent[name] = inst  
--- else  
---   table.insert(parent.children, inst)  
--- end
---@param parent GuiClassInst
---@param class_name string
---@param name string | nil
---@return GuiClassInst
local function add_child(parent, class_name, name, ...)
  return add_child_int(parent, class_name, name, 0, ...) -- it's a tail call, so no big deal
end

--- creates a new inst of a GuiClass with the given child.class_name.  
--- inst.name = child.name  
--- and it will be a child of the given parent (both the inst and the elem).  
---   
--- if child.parent_pass_count != nil and > 0 then inst.passed_parent will be evaluated.  
--- if it cannot pass sufficient parents expect errors.  
---   
--- all varargs are passed to the GuiClass.create(...) function.
---   
--- if child.name != nil then  
---   parent.children[child.name] = inst  
---   parent[child.name] = inst  
--- else  
---   table.insert(parent.children, inst)  
--- end
---@param parent GuiClassInst
---@param child GuiClassInstChildDefinition
---@return GuiClassInst
local function add_child_table(parent, child)
  return add_child_int(
    parent,
    child.class_name,
    child.name,
    child.parent_pass_count or 0,
    table.unpack(child)) -- it's a tail call, so no big deal
end

--- calls add_child(parent, class_name, name, ...) for each child in children.
---@param parent GuiClassInst
---@param children GuiClassInstChildDefinition[]
local function add_children(parent, children)
  for _, child in pairs(children) do
    add_child_int(parent, child.class_name, child.name, child.parent_pass_count or 0, table.unpack(child))
  end
end

--- well, it's recursive.  
--- calls inst.on_destroy on every child, and child of child if it exists.
---@param inst GuiClassInst
local function destroy_recursive(inst)
  for _, child in pairs(inst.children) do
    destroy_recursive(child)
  end
  global.gui_handler.instances[inst.elem.index] = nil
  remove_event_handlers(inst)
  local func = inst.on_destroy
  if func then func(inst) end
end

--- destroys inst and all of it's children.  
--- calls on_destroy on every inst getting destroyed.  
---  
--- if inst is a child, it will remove itself from the parent.
---@param inst GuiClassInst
function gui_handler.destroy(inst)
  destroy_recursive(inst)
  if inst.elem.valid then inst.elem.destroy() end

  local parent = inst.parent
  if parent then
    local name = inst.name
    if name then -- has name, easy to remove
      parent[name] = nil
      parent.children[name] = nil
    else -- no name, have to find it the hard way
      local children = parent.children
      for i = 1, #children do
        if children[i] == inst then
          -- has to table.remove, otherwise future destroys could fail
          table.remove(children, i)
        end
      end
    end
  end
end

--- call this when the elem of an inst got invalidated.  
--- this literally just calls destroy(inst) but is more elaborate.
---@param inst GuiClassInst
function gui_handler.got_destroyed(inst)
  gui_handler.destroy(inst)
end

---@param class GuiClassDefinition
local function validate_class(class)
  if not class.class_name or not class.create then
    error("Classes must define 'class_name' and 'create'")
  end
  if classes[class.class_name] then error("Class '" .. class.class_name .. "' is already registered.") end
  -- is there more to validate?
end

--- registers the given class and converts the GuiClassDefinition  
--- to a GuiClass.  
--- this means the following functions will also exist on the class:  
---   
--- add(parent, class_name, name, ...)  
--- add_table(parent, child)  
--- add_children(parent, children)  
--- destroy(inst)  
--- got_destroyed(inst)
---   
--- the table (class) will be used as a metatable for all GuiClassInst s  
--- where inst.class_name == class.class_name.  
---   
--- (also: class.__index = class)
---@param class GuiClassDefinition
function gui_handler.register_class(class)
  validate_class(class)
  classes[class.class_name] = class
  class.__index = class

  local class_events = {}
  local conditional_class_events = {}
  cached_class_events[class.class_name] = class_events
  conditional_cached_class_events[class.class_name] = conditional_class_events

  for _, event_name in pairs(event_names) do
    if class["on_" .. event_name] then
      local condition = class.event_conditions and class.event_conditions["on_" .. event_name]
      if condition ~= nil then
        conditional_class_events[event_name] = type(condition) == "function"
          and condition
          or function() return condition end
      else
        class_events[#class_events+1] = event_name
      end
    end
  end

  -- these functions will be directly accessable on the instances, because metatables
  class.add = add_child
  class.add_table = add_child_table
  class.add_children = add_children
  class.destroy = gui_handler.destroy
  class.got_destroyed = destroy_recursive -- see gui_handler.got_destroyed
end

--- calls register_class(class) for each class in classes
---@param classes GuiClassDefinition[]
function gui_handler.register_classes(classes)
  for _, class in pairs(classes) do
    gui_handler.register_class(class)
  end
end


do -- event handlers
  local lib = {}

  function lib.on_init()
    global.gui_handler = {
      instances = {},
    }
  end

  function lib.on_load()
    for _, inst in pairs(global.gui_handler.instances) do
      add_event_handlers(inst)
      setmetatable(inst, classes[inst.class_name])
    end
  end

  for _, event_name in pairs(event_names) do
    local handler_name = "on_" .. event_name -- that way concatenation only happens once -> on startup
    local event_specific_handlers = event_handlers[event_name]

    script.on_event(defines.events["on_gui_" .. event_name], function(event)
      -- if not event.element then return end -- needed for on_gui_closed and on_gui_opened
      -- todo: optimize so it's not included in all other handlers, or just remove the 2
      -- removed for now, see event-names.lua for more info

      local inst = event_specific_handlers[event.element.index]
      if inst then
        inst[handler_name](inst, event)
      end
    end)
  end

  event_handler.add_lib(lib)
end

return gui_handler



---@class GuiClassInstDefinition
--[[
  {
    type = string, -- see basic-class-names.lua

    children = {
      GuiClassInsstChildDefinition,
      ...
      -- before LuaGuiElement.add(...) get's called, this table will be removed from the GuiClassInstDefinition
      -- this is to make dealing with circular references easier (basically don't worry about them inside children).
      -- afterwards, for every item add_child_table(parent, child) will be called
      -- where parent = inst
      -- and child = the respective GuiClassInsstChildDefinition
    },

    elem_mods = {
      [string] = any, -- after the inst.elem has been created, for every
      ... -- item in this list inst.elem[key] = value will be executed
    },
    style_mods = {
      [string] = any, -- just like elem_mods, but for inst.elem.style
      ...
    },

    [any] = any,
    ...
    -- this table will be passed to the LuaGuiElement.add(...) function
    -- so any parameters dependent on the type will be used by the api
    -- every other key-value pair will also persist in the GuiClassInst
  }
]]


---@class GuiClassInstChildDefinition
--[[
  {
    class_name = string,
    name = nil | string,
    parent_pass_count = nil | integer,

    -- every continuous integer key starting at 1 ascending will be passed to GuiClass.create(...) in that order
  }
]]


---@class GuiClassInst
--[[
  {
    class_name = string,
    name = nil | string,
    parent = nil | GuiClassInst,
    children = {
      [string] = GuiClassInst, -- all named children
      ...
      [integer] = GuiClassInst, -- all unnamed children
      ...
    },
    elem = LuaGuiElement,

    [string] = GuiClassInst, -- all named children
    ...

    [any] = any,
    ...
    -- everything that was in the GuiClassinstDefinition
    -- plus the "passed_data", which is the optional second return value of GuiClass.create(...)
  }
]]


---@class GuiClassDefinition
--[[
  {
    class_name = string, -- unique
    create = function(...) -> (GuiClassInstDefinition, nil | {[any] = any, ...}),
    -- called whenever a new instance of the class gets created
    -- the second return value simply contains data that will end up in the GuiClassInst
    -- this is required whenever a value cannot be passed the the LuaGuiElement.add function,
    -- like when having circular references

    on_elem_created = function(self),
    on_create = function(self),

    ["on_" .. event_name] = function(self, event), -- event handlers. on_click would be one

    [any] = any, -- you can throw anything into this table, remember it'll be a metatable for GuiClassInst s
    ...
  }
]]


---@class GuiClass
--[[
  {
    -- <everything that was in the GuiClassDefinition used to create the GuiClass>

    __index = GuiClass, -- self

    -- see respective functions for intelisense
    add = function(parent, class_name, name, ...),
    add_table = function(parent, child),
    add_children = function(parent, children),
    destroy = function(inst),
    got_destroyed = function(inst),
  }
]]


---@class LuaGuiElement
-- api LuaObject





--[[

<outdated>

local classes = {
  [class_name] = {
    create = (function),
    [event_name] = (function), -- on_click instead of on_gui_click, basically remove the "_gui" part
    [function_name] = (function),
    ...
  }
}

global.gui_handler = {
  [event_name] = {
    [gui_element_index] = {
      class_name = (string),

      <class specific data - custom>,

      <metatable> = classes[class_name],
    },
  },
}

update:
global.gui_handler = {
  instances = [
    <class inst>,
    ...
  ]
}

]]
