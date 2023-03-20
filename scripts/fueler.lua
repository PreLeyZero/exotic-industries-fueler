local model = {}

--====================================================================================================
--FUELER
--====================================================================================================

model.target_types = {
    "locomotive",
    "car",
    "character", -- refering to player equipment
    "spider-vehicle", -- needed for EI changes
}


--UTIL
------------------------------------------------------------------------------------------------------

function model.entity_check(entity)
    if entity == nil then
        return false
    end

    if not entity.valid then
        return false
    end

    return true
end


function model.check_global()

    if not global.ei then
        global.ei = {}
    end

    if not global.ei.fueler then
        global.ei.fueler = {}
    end

end


function model.check_queue()

    if not global.ei then
        global.ei = {}
    end

    if not global.ei.fueler_queue then
        global.ei.fueler_queue = {}
    end

end


function model.check_cooldown()

    if not global.ei then
        global.ei = {}
    end

    if not global.ei.cooldown then
        global.ei.cooldown = {}
    end

end


function model.is_on_cooldown(entity)

    if not global.ei.cooldown[entity.unit_number] then
        return false
    end

    if global.ei.cooldown[entity.unit_number] > game.tick then
        -- the tick value is for when the cooldown will end
        return true
    end

    return false

end


function model.add_cooldown(entity)

    model.check_cooldown()
    global.ei.cooldown[entity.unit_number] = game.tick + 60

end


function model.refuel_target(fueler, target, target_type)

    -- game.print("refueling target")
    -- game.print("fueler: " .. fueler.name)
    -- game.print("target: " .. target.name)

    local fueler_inventory = fueler.get_inventory(defines.inventory.chest)
    local target_inventory = nil

    if target_type == "car" or target_type == "spider-vehicle" or target_type == "locomotive" then

        target_inventory = target.get_fuel_inventory()

    end

    if target_inventory == nil then
        return
    end

    if target_inventory.is_full() then
        return
    end

    if fueler_inventory.is_empty() then
        return
    end

    -- for every itemstack in the fueler inventory check if
    -- this itemstack can be inserted into the target inventory

    local itemstacks_inserted = {}

    for i=1, #fueler_inventory do

        local itemstack = fueler_inventory[i]

        if itemstack.valid_for_read then

            if target_inventory.can_insert(itemstack.name) then
                local count = target_inventory.insert(itemstack.name)

                table.insert(itemstacks_inserted, {itemstack.name, count})

            end
            
        end

    end

    -- remove the itemstacks that were inserted into the target inventory
    for _, itemstack in ipairs(itemstacks_inserted) do
        fueler_inventory.remove({name=itemstack[1], count=itemstack[2]})
    end


end


function model.get_break_point()

    model.check_queue()

    -- id,_ = next() returns the first element of a table
    -- id,_ = next(_, id) returns the next element of a table

    -- if there already is a break point, then try to move it forward one step
    -- if that is not possible then try to return the first element
    -- if that is not possible then return nil

    -- if there id no current break point, then try to return the first element
    -- if that is not possible then return nil

    local break_point = global.ei.fueler_break_point

    if break_point then

        -- try to move the break point forward one step
        if next(global.ei.fueler_queue, break_point) then
            global.ei.fueler_break_point,_ = next(global.ei.fueler_queue, break_point)
            return global.ei.fueler_break_point
        end

        -- cant move the break point forward, so try to return the first element
        if next(global.ei.fueler_queue) then
            global.ei.fueler_break_point,_ = next(global.ei.fueler_queue)
            return global.ei.fueler_break_point
        end

        -- cant return the first element, so return nil
        return nil

    end

    -- there is no break point, so try to return the first element
    if next(global.ei.fueler_queue) then
        global.ei.fueler_break_point,_ = next(global.ei.fueler_queue)
        return global.ei.fueler_break_point
    end

    -- cant return the first element, so return nil
    return nil

end


--UPDATES
------------------------------------------------------------------------------------------------------

function model.update_cooldowns()

    model.check_cooldown()

    local ids_to_remove = {}

    -- remove all cooldowns that are over current tick
    for unit, cooldown in pairs(global.ei.cooldown) do

        if cooldown < game.tick then
            -- store unit for removal
            table.insert(ids_to_remove, unit)
        end

    end

    -- remove all stored units
    for i, unit in ipairs(ids_to_remove) do
        global.ei.cooldown[unit] = nil
    end

end


function model.update_fueler(break_point)

    model.check_global()
    model.check_cooldown()

    local unit = global.ei.fueler_queue[break_point]
    local fueler = global.ei.fueler[unit].entity

    -- get what entity_type this fueler currently fuels
    -- and then try to insert as many items from the fueler inv as possible
    -- into all targets of that type

    local target_type = model.get_target_type(unit)

    -- get all entities of the target type in range
    local targets = fueler.surface.find_entities_filtered{
        position = fueler.position,
        radius = 6,
        type = target_type,
    }

    -- exclude targets that are on cooldown for refueling
    -- for the others try refueling them
    for i, target in ipairs(targets) do

        if not model.entity_check(target) then
            goto continue
        end

        if not model.is_on_cooldown(target) then
            model.refuel_target(fueler, target, target_type)
            model.add_cooldown(target)
        end

        ::continue::

    end

end


--GETTERS AND SETTERS
------------------------------------------------------------------------------------------------------

function model.get_target_type(unit)

    -- get the current entity type that this fueler is fueling
    -- if none id given then return the default type (locomotive)

    local target_type = global.ei.fueler[unit].target_type

    if not target_type then
        target_type = model.target_types[1]
    end

    return target_type

end

--REGISTER
------------------------------------------------------------------------------------------------------

function model.register_fueler(entity)

    local unit = entity.unit_number

    model.check_global()
    model.check_queue()

    global.ei.fueler[unit] = {}
    global.ei.fueler[unit].entity = entity

    -- get lenght of queue
    local queue_lenght = #global.ei.fueler_queue
    table.insert(global.ei.fueler_queue, unit)

    -- store the position in the queue
    global.ei.fueler[unit].queue_pos = queue_lenght + 1

end


function model.unregister_fueler(entity)

    local unit = entity.unit_number

    model.check_global()
    model.check_queue()

    
    -- remove the unit from the queue
    local sus_pos = global.ei.fueler[unit].queue_pos

    if global.ei.fueler_queue[sus_pos] == unit then
        table.remove(global.ei.fueler_queue, sus_pos)
    else
        -- if the unit is not at that pos, then check for others
        for i, v in pairs(global.ei.fueler_queue) do
            if v == unit then
                table.remove(global.ei.fueler_queue, i)
            end
        end
    end

    -- delete the entry from storage 
    global.ei.fueler[unit] = nil
    
end

--HANDLERS
------------------------------------------------------------------------------------------------------

function model.on_built_entity(entity)

    if not model.entity_check(entity) then
        return
    end

    if entity.name ~= "ei_fueler" then
        return
    end

    model.register_fueler(entity)

end


function model.on_destroyed_entity(entity)

    if not model.entity_check(entity) then
        return
    end

    if entity.name ~= "ei_fueler" then
        return
    end

    model.unregister_fueler(entity)

end


function model.updater()

    local next_break_point = model.get_break_point()

    if not next_break_point then
        return
    end

    -- update this fueler
    model.update_fueler(next_break_point)


    model.update_cooldowns()

end

return model