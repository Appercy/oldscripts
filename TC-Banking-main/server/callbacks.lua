--[[
    alle Events /Callbacks HEISEN SO:
    tb:createIBAN
    tb:removeIBAN
    tb:getIBANBalance
    tb:transferMoney
    tb:getTransferHistory
    tb:setPrimaryIBAN
    tb:getSociety
    tb:setSociety
    tb:getBankingData
    tb:getUserName
    tb:getIdentifier
    tb:createAccount
    tb:deleteAccount
    tb:leaveAccount
    tb:deposit
    tb:withdraw
    tb:transfer
    tb:externalTransfer
    tb:updateAccessRole
    tb:shareAccount
    tb:deleteAccess
]]
local Banking = require("functions.server.banking")
local Framework = require("functions.server.framework")

lib.callback.register('tb:createIBAN', function(source)
    identifier = Framework.Player.getIdentifier(source)
    return Banking.IBAN.Create(identifier)
end)


-- removing iban
-- @ param IBAN
-- @ return boolean
lib.callback.register('tb:removeIBAN', function(source, IBAN)
    return Banking.IBAN.Remove(IBAN)
end)
-- get balance
-- @ param IBAN
-- @ return integer
lib.callback.register('tb:getIBANBalance', function(source, IBAN)
    return Banking.IBAN.GetBalance(IBAN)
end)

-- transfer money
-- @ param IBAN
-- @ param targetIBAN
-- @ param amount
-- @ param description
-- @ return boolean
lib.callback.register('tb:transferMoney', function(source, IBAN, targetIBAN, amount, description)
    return Banking.Transfer.TransferMoney(IBAN, targetIBAN, amount, description)
end)

-- get transfer history
-- @ param IBAN
-- @ return table
lib.callback.register('tb:getTransferHistory', function(source, IBAN)
    return Banking.Transfer.GetHistory(IBAN)
end)


lib.callback.register('tb:setPrimaryIBAN', function(source, IBAN)
    return Banking.IBAN.SetPrimary(IBAN)
end)

lib.callback.register('tb:getSociety', function(source, IBAN)
    return Banking.IBAN.GetSociety(IBAN)
end)

lib.callback.register('tb:setSociety', function(source, society, IBAN)
    return Banking.IBAN.SetSociety(society, IBAN)
end)

lib.callback.register("tb:getBankingData", function(source)
    return Banking.Data.GetBankingData(source)
end)

lib.callback.register('tb:getUserName', function(source)
    return Framework.Player.getName(source)
end)

lib.callback.register('tb:getIdentifier', function(source)
    return Framework.Player.getIdentifier(source)
end)


lib.callback.register('tb:createAccount', function(source)
    success = false
    identifier = Framework.Player.getIdentifier(source)
    iban = Banking.IBAN.Create(identifier)
    if iban then
        success = true
        returndata = Banking.Data.GetBankingDataForSingleAccount(iban, identifier)
    else
        account = {}
    end

    return success, returndata
end)


lib.callback.register('tb:deleteAccount', function(source, iban)
    if Banking.IBAN.IsOwner(source, iban) then
    return Banking.IBAN.Delete(iban)
    else
        return false
    end
end)

lib.callback.register('tb:leaveAccount', function(source, iban)
    if Banking.IBAN.HasAccess(source, iban) then
    identifier = Framework.Player.getIdentifier(source)
    return Banking.IBAN.Leave(iban, identifier)
    else
        return false
    end
end)

lib.callback.register('tb:deposit', function(source, iban, amount, reason)
    if Banking.IBAN.HasAccess(source, iban) then
        return Banking.IBAN.Deposit(iban, amount, source, reason)
    else
        return false
    end
end)

lib.callback.register('tb:withdraw', function(source, iban, amount, reason)
    if Banking.IBAN.IsAdministrator(source, iban) then
    return Banking.IBAN.Withdraw(iban, amount, source, reason)
    else
        return false
    end
end)

lib.callback.register('tb:transfer', function(source, iban, targetiban, amount, reason)
    if Banking.IBAN.IsAdministrator(source, iban) then
    return Banking.Transfer.TransferMoney(iban, targetiban, amount, reason)
    else
        return false
    end
end)

lib.callback.register('tb:externalTransfer', function(source, iban, targetiban, amount, reason)
    if Banking.IBAN.IsAdministrator(source) then
        return Banking.Transfer.TransferMoney(iban, targetiban, amount, reason)
    else
        return false
    end
end)

lib.callback.register('tb:updateAccessRole', function(source, iban, role, identifier)
    if Banking.IBAN.IsOwner(source, iban) then
    return Banking.IBAN.UpdateAccessRole(iban, role, identifier)
    else
        return false
    end
end)

lib.callback.register('tb:shareAccount', function(source, iban, identifier, role)
    if Banking.IBAN.IsOwner(source, iban) then
        if Config.Debug then
            playeridentifier = "char2:773683d52a99ba3c845a54681ee6b6b9591d4971"
        else
            playeridentifier = Framework.Player.getIdentifier(identifier)
        end

        return Banking.IBAN.AddUser(playeridentifier, iban, role)
    else
        return false
    end
end)

lib.callback.register('tb:deleteAccess', function(source, iban, identifier)
    return Banking.IBAN.DeleteAccess(iban, identifier)
end)

lib.callback.register('tb:createCard', function(source, iban, pin, cardnumber)
   if Banking.IBAN.IsOwner(source, iban) then
    return Banking.Card.CreateCard(iban, pin, cardnumber, source)
    else
        return false
    end
end)

lib.callback.register('tb:deleteCard', function(source, iban, cardnumber)
    
    if Banking.IBAN.IsOwner(source, iban) then
    return Banking.Card.DeleteCard(iban, cardnumber)
    else
        return false
    end
end)


lib.callback.register('tb:toggleCardLock', function(source, iban, cardnumber, toggle)
    if Banking.IBAN.IsOwner(source, iban) then
  
        if toggle == true then 
           Banking.Card.LockCard(cardnumber)
        else
            Banking.Card.UnlockCard(cardnumber)
        end
        return true
    else
        return false
    end
end)


lib.callback.register('tb:updateCardLimit', function(source, iban, cardnumber, limit)
    if Banking.IBAN.IsOwner(source, iban) then
    return Banking.Card.SetMWPH(cardnumber, limit)
    else
        return false
    end
end)

lib.callback.register('tb:recreateCard', function(source, iban, cardnumber)
    if Banking.IBAN.IsOwner(source, iban) then
    return Banking.Card.RecreateCard(source, cardnumber)
    else
        return false
    end
end)