if script.active_mods["gvv"] then require("__gvv__.gvv")() end

--====================================================================================================
--REQUIREMENTS
--====================================================================================================

ei_lib = require("lib/lib")

local ei_fueler = require("scripts/fueler")

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

    ei_fueler.on_destroyed_entity(e["entity"])

end