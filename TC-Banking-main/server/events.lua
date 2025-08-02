--[[
    alle Events /Callbacks HEISEN SO:

    - tb:createIBAN
    - tb:transferMoney
    - tb:getTransferHistory

    - tb:setPrimaryIBAN
    - tb:getSociety
    - tb:setSociety
]]
local Banking = require("functions.server.banking")
local Framework = require("functions.server.framework")

RegisterNetEvent('tb:createIBAN')
AddEventHandler('tb:createIBAN', function()
    local identifier = Framework.Player.getIdentifier(source)
    Banking.IBAN.Create(identifier)
end)

RegisterNetEvent('tb:removeIBAN')
AddEventHandler('tb:removeIBAN', function(IBAN)
    Banking.IBAN.Remove(IBAN)
end)

RegisterNetEvent('tb:getIBANBalance')
AddEventHandler('tb:getIBANBalance', function(IBAN)
    Banking.IBAN.GetBalance(IBAN)
end)

RegisterNetEvent('tb:transferMoney')
AddEventHandler('tb:transferMoney', function(IBAN, targetIBAN, amount, description)
    Banking.Transfer.TransferMoney(IBAN, targetIBAN, amount, description)
end)

RegisterNetEvent('tb:getTransferHistory')
AddEventHandler('tb:getTransferHistory', function(IBAN)
    Banking.Transfer.GetHistory(IBAN)
end)



RegisterNetEvent('tb:setPrimaryIBAN')
AddEventHandler('tb:setPrimaryIBAN', function(IBAN)
    Banking.IBAN.SetPrimary(IBAN)
end)

RegisterNetEvent('tb:getSociety')
AddEventHandler('tb:getSociety', function(IBAN)
    Banking.IBAN.GetSociety(IBAN)
end)

RegisterNetEvent('tb:setSociety')
AddEventHandler('tb:setSociety', function(society, IBAN)
    Banking.IBAN.SetSociety(society, IBAN)
end)
