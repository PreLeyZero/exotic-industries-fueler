if script.active_mods["gvv"] then require("__gvv__.gvv")() end

--====================================================================================================
--REQUIREMENTS
--====================================================================================================

ei_lib = require("lib/lib")

local ei_fueler = require("scripts/fueler")

ei_informatron = require("scripts/informatron")

--====================================================================================================
--EVENTS
--====================================================================================================

--ENTITY RELATED
------------------------------------------------------------------------------------------------------

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    --defines.events.on_entity_cloned
    }, function(e)
    on_built_entity(e)
end)


script.on_event({
    defines.events.on_entity_died,
	defines.events.on_pre_player_mined_item,
	defines.events.on_robot_pre_mined,
	defines.events.script_raised_destroy
    }, function(e)
    on_destroyed_entity(e)
end)


--UPDATER
------------------------------------------------------------------------------------------------------

script.on_event(defines.events.on_tick, function() 
    updater()
end)


--GUI RELATED
------------------------------------------------------------------------------------------------------

script.on_event(defines.events.on_gui_opened, function(event)
    local name = event.entity and event.entity.name

    if not name then
        return
    elseif name == "ei_fueler" then
        ei_fueler.open_gui(game.get_player(event.player_index))
    end
end)


script.on_event(defines.events.on_gui_closed, function(event)
    local name = event.entity and event.entity.name
    local element_name = event.element and event.element.name

    if name == "ei_fueler" then
        ei_fueler.close_gui(game.get_player(event.player_index))
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    local parent_gui = event.element.tags.parent_gui
    if not parent_gui then return end

    if parent_gui == "ei_fueler-console" then
        ei_fueler.on_gui_click(event)
    end
end)


--====================================================================================================
--HANDLERS
--====================================================================================================

function updater()

    for i=0, settings.startup["ei_fueler_max_updates_per_tick"].value do
        ei_fueler.updater()
    end

end


function on_built_entity(e)
    if not e["created_entity"] and e["entity"] then
        e["created_entity"] = e["entity"]
    end

    if not e["created_entity"] then
        return
    end

    ei_fueler.on_built_entity(e["created_entity"])

end


function on_destroyed_entity(e)
    if not e["entity"] then
        return
    end

    local transfer = nil or e["robot"] or e["player_index"]

    ei_fueler.on_destroyed_entity(e["entity"], transfer)

end