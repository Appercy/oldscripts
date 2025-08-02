Billing = {}
Banking = require("functions.server.banking")
-- TO BE REWORKED

Billing.CreateBill = function (id, reason, amount, maxTime, issuer, society, IBAN, days, minutes)
name = tonumber(id) and Framework.Player.getName(id) or Framework.Player.getName(nil, id) or "System"
issuer = issuer or (society and (name .. " | " .. society) or name)
IBAN = Banking.IBAN.Exists(IBAN) and IBAN or Banking.IBAN.getPrimaryAccount(Framework.Player.getIdentifier(id))
days = maxTime and maxTime.days or 0
minutes = maxTime and maxTime.minutes or 0
local date = os.date("%Y-%m-%d %H:%M:%S", os.time() + (days * 86400) + (minutes * 60))
local billData = MySQL.insert.await('INSERT INTO TC_BANKING_TRANSACTION_HISTORY (IBAN, AMOUNT, DATE, DESCRIPTION, ISSUER, STATUS) VALUES (?, ?, ?, ?, ?)', { IBAN, amount, date, reason, issuer, "pending" })
end
Billing.GetDueBills = function()
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    local bills = MySQL.query.await('SELECT * FROM TC_BANKING_TRANSACTION_HISTORY WHERE STATUS != ? AND DATE < ?', { "completed", currentTime })
    return bills
end

Billing.SetBillCompleted = function(id)
    MySQL.update.await('UPDATE TC_BANKING_TRANSACTION_HISTORY SET STATUS = ? WHERE ID = ?', { "completed", id })
end




return Billing