-- data.lua
local RodLauncher = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
RodLauncher.name = "RodLauncher-silo"
--RodLauncher.collision_mask = {"space-platform-layer"}  -- Replace with the actual layer name for space platforms
RodLauncher.rocket_parts_required = 10
RodLauncher.fixed_recipe = nil
RodLauncher.inventory_size = 100  -- Set desired inventory size
RodLauncher.energy_usage = "1MW"  -- Disable energy consumption if not needed
RodLauncher.module_specification = nil  -- Remove module slots if not required
RodLauncher.crafting_categories = {"RodLauncher-crafting"}
RodLauncher.inventory_size = 100


-- Remove launch-related animations and sounds



data:extend({RodLauncher})

-- data.lua
local space_silo_item = {
    type = "item",
    name = "RodLauncher-silo-item",
    icon = "__base__/graphics/icons/rocket-silo.png",  -- Use your own icon if desired
    icon_size = 64,
    subgroup = "production-machine",  -- Adjust to the appropriate subgroup
    order = "e[rocket-silo]",
    place_result = "RodLauncher-silo",  -- Link to the custom entity name
    stack_size = 1
}
data:extend({space_silo_item})

local space_silo_recipe = {
    type = "recipe",
    name = "RodLauncher-recipe",
    enabled = true,  -- Set to `true` if you want it available immediately
    ingredients = {
        {type = "item", name = "steel-plate", amount = 100},
        {type = "item", name = "advanced-circuit", amount = 200},
        {type = "item", name = "concrete", amount = 500}
    },
    results = {{type="item", name="RodLauncher-silo-item", amount=1}}
}

data:extend({space_silo_recipe})







data:extend({
    {
        type = "recipe-category",
        name = "RodLauncher-crafting"
    }
})

local space_silo_recipe_1 = {
    type = "recipe",
    name = "Basic-Rod-From-God",
    category = "RodLauncher-crafting",  -- Assign to custom silo category
    enabled = true,
    ingredients = {
        {type = "item", name = "solid-fuel", amount = 2},
        {type = "item", name = "rocket-fuel", amount = 1}
    },
    results = {{type="item", name="concrete", amount=1}},
    energy_required = 30  -- Adjust crafting time as needed
}
data:extend({space_silo_recipe_1})