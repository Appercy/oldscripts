--[[ 
    This file handles the initialization of the framework, NPC management, 
    and blip creation for ESX Legacy. It includes event handlers for player joining 
    and resource stopping.

    @file init.lua
    @description Handles framework initialization, NPC cleanup, and blip creation.
]]

-- Import required modules
Framework = require("functions.shared.framework") -- Framework module for shared functionality
NPC = require("functions.client.npc") -- NPC module for managing NPCs

-- Initialize the framework
Framework.init()

--[[ 
    Event: esx:onPlayerJoined
    Triggered when a player joins the server.
    Creates blips for the player.

    @event esx:onPlayerJoined
    @triggeredBy ESX framework when a player joins
]]
AddEventHandler("esx:onPlayerJoined", function()
    -- Blips erstellen (Create blips)
    Blips:CreateBlips()
end)

--[[ 
    Event: onResourceStop
    Triggered when the resource is stopped.
    Deletes all NPCs to ensure cleanup.

    @event onResourceStop
    @param resourceName (string) The name of the resource being stopped
]]
AddEventHandler("onResourceStop", function(resourceName)
    -- Überprüfen, ob das aktuelle Resource gestoppt wird (Check if the current resource is being stopped)
    if (GetCurrentResourceName() == resourceName) then
        -- Alle NPCs löschen (Delete all NPCs)
        NPC.DeleteAll()
    end
end)