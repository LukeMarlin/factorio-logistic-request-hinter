local default_gui = data.raw["gui-style"].default

function redbuttongraphcialset()
  return
  {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {111, 36},
    size = 36,
    scale = 1
  }
end

default_gui.fulfilling_slot = {
    type = "button_style",
    parent = "slot_button",
    default_graphical_set =  orangebuttongraphcialset(),
    hovered_graphical_set =  orangebuttongraphcialset(),
    clicked_graphical_set = orangebuttongraphcialset(),
    disabled_graphical_set = orangebuttongraphcialset()
}

default_gui.cant_fulfill_slot = {
    type = "button_style",
    parent = "slot_button",
    default_graphical_set =  redbuttongraphcialset(),
    hovered_graphical_set =  redbuttongraphcialset(),
    clicked_graphical_set = redbuttongraphcialset(),
    disabled_graphical_set = redbuttongraphcialset()
}