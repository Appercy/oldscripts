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
Framework.init = function()
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

--- Assigns a job to a player using their source ID.
--- @param id number The player's source ID.
--- @param job string The job name to assign.
--- @return boolean True if the job was assigned, false otherwise.
Framework.Server.RecruitPlayer = function(id, job)
    local player = Framework.Server.GetPlayer(id, nil)
  --  print(tostring(player), tostring(SQL.HasJob(job, player.getIdentifier()), tostring(job)))
    if player and SQL.HasJob(job, player.getIdentifier()) == false then
        player.setJob(job, 0)
        return true
    end
    return false
end

--- Retrieves the job of a player using their source or identifier.
--- @param source number | nil The player's source ID.
--- @param identifier string | nil The player's identifier.
--- @return table | nil The player's job or nil if not found.
Framework.Server.GetJob = function(source, identifier)
    local player = Framework.Server.GetPlayer(source, identifier)
    if player then
        return player.getJob()
    end
    return nil
end

--- Changes the grade of a player in their current job.
--- @param identifier string The player's identifier.
--- @param grade number The new grade to assign.
--- @param job string The job name (used for event triggering).
--- @return boolean Always returns true.
Framework.Server.ChangeGradeofPlayer = function(identifier, grade, job)
   -- print(identifier, grade, job)
    local player = Framework.Server.GetPlayer(identifier, identifier)
    if player then
       print(tostring(player.getJob().name), tostring(grade))
        player.setJob(player.getJob().name, grade)
    end
    TriggerEvent("l_bossmenu:refreshJob", identifier, grade, job)
    return true
end

Framework.Server.RefreshJobs = function()
    ESX.RefreshJobs()
end

--========================================--
--              CLIENT FUNCTIONS          --
--========================================--

Framework.Client = {}

--- Displays a help notification to the player.
--- @param msg string The message to display.
--- @return void
Framework.Client.ShowHelpNotification = function(msg)
    if msg then
        lib.showTextUI(msg)
    end
end

--- Hides the currently displayed help notification.
--- @return void
Framework.Client.HideHelpNotification = function()
    lib.hideTextUI()
end

--- Displays a notification to the player.
--- @param msg string The message to display.
--- @return void
Framework.Client.ShowNotification = function(msg)
    if msg then
        lib.notify({
            title = 'bossmenu',
            description = msg,
            type = 'success'
        })
    end
end

-- Return the Framework table for use in other scripts
return Framework
