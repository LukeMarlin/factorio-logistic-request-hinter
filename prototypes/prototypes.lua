local default_gui = data.raw["gui-style"].default

function redbuttongraphcialset()
  return
  {
    type = "monolith",
    monolith_border = 1,
    monolith_image =
    {
      filename = "__core__/graphics/gui.png",
      priority = "extra-high-no-scale",
      width = 36,
      height = 36,
      x = 111,
      y = 36
    }
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