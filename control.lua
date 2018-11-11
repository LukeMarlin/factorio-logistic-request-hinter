if global["hinter_gui"] == nil then global["hinter_gui"] = {} end
hinter_frame_captions = {fulfilling = "Being fulfilled", cant_fulfill = "Can't fulfill"}

function fill_request_table(player, type, requests)

    if type == "fulfilling" then
        style = "fulfilling_slot"
    else
        style = "cant_fulfill_slot"
    end

    if global["hinter_gui"][type] == nil then
        global["hinter_gui"][type] = player.gui.top.add{type="frame", caption=hinter_frame_captions[type]}
        global["hinter_gui"][type].add{type="table", column_count=5}
    else
        global["hinter_gui"][type].children[1].clear()
    end

    for name, qty in pairs(requests) do
        global["hinter_gui"][type].children[1].add{type="sprite-button", sprite="item/" .. name, number=qty, style=style, enabled=false}
    end
end

function process_player(player)

    character = player.character
    if character ~= nil then
        logistic_slots = character.get_logistic_point()
        player_logistic_requester = logistic_slots[1] --TODO: check if exists
        filters = player_logistic_requester.filters
        network = character.force.find_logistic_network_by_position(player.position, player.surface)
        if network ~= nil and filters ~= nil then

            quickbar = character.get_quickbar().get_contents()
            main_inventory = character.get_main_inventory().get_contents()
            guns = character.get_inventory(defines.inventory.player_guns).get_contents()
            ammo = character.get_inventory(defines.inventory.player_ammo).get_contents()
            tools = character.get_inventory(defines.inventory.player_armor).get_contents()
            armor = character.get_inventory(defines.inventory.player_tools).get_contents()
            on_the_way_items = player_logistic_requester.targeted_items_deliver

            -- Looking into player inventories and checking its
            -- current logistic request to see what is missing
            needed_items = {}
            for _, filter in ipairs(filters) do
                item_name = filter.name
                missing_qty = filter.count
                missing_qty = missing_qty - (quickbar[item_name] or 0)
                missing_qty = missing_qty - (main_inventory[item_name] or 0)
                missing_qty = missing_qty - (guns[item_name] or 0)
                missing_qty = missing_qty - (ammo[item_name] or 0)
                missing_qty = missing_qty - (tools[item_name] or 0)
                missing_qty = missing_qty - (armor[item_name] or 0)
                --TODO: AJOUTER INVENTAIRE "DANS LA MAIN"
                if missing_qty > 0 then
                    needed_items[item_name] = missing_qty
                    --player.print(item_name .. ": " .. needed_items[item_name])
                end
            end

            local request_statuses = {}

            -- Now that we know what's needed, let's see if the
            -- player is in a network and what that network offers
            for item_name, item_qty in pairs(needed_items) do
                remaining = item_qty
                remaining = remaining - (on_the_way_items[item_name] or 0)
                remaining = remaining - (network.get_item_count(item_name) or 0)
                if remaining <= 0 then
                    if request_statuses["fulfilling"] == nil then request_statuses["fulfilling"] = {} end
                    request_statuses["fulfilling"][item_name] = item_qty
                    --player.print("Putting in ffing")
                    --player.print("Request for item '" .. item_name .. "' is being fulfilled, just wait there!")
                else
                    if request_statuses["cant_fulfill"] == nil then request_statuses["cant_fulfill"] = {} end
                    request_statuses["cant_fulfill"][item_name] = item_qty
                    --player.print("Putting in cff")
                    --player.print("Cannot fulfill request for item '" .. item_name .. "', missing " .. item_qty)
                end
            end

            if request_statuses["fulfilling"] ~= nil then
                fill_request_table(player, "fulfilling", request_statuses["fulfilling"], fulfilling_count)
            else
                if global["hinter_gui"]["fulfilling"] ~= nil then
                    global["hinter_gui"]["fulfilling"].destroy()
                    global["hinter_gui"]["fulfilling"] = nil
                end
            end
            if request_statuses["cant_fulfill"] ~= nil then
                fill_request_table(player, "cant_fulfill", request_statuses["cant_fulfill"], cant_fulfill_count)
            else
                if global["hinter_gui"]["cant_fulfill"] ~= nil then 
                    global["hinter_gui"]["cant_fulfill"].destroy()
                    global["hinter_gui"]["cant_fulfill"] = nil
                end
            end

            --player.print(gui.help())
            --for item_name, item_qty in pairs(requested_items) do
            --    player.print{"", item_name .. item_qty}
            --end
        else
            if global["hinter_gui"]["cant_fulfill"] ~= nil then global["hinter_gui"]["cant_fulfill"].destroy() end
            if global["hinter_gui"]["fulfilling"] ~= nil then global["hinter_gui"]["fulfilling"].destroy() end
            global["hinter_gui"] = {}
        end
    end
end

script.on_event({defines.events.on_tick},
    function (e)
        if e.tick % 150 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just once per 2.5 second
            for _, player in pairs(game.connected_players) do  --loop through all online players on the server
                process_player(player)
            end
        end
    end
)

--player_index :: uint: The player.
--gui_type :: defines.gui_type: The GUI type that was open.
--entity :: LuaEntity (optional): The entity that was open
--item :: LuaItemStack (optional): The item that was open
--equipment :: LuaEquipment (optional): The equipment that was open
--other_player :: LuaPlayer (optional): The other player that was open
--element :: LuaGuiElement (optional): The custom GUI element that was open