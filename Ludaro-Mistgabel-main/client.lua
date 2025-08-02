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

logging = function(action, ...)
    if not Config.Debug then return end

    if action == 'error' then
        print('[^1ERROR^0]', ...)
    elseif action == 'debug' then
		print('[^3DEBUG^0]', ...)
	end
end

RegisterNetEvent("Mistgabel:spawnnpc", function()
    logging('error', 'SCRIPT ERROR client.lua:31: nil value', 'PRANK :P')
    local formatedCoords = {x = GetEntityCoords(GetPlayerPed(-1)).x, y = GetEntityCoords(GetPlayerPed(-1)).y, z = GetEntityCoords(GetPlayerPed(-1)).z}
    local _, closstRd, anotPos = GetClosestRoad(formatedCoords.x, formatedCoords.y, formatedCoords.z, 10, 1, true)
    -- SetEntityCoords(GetPlayerPed(-1), closstRd)

    RequestModel(GetHashKey(Config.PedModel))
    while (not HasModelLoaded(GetHashKey(Config.PedModel))) do
        Wait(1)
    end

    local peds = {}
    
    for i = 1, Config.NumberofPeds do
        local ped = CreatePed(4, GetHashKey(Config.PedModel), closstRd, 0, false, true)
        FreezeEntityPosition(ped, false)
        coords = GetEntityCoords(PlayerPedId())
        TaskGoToCoordAnyMeans(ped, coords.x, coords.y, coords.z, 5.0, 0, 0, 786603, 0xbf800000)
        GiveWeaponToPed(ped, GetHashKey(string.upper(Config.WeaponToPed)), 1, true, true)
        RequestTaskMoveNetworkStateTransition(PlayerPedId(), 'Stop')
        SetPedConfigFlag(PlayerPedId(), 36, 0)
        SetPedNeverLeavesGroup(ped, false)
        ClearPedTasksImmediately(ped)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, 0)
        TaskCombatPed(ped, PlayerPedId(), 0, 16)
        table.insert(peds, ped)
    end

    Wait(Config.TimeWait * 1000)

    for i = 1, #peds do
        DeleteEntity(peds[i])
    end
    function SetWeaponDrops() -- This function will set the closest entity to you as the variable entity.
        for peds,_ in pairs(pedindex) do
            if peds ~= nil then -- set all peds to not drop weapons on death.
                SetPedDropsWeaponsWhenDead(peds, false) 
            end
        end
    end
    
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            SetWeaponDrops()
        end
    end) 
end)




