--========================================--
--                                        --
--              FRAMEWORK                 --
--                                        --
--========================================--

-- Framework table to hold all framework-related functions and data
Framework = {}

--========================================--
--              INITIALIZATION            --
--========================================--

--- Initializes the framework by checking if `es_extended` is started.
--- If it is, retrieves the shared object for ESX.
--- @return void
Framework.Init = function()
    if GetResourceState("es_extended") == "started" then
        if exports["es_extended"] and exports["es_extended"].getSharedObject then
            ESX = exports["es_extended"]:getSharedObject()
        else
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        end
    end
end


--========================================--
--              SERVER FUNCTIONS          --
--========================================--

Framework.Server = {}

--- Retrieves a player object using their source or identifier.
--- @param source number | nil The player's source ID.
--- @param identifier string | nil The player's identifier.
--- @return table | nil The player object or nil if not found.
Framework.Server.GetPlayer = function(source, identifier)
    if source then
        local player = ESX.GetPlayerFromId(source)
        if player then
            return player
        end
    else
        local player = ESX.GetPlayerFromIdentifier(identifier)
        if player then
            return player
        end
    end
    return nil
end

--- Retrieves the name of a player using their source or identifier.
--- @param id number | nil The player's source ID.
--- @param identifier string | nil The player's identifier.
--- @return string The player's name or "NAME NICHT GEFUNDEN" if not found.
Framework.Server.GetPlayerName = function(id, identifier)
    local player = Framework.Server.GetPlayer(id, identifier)
    if player then
        return player.getName()
    end
    return "NAME NICHT GEFUNDEN"
end

Framework.Server.GetIdentifier = function(source)
    local player = Framework.Server.GetPlayer(source)
    if player then
        return player.getIdentifier()
    end
    return nil
end

Framework.Server.GetJob = function(source)
    local player = Framework.Server.GetPlayer(source)
    if player then
        return player.getJob()
    end
    return nil
end

Framework.Server.SetJob = function(source, job, grade)
    local player = Framework.Server.GetPlayer(source)
    if player then
        player.setJob(job, grade)
    end
end

Framework.Server.showNotification = function(source, msg)
    local player = Framework.Server.GetPlayer(source)
    if player then
        player.showNotification(msg)
    end
end

Framework.Server.RefreshJobs = function()
    ESX.RefreshJobs()
end


Framework.Client = {}

Framework.Client.ShowNotification = function(msg)
   ESX.ShowNotification(msg)
end
-- Return the Framework table for use in other scripts
return Framework
