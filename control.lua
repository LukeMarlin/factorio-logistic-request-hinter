function fill_request_table(player, requests)

    if requests["fulfilling"] == nil and requests["cant_fulfill"] == nil then
        if global[player.index] ~= nil then
           global[player.index].visible = false
        end
        return
    else
       global[player.index].visible = true
    end

    if global[player.index].children ~= nil then
        global[player.index].children[1].clear()
    end


    for type, items in pairs(requests) do

        if type == "fulfilling" then
            style = "fulfilling_slot"
        else
            style = "cant_fulfill_slot"
        end

        for name, qty in pairs(items) do
            global[player.index].children[1].add{type="sprite-button", sprite="item/" .. name, number=qty, style=style, enabled=false}
        end
    end
end

function create_hinter_gui(player)

    if settings.get_player_settings(player)["logistic-request-hinter-ui-position"].value == "top" then
        global[player.index] = player.gui.top.add{type="frame", name="logistic_request_hinter"}
    else
        global[player.index] = player.gui.left.add{type="frame", name="logistic_request_hinter"}
    end

    if settings.get_player_settings(player)["logistic-request-hinter-show-frame-caption"].value then
        global[player.index].caption = "Logistic requests"
    end

    global[player.index].visible = false
    global[player.index].add{type="table", column_count=settings.get_player_settings(player)["logistic-request-hinter-column-count"].value}

end

function init(player)
    if global["vars"] == nil then
        global["vars"] = {}
    end

    if global["vars"][player.index] == nil then
        global["vars"][player.index] = {}
    end
    if global["vars"][player.index]["disable_ui"] == nil then
        global["vars"][player.index]["disable_ui"] = false
    end
end

function is_gui_outdated(player)
    local player_settings = settings.get_player_settings(player)
    return player_settings["logistic-request-hinter-ui-position"].value == "top" and not is_top
        or player_settings["logistic-request-hinter-ui-position"].value == "left" and is_top
        or global[player.index].children[1].column_count ~= player_settings["logistic-request-hinter-column-count"].value
        or global[player.index].caption ~= "" and not player_settings["logistic-request-hinter-show-frame-caption"].value
        or global[player.index].caption == "" and player_settings["logistic-request-hinter-show-frame-caption"].value
end

function process_player(player)
    if global[player.index] == nil then
    -- We have no reference to the UI but it might be there, trying to get it
        if settings.get_player_settings(player)["logistic-request-hinter-ui-position"].value == "top" then
            global[player.index] = player.gui.top.logistic_request_hinter
        else
            global[player.index] = player.gui.left.logistic_request_hinter
        end
    end

    if global[player.index] == nil then
    -- It does not exist at all, creating it
        create_hinter_gui(player)
    else
    -- We found an existing reference, replacing it if necessary based on settings (that might have changed since then)
        is_top = global[player.index].parent == player.gui.top
        if is_gui_outdated(player) then
            -- Misplaced or incorrectly sized, destroying it and restart processing
            global[player.index].destroy()
            global[player.index] = nil
            return process_player(player)
        end
    end

    character = player.character

    if character == nil then return end

    logistic_slots = character.get_logistic_point()
    player_logistic_requester = logistic_slots[1]

    if player_logistic_requester == nil then
        return
    end

    filters = player_logistic_requester.filters
    network = character.force.find_logistic_network_by_position(player.position, player.surface)
    if network == nil or filters == nil then
        global[player.index].visible = false
        return
    end

    main_inventory = character.get_main_inventory().get_contents()
    guns = character.get_inventory(defines.inventory.character_guns).get_contents()
    ammo = character.get_inventory(defines.inventory.character_ammo).get_contents()
    armor = character.get_inventory(defines.inventory.character_armor).get_contents()
    on_the_way_items = player_logistic_requester.targeted_items_deliver

    -- Looking into player inventories and checking its
    -- current logistic request to see what is missing
    needed_items = {}
    for _, filter in ipairs(filters) do
        item_name = filter.name
        missing_qty = filter.count
        missing_qty = missing_qty - (main_inventory[item_name] or 0)
        missing_qty = missing_qty - (guns[item_name] or 0)
        missing_qty = missing_qty - (ammo[item_name] or 0)
        missing_qty = missing_qty - (armor[item_name] or 0)
        if player.cursor_stack.valid_for_read and player.cursor_stack.name == item_name then
            missing_qty = missing_qty - player.cursor_stack.count
        end

        if missing_qty > 0 then
            needed_items[item_name] = missing_qty
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
        if e.tick % 150 == 0 then -- Run once every 2.5 seconds
            for _, player in pairs(game.connected_players) do
                init(player)
                if global["vars"][player.index]["disable_ui"] or not player.character_personal_logistic_requests_enabled then -- player requested to disable the UI, we completely skip the processing
                    if global[player.index] ~= nil then
                        global[player.index].visible = false
                    end
                else
                    process_player(player)
                end
            end
        end
    end
)

script.on_event("hide-hinter-gui",
    function(event)
        disable_gui(event.player_index)
    end
)

function disable_gui(player_index)
    disabled_by_player = global["vars"][player_index]["disable_ui"]
    if disabled_by_player then
        global["vars"][player_index]["disable_ui"] = false
    else
        global["vars"][player_index]["disable_ui"] = true
    end

    -- make the action immediate instead of waiting for next trigger
    if global[player_index] ~= nil then
        global[player_index].visible = not global["vars"][player_index]["disable_ui"]
    end
end