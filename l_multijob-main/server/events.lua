Framework = require("functions.shared.framework")
SQL = require("functions.server.sql")
RegisterNetEvent(
    "changePlayerJob",
    function(job, grade)
        Framework.Server.SetJob(source, job, grade)
    end
)

RegisterNetEvent(
    "deleteMultijob",
    function(job)
        SQL.RemoveJob(job, source)
    end
)

AddEventHandler(
    "esx:setJob",
    function(player, job, lastJob)
   
        if (job.name == lastJob.name and job.grade == lastJob.grade) then
            return
        end

       if job.name == "unemployed" then
            Framework.Server.SetJob(player, "unemployed", 0)
            return
        end

        jobdata = {
            name = job.name,
            label = job.label,
            grade = job.grade,
            gradelabel = job.grade_label
        }
        toomuchjobs = SQL.AddJob(jobdata, player)

        if toomuchjobs == true then
            Framework.Server.SetJob(player, lastJob.name, lastJob.grade)
            Framework.Server.showNotification(player, "Du hast zu viele Jobs!")
        end
        identifier = Framework.Server.GetIdentifier(player)
    end
)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler(
    "esx:playerLoaded",
    function(player, xPlayer)
        jobdata = {
            name = xPlayer.job.name,
            label = xPlayer.job.label,
            grade = xPlayer.job.grade,
            gradelabel = xPlayer.job.grade_label
        }

        name = xPlayer.job.name
        print("Debug: Checking job name:", name)
        print("for player" .. player)
        if name == "mechanic" or name == "bennys" then
            TriggerClientEvent("brutal_mechanicjob:client:ToggleDuty", player)
            print("Debug: Mechanic or Bennys job detected, toggling duty")
        elseif name == "ambulance" then
            TriggerClientEvent("brutal_ambulancejob:client:ToggleDuty", player)
            print("Debug: Ambulance job detected, toggling duty")
        elseif name == "police" or name == "policemrpd" then
            TriggerClientEvent("brutal_policejob:client:ToggleDuty", player)
            print("Debug: Police or Policemrpd job detected, toggling duty")
        else
            print("Debug: Job is not recognized, toggling all duties off")
            TriggerClientEvent("brutal_mechanicjob:client:ToggleDuty", player)
            TriggerClientEvent("brutal_bennysjob:client:ToggleDuty", player)
            TriggerClientEvent("brutal_ambulancejob:client:ToggleDuty", player)
            TriggerClientEvent("brutal_policejob:client:ToggleDuty", player)
            TriggerClientEvent("brutal_policemrpdjob:client:ToggleDuty", player)
        end
        jobdata = {
            name = xPlayer.job.name,
            label = xPlayer.job.label,
            grade = xPlayer.job.grade,
            gradelabel = xPlayer.job.grade_label
        }

        toomuchjobs = SQL.AddJob(jobdata, player)
        -- make it so that if he joins his job will be added to the multijob database

    end
)


RegisterNetEvent('l_multijob:removeJob', function(job, identifier)
SQL.RemoveJob(job, identifier)
end)