--[[ 
    NPC Management Module
    This module provides functionality to create, delete, and manage NPCs in the game world.
    All NPC-related operations are handled through this module.
]]

-- NPC table to hold functions and NPC instances
NPC = {}
NPCs = {}

--[[ 
    NPC.Create
    Creates an NPC at the specified coordinates with the given model and assigns it a name.
    @param coords (table): A table containing x, y, z, and w (heading) coordinates.
    @param model (string): The model name or hash of the NPC to be created.
    @param name (string): A unique identifier for the NPC.
    @return nil
]]
NPC.Create = function(coords, model, name)
    lib.requestModel(model) -- Request the model to be loaded
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, true)
    FreezeEntityPosition(ped, true) -- Freeze the NPC in place
    SetEntityInvincible(ped, true) -- Make the NPC invincible
    SetBlockingOfNonTemporaryEvents(ped, true) -- Prevent the NPC from reacting to events
    NPCs[name] = ped -- Store the NPC in the NPCs table
    return ped
end

--[[ 
    NPC.Delete
    Deletes an NPC by its name.
    @param name (string): The unique identifier of the NPC to be deleted.
    @return nil
]]
NPC.Delete = function(name)
    if NPCs[name] then
        DeleteEntity(NPCs[name]) -- Delete the NPC entity
        NPCs[name] = nil -- Remove the NPC from the table
    end
end

--[[ 
    NPC.DeletALL
    Deletes all NPCs that have been created using this module.
    @return nil
]]
NPC.DeleteAll = function()
    for name, ped in pairs(NPCs) do
        DeleteEntity(ped) -- Delete each NPC entity
        NPCs[name] = nil -- Clear the NPC from the table
    end
end

-- Return the NPC module
return NPC