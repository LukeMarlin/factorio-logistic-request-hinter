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

function create_hinter_gui(player)

    if settings.get_player_settings(player)["logistic-request-hinter-ui-position"].value == "top" then
        hinter_gui = player.gui.top.add{type="frame", name="logistic_request_hinter"}
    else
        hinter_gui = player.gui.left.add{type="frame", name="logistic_request_hinter"}
    end

    if settings.get_player_settings(player)["logistic-request-hinter-show-frame-caption"].value then
        hinter_gui.caption = "Logistic requests"
    end

    hinter_gui.style.visible = false
    hinter_gui.add{type="table", column_count=settings.get_player_settings(player)["logistic-request-hinter-column-count"].value}
end

function is_gui_outdated(player_settings)
    return player_settings["logistic-request-hinter-ui-position"].value == "top" and not is_top
        or player_settings["logistic-request-hinter-ui-position"].value == "left" and is_top
        or hinter_gui.children[1].column_count ~= player_settings["logistic-request-hinter-column-count"].value
        or hinter_gui.caption ~= "" and not player_settings["logistic-request-hinter-show-frame-caption"].value
        or hinter_gui.caption == "" and player_settings["logistic-request-hinter-show-frame-caption"].value
end

function process_player(player)

    if hinter_gui == nil then
    -- We have no reference to the UI but it might be there, trying to get it
        if settings.get_player_settings(player)["logistic-request-hinter-ui-position"].value == "top" then
            hinter_gui = player.gui.top.logistic_request_hinter
        else
            hinter_gui = player.gui.left.logistic_request_hinter
        end
    end

    
    if hinter_gui == nil then
    -- It does not exist at all, creating it
        create_hinter_gui(player)
    else
    -- We found an existing reference, replacing it if necessary based on settings (that might have changed since then)
        is_top = hinter_gui.parent == player.gui.top
        if is_gui_outdated(settings.get_player_settings(player)) then
            -- Misplaced or incorrectly sized, destroying it and restart processing
            hinter_gui.destroy()
            hinter_gui = nil
            return process_player(player)
        end
    end

    character = player.character

    if character == nil then return end

    logistic_slots = character.get_logistic_point()
    player_logistic_requester = logistic_slots[1] --TODO: check if exists
    filters = player_logistic_requester.filters
    network = character.force.find_logistic_network_by_position(player.position, player.surface)
    if network == nil or filters == nil then
        hinter_gui.style.visible = false
        return
    end

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