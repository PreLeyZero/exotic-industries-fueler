--====================================================================================================
--fueler
--====================================================================================================

data:extend({
    {
        name = "ei_fueler",
        type = "item",
        icon = ei_fueler_graphics_path.."64_empty.png",
        icon_size = 64,
        subgroup = "production-machine",
        order = "x",
        place_result = "ei_fueler",
        stack_size = 10,
    },
    {
        name = "ei_fueler",
        type = "recipe",
        category = "crafting",
        energy_required = 1,
        ingredients = {
            {"iron-plate", 10},
            {"iron-gear-wheel", 5},
            {"electronic-circuit", 5},
        },
        result = "ei_fueler",
        result_count = 1,
        enabled = true,
    },
    {
        name = "ei_fueler",
        type = "container",
        icon = ei_fueler_graphics_path.."64_empty.png",
        icon_size = 64,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "ei_fueler"},
        max_health = 100,
        corpse = "small-remnants",
        collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        inventory_size = 4,
        enable_inventory_bar = false,
        picture = {
            filename = ei_fueler_graphics_path.."64_red.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            shift = {0, 0},
        },
        radius_visualisation_specification = {
            sprite = {
                filename = ei_fueler_graphics_path.."radius.png",
                width = 256,
                height = 256
            },
            distance = 6
        },
        
    },
    {
        name = "ei_fueler-sprite",
        type = "sprite",
        filename = ei_fueler_graphics_path.."64_empty.png",
        width = 64,
        height = 64,
    },
})