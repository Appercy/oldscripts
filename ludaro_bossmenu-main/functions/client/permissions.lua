--[[ 
    Permission Module
    This module handles permission checks for jobs and grades in the ESX framework.
    It provides utility functions to determine if a user has specific permissions or can access the menu.

    @module Permission
]]

-- Dependencies
local Callback = require("functions.client.callback")
local Framework = require("functions.shared.framework")

-- Permission Table
local Permission = {}

--- Checks if a user has a specific permission.
-- This function verifies if the user's job and grade allow the specified permission.
-- It also considers the `max` flag for higher grades.
-- @param permission (string) The permission to check.
-- @return (boolean) True if the user has the permission, false otherwise.
Permission.IsAllowed = function(permission)
    local job, grade = Callback.GetJob()

    -- Check if the job and grade exist in the configuration
    if Config.Locations[job] and Config.Locations[job].permissions[grade] then
        local gradePermissions = Config.Locations[job].permissions[grade]

        -- Iterate through all grades to check for the `max` flag
        for g, perms in pairs(Config.Locations[job].permissions) do
            if perms.max and g <= grade then
                -- Return true unless the permission is explicitly overridden
                return perms[permission] ~= false
            end
        end

        -- Return the specific permission if no `max` is found
        return gradePermissions[permission] or false
    end

    -- Default to false if no permissions are found
    return false
end

--- Checks if the user can open the menu.
-- This function determines if the user has any permissions or if their grade is above the `max` threshold.
-- @return (boolean) True if the user can open the menu, false otherwise.
Permission.CanOpenMenu = function()
    local job, grade = Callback.GetJob()

    -- Check if the job and grade exist in the configuration
    if Config.Locations[job] and Config.Locations[job].permissions[grade] then
        -- Iterate through all permissions for the grade
        for permission, hasPermission in pairs(Config.Locations[job].permissions[grade]) do
            if hasPermission then
                return true
            end
        end
    end

    -- Check if the grade is above the `max` threshold
    if Config.Locations[job] then
        for g, perms in pairs(Config.Locations[job].permissions) do
            if perms.max and g <= grade then
                return true
            end
        end
    end

    -- Default to false if no conditions are met
    return false
end

-- Return the Permission module
return Permission
