
RegisterNUICallback('getBankData', function(data, cb)
    data = Callback.GetBankingTabletData()
    print(ESX.DumpTable(data))
    cb(data)
  end)

  RegisterNUICallback('closeNUI', function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
  end)

-- BankingTab.vue
  RegisterNUICallback('getUser', function(data, cb)
    Name = Callback.GetUserName()
    cb({name = Name})
  end)

  RegisterNUICallback("getIdentifier", function(data, cb)
    Identifier = Callback.GetIdentifier()
    cb({identifier = Identifier})
  end)

  RegisterNUICallback('createAccount', function(data, cb)
    successful, returndata = Callback.CreateAccount()
    if successfull then
      cb({success = successful, data = returndata})
    else
      cb({success = successful, data = {}})
    end
  end)
  

RegisterNUICallback('deleteAccount', function(data, cb)
  successful = Callback.DeleteAccount(data.iban)
  cb({success = successful})
end)

RegisterNUICallback('leaveAccount', function (data, cb)
  successful = Callback.LeaveAccount(data.iban)
cb({success = successful})  
end)
  
RegisterNUICallback('transaction', function(data, cb)
 iban = data.iban
  typee = data.type
  amount = data.amount
  reason = data.reason 

  if typee == "deposit" then
    success = Callback.Deposit(iban, amount, reason)
  end 
  if typee == "withdraw" then
    success = Callback.Withdraw(iban, amount, reason)
  end
  print(success)
  cb({success = success})
end)

RegisterNUICallback('transfer', function(data, cb)
  from = data.fromIban
  to = data.toIban
  amount = data.amount
  description = data.description
  success = Callback.Transfer(from, to, amount, description)
  cb({success = success})
end)

RegisterNUICallback('externalTransfer', function(data, cb)
  from = data.fromIban
  to = data.toIban
  amount = data.amount
  description = data.description
  success = Callback.TransferExtern(from, to, amount, description)
  cb({success = success})
end)

RegisterNUICallback('updateAccessRole', function(data, cb)
  iban = data.iban
  role = data.role
  identifier = data.identifier
  success = Callback.UpdateAccessRole(iban, role, identifier)
  cb({success = success})
end)

RegisterNUICallback('shareAccount', function(data, cb)
  iban = data.iban
  identifier = data.identifier
  role = data.role
  success, name = Callback.ShareAccount(iban, identifier, role)
  cb({success = success, name})
end)

RegisterNUICallback('deleteAccess', function(data, cb)
  iban = data.iban
  identifier = data.identifier
  success = Callback.DeleteAccess(iban, identifier)
  cb({success = success})
 
end)

-- card.vue

RegisterNUICallback('createCard', function (data, cb)
  iban = data.iban
  pin = data.pin
  cardnumber = data.cardNumber

  success = Callback.CreateCard(iban, pin, cardnumber)
 
  cb({success = success})
end)

RegisterNUICallback('deleteCard', function(data,cb)
  success = Callback.DeleteCard(data.iban, data.cardId)
  cb({success = success})
end)

RegisterNUICallback('toggleCardLock', function(data, cb)
  success = Callback.ToggleCardLock(data.iban, data.cardId, data.locked)
  cb({success = success})
end)

RegisterNUICallback('updateCardLimit', function(data, cb)
  success = Callback.UpdateCardLimit(data.iban, data.cardId, data.limit)
  cb({success = success})
end)

RegisterNUICallback('recreateCard', function(data, cb)
  success = Callback.RecreateCard(data.iban, data.cardId)
  cb({success = success})
end)