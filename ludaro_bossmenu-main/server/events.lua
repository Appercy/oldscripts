--[[ 
   @module SQL
   @description This module handles SQL-related operations for the server.
]]
local SQL = require("functions.server.sql")

--[[ 
   @event l_bossmenu:refreshJob
   @description This event updates the job and grade of a player in the database.
   @param identifier (string) - The unique identifier of the player (e.g., Steam ID).
   @param grade (number) - The new grade level to assign to the player.
   @param job (string) - The new job to assign to the player.
   @usage TriggerEvent('l_bossmenu:refreshJob', identifier, grade, job)
]]
RegisterNetEvent('l_bossmenu:refreshJob', function(identifier, grade, job)
   -- Update the player's job and grade in the database
   SQL.SetGrade(identifier, grade, job)
   -- Notify the user in German
end)