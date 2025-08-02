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

exports('tb:createIBAN', function()
    local identifier = Framework.Player.getIdentifier(source)
    Banking.IBAN.Create(identifier)
end)

exports('tb:removeIBAN', function(IBAN)
    Banking.IBAN.Remove(IBAN)
end)

exports('tb:getIBANBalance', function(IBAN)
    Banking.IBAN.GetBalance(IBAN)
end)

exports('tb:transferMoney', function(IBAN, targetIBAN, amount, description)
    Banking.Transfer.TransferMoney(IBAN, targetIBAN, amount, description)
end)

exports('tb:getTransferHistory', function(IBAN)
    Banking.Transfer.GetHistory(IBAN)
end)

exports('tb:setPrimaryIBAN', function(IBAN)
    Banking.IBAN.SetPrimary(IBAN)
end)

exports('tb:getSociety', function(IBAN)
    Banking.IBAN.GetSociety(IBAN)
end)

exports('tb:setSociety', function(society, IBAN)
    Banking.IBAN.SetSociety(society, IBAN)
end)
