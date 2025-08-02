-- SQL Module
-- This module provides various SQL-related functions for managing jobs, employees, and grades in the system.

SQL = {}
Framework = require("functions.shared.framework")

SQL.Init = function()
     local queries = {
          {
               query = [[
               CREATE TABLE IF NOT EXISTS `multijob` (
                    `id` VARCHAR(999) PRIMARY KEY,
                    `jobs` VARCHAR(999) NOT NULL
               ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
          ]],
               values = {}
          },
          {
               query = [[
               ALTER TABLE `multijob`
               MODIFY COLUMN `id` VARCHAR(999),
               MODIFY COLUMN `jobs` VARCHAR(999);
          ]],
               values = {}
          }
     }

     local success = MySQL.transaction.await(queries)
     if success then
          print("^2[MultiJob]^0: ^3" .. os.date("%X") .. "^0 Table '^3multijob^0' created or updated successfully.^0")
     else
          print("^1[MultiJob]^0: ^3" .. os.date("%X") .. "^0 Failed to create or update table '^3multijob^0'.^0")
     end
end



SQL.GetJobs = function(source)
     if type(source) == "number" then
         identifier = Framework.Server.GetIdentifier(source)
     elseif type(source) == "string" then
        identifier = source
     end

     if identifier == nil then return "error" end

     local result = MySQL.query.await('SELECT jobs FROM multijob WHERE id = ?', { identifier })
     if result and result[1] then
          local jobs = json.decode(result[1].jobs)
          return jobs
     else
          return nil
     end
   
end

SQL.RemoveJob = function(jobname, source)

     oldjobs = SQL.GetJobs(source)
     if oldjobs == nil then
          oldjobs = {}
     end
     if oldjobs[jobname] then
          oldjobs[jobname] = nil
     end
     jobs = json.encode(oldjobs)
     if type(source) == "number" then
          identifier = Framework.Server.GetIdentifier(source)
     elseif type(source) == "string" then
          identifier = source
     end
     print(jobname, source, identifier)

     local result = MySQL.query.await('SELECT jobs FROM multijob WHERE id = ?', { identifier })
     if result and result[1] then
          local jobs = json.decode(result[1].jobs)
          jobs[jobname] = nil
          local updatedJobs = json.encode(jobs)
          MySQL.query.await('UPDATE multijob SET jobs = @jobs WHERE id = @id', {
               ['@id'] = identifier,
               ['@jobs'] = updatedJobs
          })
     end

     -- If the job being removed is the current job, set the player to another job from multijob or to unemployed grade 0
     local currentJob = (Framework.Server.GetJob(source) ~= nil and Framework.Server.GetJob(source).name) or nil
     if currentJob == nil then 
     -- Player is offline; check their current job in the database and update it if necessary
     local result = MySQL.query.await('SELECT job, job_grade FROM users WHERE identifier = ?', { identifier })
     if result and result[1] then
          local dbJob = result[1].job
          local dbJobGrade = result[1].job_grade
          if dbJob == jobname then
               MySQL.query.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', { "unemployed", 0, identifier })
          end
     end
     elseif currentJob == jobname then
          local remainingJobs = SQL.GetJobs(source)
          if remainingJobs and next(remainingJobs) then
               -- Set to another job if available
               for newJobName, newJobData in pairs(remainingJobs) do
                    Framework.Server.SetJob(source, newJobName, newJobData.grade)
                    break
               end
          else
               -- Set to unemployed if no other jobs are available
               Framework.Server.SetJob(source, "unemployed", 0)
          end
     end

end


SQL.ChangeGrade = function(jobname, grade, source)
     if jobname == "unemployed" then return end
     oldjobs = SQL.GetJobs(source)
     if oldjobs == nil then
          oldjobs = {}
     end
     if oldjobs[jobname] then
          oldjobs[jobname].grade = grade
     end
     jobs = json.encode(oldjobs)
     if type(source) == "number" then
          identifier = Framework.Server.GetIdentifier(source)
     elseif type(source) == "string" then
          identifier = source
     end

     MySQL.query.await('UPDATE multijob SET jobs = @jobs WHERE id = @id', {
          ['@id'] = identifier,
          ['@jobs'] = jobs
     }, function(result)
          if result.affectedRows > 0 then
          end
     end)

end

SQL.GetGradeLabel = function(grade, job)
     local result = MySQL.query.await('SELECT label FROM job_grades WHERE job_name = ? AND grade = ?', { job, grade })
     if result and result[1] then
          return result[1].gradeLabel
     else
          return nil
     end
end

SQL.AddJob = function(jobdata, source)
     local grade = jobdata.grade
     local name = jobdata.name
     local label = jobdata.label
     local gradelabel = jobdata.gradelabel
     print("Debug: Adding job:", name, "with grade:", grade, "and label:", label, "and gradelabel:", gradelabel)
     if name == "unemployed" then return end

     local oldjobs = SQL.GetJobs(source)
     if oldjobs == nil then
          oldjobs = {}
     end


     -- Check if the job already exists
     if oldjobs[name] then
          -- Update the job if the grade, label, or gradeLabel is different
          if oldjobs[name].grade ~= grade or oldjobs[name].label ~= label or oldjobs[name].gradeLabel ~= gradelabel then
               oldjobs[name].grade = grade
               oldjobs[name].label = label
               oldjobs[name].gradeLabel = gradelabel
          end
     else
          -- Check if the max job limit is reached

          local jobCount = 0
          for _ in pairs(oldjobs) do
               jobCount = jobCount + 1
          end

          if jobCount >= Config.MaxJobs then
               return true
          end

          -- Add the new job
          oldjobs[name] = {
               grade = grade,
               label = label,
               gradeLabel = gradelabel
          }
     end

     local jobs = json.encode(oldjobs)
     local identifier
     if type(source) == "number" then
          identifier = Framework.Server.GetIdentifier(source)
     elseif type(source) == "string" then
          identifier = source
     end
     

     MySQL.query.await('INSERT INTO multijob (id, jobs) VALUES (@id, @jobs) ON DUPLICATE KEY UPDATE jobs = @jobs', {
          ['@id'] = identifier,
          ['@jobs'] = jobs
     }, function(result)
          if result.affectedRows > 0 then
          end
     end)

end


return SQL


