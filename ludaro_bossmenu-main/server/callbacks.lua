--[[ 
    l_bossmenu Server Callbacks
    This script handles various server-side callbacks for the boss menu system.
    Each callback is registered using `lib.callback.register` and interacts with the framework, SQL, or society modules.

    @module l_bossmenu
]]

-- Import required modules
local Framework = require("functions.shared.framework")
local SQL = require("functions.server.sql")
local Society = require("functions.server.society")

--[[ 
    Callback: l_bossmenu:getJob
    Retrieves the job and grade of the player.

    @param source [number] - The player's source ID.
    @param cb [function] - The callback function.
    @return [string, number] - The job name and grade.
]]
lib.callback.register('l_bossmenu:getJob', function(source, cb)
    local job = Framework.Server.GetJob(source)
    return job.name, job.grade
end)

--[[ 
    Callback: l_bossmenu:getEmployees
    Retrieves a list of employees for the specified job.

    @param source [number] - The player's source ID.
    @param job [string] - The job name (optional).
    @return [table] - A list of employees.
]]
lib.callback.register('l_bossmenu:getEmployees', function(source, job)
    return SQL.GetEmployees(job or Framework.Server.GetJob(source).name)
end)

--[[ 
    Callback: l_bossmenu:change_grade
    Changes the grade of a specific player.

    @param source [number] - The player's source ID.
    @param id [number] - The target player's ID.
    @param grade [number] - The new grade.
    @param job [string] - The job name.
    @return [boolean] - Whether the grade change was successful.
]]
lib.callback.register('l_bossmenu:change_grade', function(source, id, grade, job)
    return Framework.Server.ChangeGradeofPlayer(id, grade, job)
end)

--[[ 
    Callback: l_bossmenu:getGrades
    Retrieves all grades for a specific job.

    @param source [number] - The player's source ID.
    @param job [string] - The job name.
    @return [table] - A list of grades.
]]
lib.callback.register('l_bossmenu:getGrades', function(source, job)
    return SQL.GetGrades(job)
end)

--[[ 
    Callback: l_bossmenu:fire_employee
    Fires an employee from a specific job.

    @param source [number] - The player's source ID.
    @param id [number] - The target player's ID.
    @param job [string] - The job name.
    @return [boolean] - Whether the employee was successfully fired.
]]
lib.callback.register('l_bossmenu:fire_employee', function(source, id, job)
    return SQL.FireEmployee(id, job)
end)

--[[ 
    Callback: l_bossmenu:getPlayerName
    Retrieves the name of a specific player.

    @param source [number] - The player's source ID.
    @param id [number] - The target player's ID.
    @return [string] - The player's name.
]]
lib.callback.register('l_bossmenu:getPlayerName', function(source, id)
    return Framework.Server.GetPlayerName(id)
end)

--[[ 
    Callback: l_bossmenu:recruit_player
    Recruits a player to a specific job.

    @param source [number] - The player's source ID.
    @param id [number] - The target player's ID.
    @param job [string] - The job name.
    @return [boolean] - Whether the player was successfully recruited.
]]
lib.callback.register('l_bossmenu:recruit_player', function(source, id, job)
    return Framework.Server.RecruitPlayer(id, job)
end)

--[[ 
    Callback: l_bossmenu:getSocietyMoney
    Retrieves the amount of money in a society's account.

    @param source [number] - The player's source ID.
    @param job [string] - The job name.
    @return [number] - The amount of money in the society's account.
]]
lib.callback.register('l_bossmenu:getSocietyMoney', function(source, job)
    return Society.GetMoney(job)
end)

--[[ 
    Callback: l_bossmenu:change_salary
    Changes the salary for a specific grade in a job.

    @param source [number] - The player's source ID.
    @param job [string] - The job name.
    @param grade [number] - The grade level.
    @param salary [number] - The new salary amount.
    @return [boolean] - Whether the salary change was successful.
]]
lib.callback.register('l_bossmenu:change_salary', function(source, job, grade, salary)
    return SQL.ChangeSalary(job, grade, salary)
end)

lib.callback.register('l_bossmenu:getNameOfPlayer', function(source, id)
    return Framework.Server.GetPlayerName(id)
end)