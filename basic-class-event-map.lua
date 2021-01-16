
local class_names = require("__JanSharpsGuiLibrary__.basic-class-names")
local event_names = require("__JanSharpsGuiLibrary__.event-names")

-- note: this list might not be complete
return {
  [class_names.button] = {
    event_names.click,
  },
  [class_names.sprite_button] = {
    event_names.click,
  },
  [class_names.checkbox] = {
    event_names.click,
    event_names.checked_state_changed,
  },
  [class_names.flow] = {
    event_names.click,
  },
  [class_names.frame] = {
    event_names.click,
    event_names.location_changed,
  },
  [class_names.label] = {
    event_names.click,
  },
  [class_names.line] = {
    event_names.click,
  },
  [class_names.progressbar] = {
    event_names.click,
  },
  [class_names.table] = {
    event_names.click,
  },
  [class_names.textfield] = {
    event_names.click,
    event_names.confirmed,
    event_names.text_changed,
  },
  [class_names.radiobutton] = {
    event_names.click,
    event_names.checked_state_changed,
  },
  [class_names.sprite] = {
    event_names.click,
  },
  [class_names.scroll_pane] = {
    event_names.click,
  },
  [class_names.drop_down] = {
    event_names.click,
    event_names.selection_state_changed,
  },
  [class_names.list_box] = {
    event_names.click,
    event_names.selection_state_changed,
  },
  [class_names.camera] = {
    event_names.click,
  },
  [class_names.choose_elem_button] = {
    event_names.click,
    event_names.elem_changed,
  },
  [class_names.text_box] = {
    event_names.click,
    event_names.confirmed,
    event_names.text_changed,
  },
  [class_names.slider] = {
    event_names.click,
    event_names.value_changed,
  },
  [class_names.minimap] = {
    event_names.click,
  },
  [class_names.entity_preview] = {
    event_names.click,
  },
  [class_names.empty_widget] = {
    event_names.click,
  },
  [class_names.tabbed_pane] = {
    event_names.click,
    event_names.selected_tab_changed,
  },
  [class_names.tab] = {
    event_names.click,
  },
  [class_names.switch] = {
    event_names.click,
    event_names.switch_state_changed,
  },
}
