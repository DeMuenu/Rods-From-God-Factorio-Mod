Radius = 100


function Explode(position, surface)
    local LuaSurface = surface
    local position = position
    --game.print(position)

    local radius = 5  -- The radius of the explosion area
    local ecke1 = {x = position.x - radius, y = position.y -radius}
    local ecke2 = {x = position.x + radius, y = position.y + radius}
    local area = {ecke1, ecke2}

    for x=ecke1.x, ecke2.x do
        for y=ecke1.y, ecke2.y do
            LuaSurface.create_entity({
                name = "explosion",  -- The name of the explosion entity
                position = {x=x, y=y},  -- The position where the explosion should be created
                force = "neutral"  -- The force associated with the entity (optional)
            })
        end
    end


    local entities = LuaSurface.find_entities(area)
    
    for _, entity in pairs(entities) do
        if entity and entity.valid then
            --game.print(entity.name)
            entity.die(nil)
        end
    end
        

end

local function destroyPositionUi(playerIndex)
    local player = game.players[playerIndex]
    local element = player.gui.screen.rod_main_frame
    if element and element.valid then

        player.gui.screen.rod_main_frame.destroy()
        --game.print("Destroyed UI for player " .. playerIndex)

    else
        --game.print("No UI for player " .. playerIndex)
    end
end

function GetStations(stringOrIndex, planet)
    storage.surfaces = storage.surfaces or {}
    local surfaceAndPosList = {}

    for surface_name, surface in pairs(game.surfaces) do
        local surface_index = surface.index
        
        storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
        storage.surfaces[surface_index]["position"] = storage.surfaces[surface_index]["position"] or {x = 0, y = 0}
        --game.print("Surface index: " .. surface_index)
        if storage.surfaces[surface_index]["position"] then
            if surface.platform ~= nil then
                local space_platform = surface.platform
                local current_location = space_platform.space_location

                local dontAdd = false

                if planet ~= nil then
                    game.print("location")
                    game.print("current loc " .. current_location.name)
                    game.print("planet loc" .. planet.name)
                    if current_location.name ~= planet.name then
                        game.print("Not the right planet")
                        dontAdd = true
                    end
                end
            
                if not dontAdd then
                    if stringOrIndex then
                        table.insert(surfaceAndPosList, {"rod.station_list_item", surface.platform.name, storage.surfaces[surface_index]["position"].x, storage.surfaces[surface_index]["position"].y})
                    else
                        table.insert(surfaceAndPosList,  surface_index)
                    end
                end

            end
            
            --game.print("Surface" .. surface_index .. "Coordinates: " .. storage.surfaces[surface_index]["position"].x .. " " .. storage.surfaces[surface_index]["position"].y)
        else
            game.print("Surface" .. surface_index .. " Coordinates not initialized")
        end
        --game.print("Surface index: " .. surface_index)
    end


    return surfaceAndPosList
end

local function ShowPositionUi(player, position, surface)
    
    local playerOB = game.get_player(player)
    local screen_element = playerOB.gui.screen
    storage.players = storage.players or {}
    storage.players[player] = storage.players[player] or {}
    storage.players[player].positionTemp = storage.players[player].positionTemp or {}
    storage.players[player].positionTemp.x = storage.players[player].positionTemp.x or 0
    storage.players[player].positionTemp.y = storage.players[player].positionTemp.y or 0
    storage.players[player].positionTemp.surfaces = storage.players[player].positionTemp.surfaces or {}
    if not screen_element.rod_main_frame then
        local main_frame = screen_element.add{type="frame", name="rod_main_frame", caption={"rod.framePositionMover"}, direction="vertical"}
        main_frame.style.size = {600, 500}
        main_frame.auto_center = true

        local coordinates_frame = main_frame.add{type="frame", name="coordinates", direction="vertical"}
        local cordinates = coordinates_frame.add{type="flow", name="controls_flow", direction="horizontal"}

        cordinates.add{type="label", name="rod_coordinates", caption={"rod.coordinates", position.x, position.y}}


        storage.players[player].positionTemp.x = position.x
        storage.players[player].positionTemp.y = position.y

        local station_frame = main_frame.add{type="frame", name="station_frame", direction="vertical"}
        local station = station_frame.add{type="flow", name="station_flow", direction="vertical"}
        local stations = GetStations(true, surface)
        local stationIndex = GetStations(false, surface)
        --local station_index = GetStations(false, surface)

        if stations and stations[1] ~= nil then
            storage.players[player].positionTemp.surfaces = stationIndex
            station.add{type = "drop-down", name = "station_list", items = stations}
        else
            station.add{type = "label", name = "station_list", caption={"rod.noStations"}}
        end

        


        local reposition_frame = main_frame.add{type="frame", name="content_frame", direction="vertical"}
        local reposition = reposition_frame.add{type="flow", name="controls_flow", direction="horizontal"}

        reposition.add{type="button", name="rod_abort_reposition", caption={"rod.abortReposition"}}
        reposition.add{type="button", name="rod_reposition", caption={"rod.reposition"}}
    else
        --game.print(playerOB.name .. playerOB.index)
        destroyPositionUi(playerOB.index)
    end
end

function Marked_Target(event)
    --game.print(event.item)
    local inRange = false
    if event.item == "RodController" then
        --game.print("Item = " .. game.players[event.player_index].cursor_stack.item.name)
        for _, station in ipairs(GetStations(false, event.surface)) do
            storage.surfaces[station] = storage.surfaces[station] or {}
            storage.surfaces[station]["position"] = storage.surfaces[station]["position"] or {x = 0, y = 0}
            --game.print(station)
            --game.print(game.get_surface(station).name)
            
            local distance = math.sqrt((storage.surfaces[station]["position"].x - event.area.left_top.x)^2 + (storage.surfaces[station]["position"].y - event.area.left_top.y)^2)
            if distance < Radius then
                if game.get_surface(station).find_entities_filtered{name="accumulator"}[1] ~= nil then
                    game.print("Accumulator" .. tostring(game.get_surface(station).find_entities_filtered{name="accumulator"}[1]))
                    Explode(event.area.left_top, event.surface)
                    return
                else
                    game.print("No Launcher found in Space-Station")
                    
                end
                inRange = true
            end
        end
        if not inRange then
            game.print("No Space-Station with launcher found in range")
        end
        
        
        
    end


    if event.item == "OrbitPosTool" then

        
        ShowPositionUi(event.player_index, event.area.left_top, event.surface)
        
    end
end
script.on_event(defines.events.on_player_selected_area, Marked_Target)

function GuiClick(event)
    
    if not event.element or not event.element.valid then
        return
    end
    local name = event.element.name
    --game.print("Element" .. name)


    if name == "rod_reposition" then
        local player_global = game.players[event.player_index]
        storage.players[event.player_index].positionTemp.surfaces = storage.players[event.player_index].positionTemp.surfaces or {}
        --local station_index = GetStations(false)
        --game.print(player_global)
        --game.print(event.player_index)
        local station_index = storage.players[event.player_index].positionTemp.surfaces
        game.print(station_index)
        local surface_index = station_index[player_global.gui.screen.rod_main_frame.station_frame.station_flow.station_list.selected_index] or nil
        game.print(surface_index)
        --surface_index = GetStations(false, game.get_surface(surface_index))

        if surface_index ~= nil then
            game.print("Repositioning Surface: ".. surface_index .. game.get_surface(surface_index).name)
            storage.surfaces[surface_index]["position"].x = storage.players[event.player_index].positionTemp.x
            storage.surfaces[surface_index]["position"].y = storage.players[event.player_index].positionTemp.y
            destroyPositionUi(event.player_index)
        else
            game.print("No station selected or no station available")
        end
    end

    if name == "rod_abort_reposition" then
        --game.print("exiting")
        destroyPositionUi(event.player_index)
    end

end
script.on_event(defines.events.on_gui_click, GuiClick)



function RangeIndication(event)
    local player = game.players[event.player_index]
    local cursor_stack = player.cursor_stack

    storage.players = storage.players or {}
    storage.players[event.player_index] = storage.players[event.player_index] or {}
    storage.players[event.player_index].ShowOrbitalOverlay = storage.players[event.player_index].ShowOrbitalOverlay or false

    if cursor_stack and cursor_stack.valid_for_read then
        if cursor_stack.item and cursor_stack.item.name then
            local itemHand = cursor_stack.item.name
            game.print("Item = " .. itemHand)
            if itemHand == "OrbitPosTool" or itemHand == "RodController" then
                storage.players[event.player_index].ShowOrbitalOverlay = true
            else
                storage.players[event.player_index].ShowOrbitalOverlay = false
            end
        
        else
            storage.players[event.player_index].ShowOrbitalOverlay = false
        end
    else
        storage.players[event.player_index].ShowOrbitalOverlay = false
        
    end
    game.print(storage.players[event.player_index].ShowOrbitalOverlay)


end
script.on_event(defines.events.on_player_cursor_stack_changed, RangeIndication)

function OnTick(event)
    
    for _, playerIndex in pairs(game.players) do

        storage.players = storage.players or {}
        storage.players[playerIndex] = storage.players[playerIndex] or {}
        storage.players[playerIndex].ShowOrbitalOverlay = storage.players[playerIndex].ShowOrbitalOverlay or false


        playerIndex = playerIndex.index
        if storage.players[playerIndex] and storage.players[playerIndex].ShowOrbitalOverlay then
            if storage.players[playerIndex].ShowOrbitalOverlay == true then
                for _, station in ipairs(GetStations(false)) do
                    storage.surfaces[station] = storage.surfaces[station] or {}
                    storage.surfaces[station]["position"] = storage.surfaces[station]["position"] or {x = 0, y = 0}
                    --game.print(station)
                    --game.print(game.get_surface(station).platform.name)
                    local position = {storage.surfaces[station]["position"].x, storage.surfaces[station]["position"].y}
                    game.print("Station name:")
                    if game.get_surface(station).platform and game.get_surface(station).platform.space_location and game.get_surface(station).platform.space_location.name then
                        game.print(game.get_surface(station).platform.space_location.name)
                        local orbitingPlanet = game.get_surface(game.get_surface(station).platform.space_location.name)
                        if orbitingPlanet then
                            game.print(orbitingPlanet)
                            rendering.draw_circle{color = {r = 0.5, g = 0, b = 0, a = 0.1}, filled=true, radius = Radius, target = position, surface = orbitingPlanet, time_to_live = 60, only_in_alt_mode = false}
                            rendering.draw_text{text = game.get_surface(station).platform.name, surface = orbitingPlanet, color = {r = 1, g = 1, b = 1, a = 1}, target = position, scale=10, time_to_live = 60, only_in_alt_mode = false}
                        end
                    end

                end
                
                
            end
        end
        
    end
end
script.on_nth_tick(60, OnTick)

