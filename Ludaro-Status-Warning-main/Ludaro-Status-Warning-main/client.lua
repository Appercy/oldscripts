
if (GetResourceState("es_extended") == "started") then
    if (exports["es_extended"] and exports["es_extended"].getSharedObject) then
        ESX = exports["es_extended"]:getSharedObject()
    else
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end
end



Citizen.CreateThread(function()
    while true do
       Wait(Config.Refreshrate + 20)
       print(waterpercent, hungerpercent)

       if waterpercent < Config.PercentageWarning or hungerpercent < Config.PercentageWarning then
        Notify(Config.WarningMSG)
        return
       end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Refreshrate)
        TriggerEvent('esx_status:getStatus', 'thirst', function(status)
            waterpercent = status.getPercent()   
        end)
        TriggerEvent('esx_status:getStatus', 'hunger', function(status)       
            hungerpercent = status.getPercent() 
        end)
    end
end)