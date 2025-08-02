ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


RegisterNetEvent('Automat:Bezahlen')
AddEventHandler('Automat:Bezahlen', function(price, name)
local _source = source
local xPlayer = ESX.GetPlayerFromId(_source)
xPlayer.removeAccountMoney('money', price)
xPlayer.addInventoryItem(name, 1)
end)
