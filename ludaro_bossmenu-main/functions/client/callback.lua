--[[ 
    Callback Module
    This module provides a set of functions to interact with the server-side callbacks for managing jobs, employees, and society-related operations.
    Each function uses `lib.callback.await` to communicate with the server and retrieve or send data.

    @module Callback
]]

Callback = {}

--- Retrieves the player's current job.
-- @return string The job name of the player.
Callback.GetJob = function()
    return lib.callback.await('l_bossmenu:getJob', false)
end

--- Retrieves the list of employees for a specific job.
-- @param jobName string The name of the job.
-- @return table A list of employees for the specified job.
Callback.GetEmployees = function(jobName)
    return lib.callback.await('l_bossmenu:getEmployees', false, jobName)
end

--- Changes the grade of an employee.
-- @param employeeId number The ID of the employee.
-- @param grade number The new grade to assign.
-- @param jobName string The name of the job.
-- @return boolean True if the grade change was successful, false otherwise.
Callback.AwaitChangeGrade = function(employeeId, grade, jobName)
    return lib.callback.await('l_bossmenu:change_grade', false, employeeId, grade, jobName)
end

--- Retrieves the grades available for a specific job.
-- @param jobName string The name of the job.
-- @return table A list of grades for the specified job.
Callback.GetGrades = function(jobName)
    return lib.callback.await('l_bossmenu:getGrades', false, jobName)
end

--- Fires an employee from a specific job.
-- @param employeeId number The ID of the employee.
-- @param jobName string The name of the job.
-- @return boolean True if the employee was successfully fired, false otherwise.
Callback.AwaitFireEmployee = function(employeeId, jobName)
    return lib.callback.await('l_bossmenu:fire_employee', false, employeeId, jobName)
end

--- Retrieves the name of a player by their ID.
-- @param playerId number The ID of the player.
-- @return string The name of the player.
Callback.GetPlayerName = function(playerId)
    return lib.callback.await('l_bossmenu:getPlayerName', false, playerId)
end

--- Recruits a player to a specific job.
-- @param playerId number The ID of the player.
-- @param jobName string The name of the job.
-- @return boolean True if the player was successfully recruited, false otherwise.
Callback.RecruitPlayer = function(playerId, jobName)
    return lib.callback.await('l_bossmenu:recruit_player', false, playerId, jobName)
end

--- Retrieves the society's money for a specific job.
-- @param jobName string The name of the job.
-- @return number The amount of money in the society's account.
Callback.GetSocietyMoney = function(jobName)
    return lib.callback.await('l_bossmenu:getSocietyMoney', false, jobName)
end

--- Changes the salary for a specific grade in a job.
-- @param jobName string The name of the job.
-- @param grade number The grade to modify.
-- @param salary number The new salary amount.
-- @return boolean True if the salary change was successful, false otherwise.
Callback.ChangeGradeSalary = function(jobName, grade, salary)
    return lib.callback.await('l_bossmenu:change_salary', false, jobName, grade, salary)
end

Callback.GetNameOfPlayer = function(id)
    return lib.callback.await('l_bossmenu:getNameOfPlayer', false, id)
end

return Callback