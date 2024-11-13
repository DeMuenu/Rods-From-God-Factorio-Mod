data:extend({
    {
      type = "selection-tool",
      name = "OrbitPosTool",
      icon = "__RodsFromGod__/assets/icons/explosion.png",
      flags = { "spawnable"},
      icon_size = 64,
      stack_size = 10,
      show_on_map = true,
      capsule_action =
      {
        type = "artillery-remote",
        flare = "artillery-flare",
        radius = 500,
        show_on_map = true,
      },
      select =
      {
        border_color = {0, 1, 0},
        mode = {"any-entity"},
        cursor_box_type = "entity",
      },
      alt_select =
      {
        border_color = {0, 1, 0},
        mode = {"any-entity"},
        cursor_box_type = "entity",
      },
      skip_fog_of_war = true
  }})
