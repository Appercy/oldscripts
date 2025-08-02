Billing = require("functions.server.billing")
Banking = require("functions.server.banking")
-- lib.cron.new("10-30 * * * *", function()
--     print("Cron job running")
-- end, {debug = true})


-- DueBills = function()
--     bills = Billing.GetDueBills()
--     for k, v in pairs(bills) do
--         lib.print.debug("Processing bill: " .. v.ID)
--             success = Banking.IBAN.RemoveMoney(v.IBAN, v.AMOUNT)
--             lib.print.debug("Success: " .. tostring(success) .. " for bill: " .. v.ID)
--             if success then
--                 lib.print.debug("Bill completed: " .. v.ID)
--                 Billing.SetBillCompleted(v.ID)
--             end
--     end
-- end

-- DueBills()


-- lib.cron.new("* * * * *", function()
--     DueBills()
-- end, {debug = true})


