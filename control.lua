--hinter_gui.destroy()
--hinter_gui = nil

function fill_request_table(player, requests)

    if requests["fulfilling"] == nil and requests["cant_fulfill"] == nil then
        if hinter_gui ~= nil then
            hinter_gui.style.visible = false
        end
        return
    else
        hinter_gui.style.visible = true
    end

    if hinter_gui.children ~= nil then
        hinter_gui.children[1].clear()
    end


    for type, items in pairs(requests) do

        if type == "fulfilling" then
            style = "fulfilling_slot"
        else
            style = "cant_fulfill_slot"
        end

        for name, qty in pairs(items) do
            hinter_gui.children[1].add{type="sprite-button", sprite="item/" .. name, number=qty, style=style, enabled=false}
        end
    end
end

function process_player(player)

    if hinter_gui == nil then
        hinter_gui = player.gui.top.logistic_request_hinter
    end

    if hinter_gui == nil then
        hinter_gui = player.gui.top.add{type="frame", name="logistic_request_hinter"}
        hinter_gui.style.visible = false
        hinter_gui.add{type="table", column_count=10}
    end

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
                if player.cursor_stack.valid_for_read and player.cursor_stack.name == item_name then
                    missing_qty = missing_qty - player.cursor_stack.count
                end

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
                else
                    if request_statuses["cant_fulfill"] == nil then request_statuses["cant_fulfill"] = {} end
                    request_statuses["cant_fulfill"][item_name] = item_qty
                end
            end

            fill_request_table(player, request_statuses)
        else
            hinter_gui.style.visible = false
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