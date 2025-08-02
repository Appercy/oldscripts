-- SQL Module
-- This module provides various SQL-related functions for managing jobs, employees, and grades in the system.

SQL = {}
Framework = require("functions.shared.framework")

--- Fetches the label of a specific job grade.
-- @param grade The grade level to fetch.
-- @param job The job name to fetch the grade for.
-- @return The label of the grade, or nil if not found.
local function GetGradeLabel(grade, job)
    local result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE grade = @grade AND job_name = @job', {
        ['@grade'] = grade,
        ['@job'] = job
    })

    if result[1] then
        return result[1].label
    else
        return nil
    end
end

--- Fetches all employees for a specific job.
-- @param job The job name to fetch employees for.
-- @return A table of employees and their details.
SQL.GetEmployees = function(job)
    local employees = {}

    -- Fetch employees from the users table
    local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE job = @job', {
        ['@job'] = job
    })

    for i = 1, #result do
        local PlayerData = Framework.Server.GetPlayer(nil, result[i].identifier)

        if PlayerData ~= nil then
            table.insert(employees, {
                id = result[i].identifier,
                name = PlayerData.getName(),
                job = PlayerData.job.name,
                grade = PlayerData.job.grade,
                grade_label = PlayerData.job.grade_label,
                multijob = false
            })
        else
            table.insert(employees, {
                id = result[i].identifier,
                name = result[i].firstname .. " " .. result[i].lastname,
                job = job,
                grade = result[i].job_grade,
                grade_label = GetGradeLabel(result[i].job_grade, job),
                multijob = false
            })
        end
    end

    -- Fetch employees from the multijob table
    local multijobresult = MySQL.Sync.fetchAll('SELECT * FROM multijob')

    for _, v in ipairs(multijobresult) do
        local jobs = json.decode(v.jobs)
        if jobs[job] then
            -- Check if the user is already added from the users table
            local alreadyAdded = false
            for _, employee in ipairs(employees) do
                if employee.id == v.id then
                    alreadyAdded = true
                    break
                end
            end

            if not alreadyAdded then
                local user = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @id', {
                    ['@id'] = v.id
                })

                if user[1] then
                    table.insert(employees, {
                        id = v.id,
                        name = user[1].firstname .. " " .. user[1].lastname,
                        job = job,
                        grade = jobs[job].grade,
                        grade_label = jobs[job].gradeLabel,
                        multijob = true
                    })
                end
            end
        end
    end

    return employees
end

--- Fetches all grades for a specific job.
-- @param job The job name to fetch grades for.
-- @return A table of grades and their details.
SQL.GetGrades = function(job)
    local grades = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = @job', {
        ['@job'] = job
    })

    for i = 1, #result do
        table.insert(grades, {
            name = result[i].label,
            grade = result[i].grade,
            label = result[i].label,
            salary = result[i].salary
        })
    end

    return grades
end

--- Changes the salary for a specific job grade.
-- @param job The job name.
-- @param grade The grade level.
-- @param salary The new salary to set.
-- @return true if the operation was successful.
SQL.ChangeSalary = function(job, grade, salary)
    MySQL.Sync.execute('UPDATE job_grades SET salary = @salary WHERE job_name = @job AND grade = @grade', {
        ['@salary'] = salary,
        ['@job'] = job,
        ['@grade'] = grade
    })
    Framework.Server.RefreshJobs()
    return true
end

--- Sets the grade for a specific employee.
-- @param identifier The identifier of the employee.
-- @param grade The new grade to set.
-- @param job The job name.
SQL.SetGrade = function(identifier, job, grade)
    local multijobresult = MySQL.Sync.fetchAll('SELECT * FROM multijob WHERE id = @id', {
        ['@id'] = identifier
    })

    for _, v in pairs(multijobresult) do
        local jobs = json.decode(v.jobs)

        if jobs[job] then
            jobs[job].grade = grade
            jobs[job].gradeLabel = GetGradeLabel(grade, job)

            MySQL.Sync.execute('UPDATE multijob SET jobs = @jobs WHERE id = @id', {
                ['@jobs'] = json.encode(jobs),
                ['@id'] = v.id
            })
        end
    end

    MySQL.Sync.execute('UPDATE users SET job_grade = @grade WHERE identifier = @id', {
        ['@grade'] = grade,
        ['@id'] = identifier
    })
end

--- Fires an employee from a specific job.
-- @param identifier The identifier of the employee.
-- @param job The job name.
-- @return true if the operation was successful.
SQL.FireEmployee = function(identifier, job)
    -- local multijobresult = MySQL.Sync.fetchAll('SELECT * FROM multijob WHERE id = @id', {
    --     ['@id'] = identifier
    -- })

    -- for _, v in pairs(multijobresult) do
    --     local jobs = json.decode(v.jobs)

    --     if jobs[job] then
    --         jobs[job] = nil

    --         MySQL.Sync.execute('UPDATE multijob SET jobs = @jobs WHERE id = @id', {
    --             ['@jobs'] = json.encode(jobs),
    --             ['@id'] = v.id
    --         })
    --     end
    -- end

    -- MySQL.Sync.execute('UPDATE users SET job_grade = 0 WHERE identifier = @id', {
    --     ['@id'] = identifier
    -- })

    -- local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @id', {
    --     ['@id'] = identifier
    -- })

    -- if result[1] and result[1].job == job then
    --     MySQL.Sync.execute('UPDATE users SET job = @job, job_grade = 0 WHERE identifier = @id', {
    --         ['@job'] = "unemployed",
    --         ['@id'] = identifier
    --     })
    -- end
    TriggerEvent('l_multijob:removeJob', job, identifier)
    return true
end

SQL.HasJob = function(identifier, job)
   -- make it fetch from multijob 
    local result = MySQL.Sync.fetchAll('SELECT * FROM multijob WHERE id = @id', {
          ['@id'] = identifier
     })
    
     for _, v in pairs(result) do
          local jobs = json.decode(v.jobs)
          if jobs[job] then
                return true
          end
     end
    
     return false
end

return SQL
