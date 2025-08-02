--[[ 
    @file points.lua
    @description Handles the creation of interaction points, NPCs, and markers for the ESX Legacy framework.
    @dependencies Requires 'functions.shared.framework', 'functions.client.npc', and 'functions.client.menu'.
]]

-- Import required modules
Framework = require('functions.shared.framework')
NPC = require('functions.client.npc')
Menu = require('functions.client.menu')

-- Iterate through all configured locations
for locationName, locationData in pairs(Config.Locations) do
    if locationData.coords then
        
        -- Create a new interaction point
        local interactionPoint = lib.points.new({
            Debug = Config.Debug,
            npc = (locationData.ped and locationData.ped.model and locationData.ped.coords) and locationData.ped or nil,
            name = locationName,
            coords = locationData.coords,
            distance = locationData.distance or 5.0
        })

        -- Create a marker if configured
        local marker
        if locationData.marker then
            marker = lib.marker.new({
                type = locationData.marker.type or 1,
                coords = vector3(locationData.coords.x, locationData.coords.y, locationData.coords.z) + 
                         (locationData.marker.offset or vector3(0.0, 0.0, 0.0)),
                scale = locationData.marker.scale or vector3(0.5, 0.5, 0.5),
                color = locationData.marker.color or {r = 0, g = 0, b = 100, a = 255},
                direction = locationData.marker.direction or vector3(0.0, 0.0, 0.0),
                rotation = locationData.marker.rotation or vector3(0.0, 0.0, 0.0),
                width = locationData.marker.width or 2.5,
                height = locationData.marker.height or 2.5,
            })
        end

        --[[ 
            @function onEnter
            @description Triggered when the player enters the interaction point.
            @context Interaction point object.
        ]]
        function interactionPoint:onEnter()
            if self.npc then
                npc = NPC.Create(self.npc.coords, self.npc.model, self.name)
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addLocalEntity(npc, {
                        {
                            name = self.name .. '_menu',
                            label = 'Boss Menü Öffnen',
                            icon = 'fa-solid fa-briefcase',
                            onSelect = function()
                                Menu.Open(self.name)
                            end
                        }
                    })
                end
                
            end
            lib.print.verbose("In der Nähe von " .. self.name)
            Framework.Client.ShowHelpNotification("Drücke E zum öffnen des Boss-Menüs")
        end

        --[[ 
            @function onExit
            @description Triggered when the player exits the interaction point.
            @context Interaction point object.
        ]]
        function interactionPoint:onExit()
            if self.npc then
                NPC.Delete(self.name)
            end
            lib.print.verbose("Nicht mehr in der Nähe von " .. self.name)
            Framework.Client.HideHelpNotification()
        end

        --[[ 
            @function nearby
            @description Continuously called while the player is near the interaction point.
            @context Interaction point object.
        ]]
        function interactionPoint:nearby()
            if marker then
                marker:draw()
            end
            if IsControlJustReleased(0, 38) then -- Key 38 (E) is pressed
                CreateThread(function()
                    Menu.Open(self.name)
                end)
            end
        end
    end
end
