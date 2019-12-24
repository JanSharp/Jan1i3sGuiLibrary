
return {
  checked_state_changed = "checked_state_changed", -- Called when LuaGuiElement checked state is changed (related to checkboxes and radio buttons).
  click = "click", -- Called when LuaGuiElement is clicked.
  -- closed = "closed", -- Called when the player closes the GUI they have open.
  confirmed = "confirmed", -- Called when a LuaGuiElement is confirmed, for example by pressing Enter in a textfield.
  elem_changed = "elem_changed", -- Called when LuaGuiElement element value is changed (related to choose element buttons).
  location_changed = "location_changed", -- Called when LuaGuiElement element location is changed (related to frames in player.gui.screen).
  -- opened = "opened", -- Called when the player opens a GUI.
  selected_tab_changed = "selected_tab_changed", -- Called when LuaGuiElement selected tab is changed (related to tabbed-panes).
  selection_state_changed = "selection_state_changed", -- Called when LuaGuiElement selection state is changed (related to drop-downs and listboxes).
  switch_state_changed = "switch_state_changed", -- Called when LuaGuiElement switch state is changed (related to switches).
  text_changed = "text_changed", -- Called when LuaGuiElement text is changed by the player.
  value_changed = "value_changed", -- Called when LuaGuiElement slider value is changed (related to the slider element).
}

-- on_gui_closed and on_gui_opened removed, because they don't help for making guis - unless i am wrong ;)
-- (and they make event handling slightly more complex, which i would like to avoid because of performance)
