
return {
  button = "button", -- Clickable elements that fire on_gui_click when clicked.
  sprite_button = "sprite-button", -- A button that displays an image rather than text.
  checkbox = "checkbox", -- Clickable elements with a cross in the middle that can be turned off or on.
  flow = "flow", -- Invisible containers that lay out children either horizontally or vertically. The root GUI elements (top, left and center; see LuaGui) are flows.
  frame = "frame", -- Grey semi-transparent boxes that contain other elements. They have a caption, and, just like flows, they lay out children either horizontally or vertically.
  label = "label", -- A piece of text.
  line = "line", -- A vertical or horizontal line.
  progressbar = "progressbar", -- Indicate progress by displaying a partially filled bar.
  table = "table", -- An invisible container that lays out children in a specific number of columns. Column width is given by the largest element contained in that row.
  textfield = "textfield", -- Boxes of text the user can type in.
  radiobutton = "radiobutton", -- Identical to checkbox except circular.
  sprite = "sprite", -- An element that shows an image.
  scroll_pane = "scroll-pane", -- Similar to a flow but includes the ability to show and use scroll bars.
  drop_down = "drop-down", -- A drop down list of other elements.
  list_box = "list-box", -- A list of other elements.
  camera = "camera", -- A camera that shows the game at the given position on the given surface.
  choose_elem_button = "choose-elem-button", -- A button that lets the player pick one of an: item, entity, tile, or signal similar to the filter-select window.
  text_box = "text-box", -- A multi-line text box that supports selection and copy-paste.
  slider = "slider", -- A number picker.
  minimap = "minimap", -- A minimap preview similar to the normal player minimap.
  entity_preview = "entity-preview", -- A preview of an entity. The entity has to be set after the GUI element is created.
  empty_widget = "empty-widget", -- A empty widget that just exists. The root GUI element screen is an empty-widget.
  tabbed_pane = "tabbed-pane", -- A collection of tabs.
  tab = "tab", -- A tab for use in a tabbed-pane.
  switch = "switch", -- A switch with left, right, and none states.
}
