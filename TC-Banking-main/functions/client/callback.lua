Callback = {}

Callback.GetBankingTabletData = function()
    return lib.callback.await("tb:getBankingData", false)
end

Callback.GetUserName = function()
    return lib.callback.await("tb:getUserName", false)
end

Callback.GetIdentifier = function()
    return lib.callback.await("tb:getIdentifier", false)
end

Callback.CreateAccount = function()
    return lib.callback.await("tb:createAccount", false)
end 

Callback.DeleteAccount = function(...)
    return lib.callback.await("tb:deleteAccount", false, ...)
end

Callback.LeaveAccount = function(...)
    return lib.callback.await("tb:leaveAccount", false, ...)
end

Callback.Deposit = function(...)
    return lib.callback.await("tb:deposit", false, ...)
end

Callback.Withdraw = function(...)
    return lib.callback.await("tb:withdraw", false, ...)
end

Callback.Transfer = function(...)
    return lib.callback.await("tb:transfer", false, ...)
end

Callback.TransferExtern = function(...)
    return lib.callback.await("tb:externalTransfer", false, ...)
end

Callback.UpdateAccessRole = function(...)
    return lib.callback.await("tb:updateAccessRole", false, ...)
end

Callback.ShareAccount = function(...)
    return lib.callback.await("tb:shareAccount", false, ...)
end

Callback.DeleteAccess = function(...)
    return lib.callback.await("tb:deleteAccess", false, ...)
end

Callback.CreateCard = function(...)
    return lib.callback.await("tb:createCard", false, ...)
end

Callback.DeleteCard = function(...)
    return lib.callback.await("tb:deleteCard", false, ...)
end

Callback.ToggleCardLock = function(...)
    return lib.callback.await("tb:toggleCardLock", false, ...)
end

Callback.UpdateCardLimit = function(...)
    return lib.callback.await("tb:updateCardLimit", false, ...)
end

Callback.RecreateCard = function(...)
    return lib.callback.await("tb:recreateCard", false, ...)
end

return Callback