local default_gui = data.raw["gui-style"].default

red_disabled_graphical_set = {
  base = {
    border = 4,
    position = {240, 816},
    size = 80
  }
}

yellow_disabled_graphical_set = {
  base = {
    border = 4,
    position = {0, 816},
    size = 80
  }
}

bright_yellow_disabled_graphical_set = {
  base = {
    border = 4,
    position = {160, 816},
    size = 80
  }
}

default_gui.on_the_way = {
    type = "button_style",
    parent = "slot_button",
    default_graphical_set =  bright_yellow_disabled_graphical_set,
    hovered_graphical_set =  bright_yellow_disabled_graphical_set,
    clicked_graphical_set = bright_yellow_disabled_graphical_set,
    disabled_graphical_set = bright_yellow_disabled_graphical_set
}

default_gui.waiting = {
    type = "button_style",
    parent = "slot_button",
    default_graphical_set = yellow_disabled_graphical_set,
    hovered_graphical_set = yellow_disabled_graphical_set,
    clicked_graphical_set = yellow_disabled_graphical_set,
    disabled_graphical_set = yellow_disabled_graphical_set
}

default_gui.missing = {
    type = "button_style",
    parent = "slot_button",
    default_graphical_set =  red_disabled_graphical_set,
    hovered_graphical_set =  red_disabled_graphical_set,
    clicked_graphical_set = red_disabled_graphical_set,
    disabled_graphical_set = red_disabled_graphical_set
}
