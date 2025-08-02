AddEventHandler("jobs_creator:toggleDuty", function(isOnDuty)
    if (isOnDuty) == true then
        TriggerServerEvent('changePlayerJob', "unemployed", 0)
      end
end)

RegisterCommand("testunem", function(source, args, rawCommand)
  TriggerServerEvent('changePlayerJob', "unemployed", 0)
end)