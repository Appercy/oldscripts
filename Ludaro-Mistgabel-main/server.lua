if (GetResourceState("es_extended") == "started") then
    if (exports["es_extended"] and exports["es_extended"].getSharedObject) then
        ESX = exports["es_extended"]:getSharedObject()
    else
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end
end


function debug(msg)
    if Config.Debug then
        if type(msg) == "table" then
            print(print(ESX.DumpTable(msg)))
        else
            print("[Ludaro|Debug] : " .. tostring(msg))
        end
    end
end

RegisterCommand(Config.Command, function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(xPlayer.group)
    for k,v in pairs(Config.Groups) do 
        if v == xPlayer.group then
        hasgroup = true
        end
    end
    if hasgroup or not Config.GroupRestricted then
       TriggerClientEvent("Mistgabel:spawnnpc", source)
    end
end)