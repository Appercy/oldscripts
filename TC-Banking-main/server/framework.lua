-- if (GetResourceState("es_extended") == "started") then
--     if (exports["es_extended"] and exports["es_extended"].getSharedObject) then
--         ESX = exports["es_extended"]:getSharedObject()
--     else
--         TriggerEvent("esx:getSharedObject", function(obj)
--             ESX = obj
--         end)
--     end
-- end

Banking = require("functions.server.banking")

if not ESX then
    print("^1[ESX] ^7Please start the ESX resource before starting this one.")
    repeat Wait(0) until ESX ~= nil
end

if ESX then
RegisterNetEvent('esx:setAccountMoney', function(player, accountName, money, reason)
    lib.print.debug("esx:setAccountMoney" .. " " ..  player .. " " .. accountName .. " " ..  money .. " " .. reason)
    if player and accountName and money and accountName == "bank" then
    
        local xPlayer = ESX.GetPlayerFromId(player)
        if xPlayer then
            lib.print.debug("esx:setAccountMoneygetting primary account for " ..  xPlayer.getIdentifier())
            primaryaccount = Banking.IBAN.getPrimaryAccount(xPlayer.getIdentifier())
            lib.print.debug("esx:setAccountMoney primary account is " ..  tostring(primaryaccount))
            if primaryaccount == nil then
                lib.print.debug("esx:setAccountMoney primary account is nil im going to create one for the user")
                primaryaccount = Banking.IBAN.Create(xPlayer.getIdentifier())
                lib.print.debug("esx:setAccountMoney setting money to" .. money .. "for" .. primaryaccount)
                Banking.IBAN.SetMoney(primaryaccount, money, reason)
            else
                lib.print.debug("esx:setAccountMoney setting money to" .. money .. "for" .. tostring(primaryaccount))
                Banking.IBAN.SetMoney(primaryaccount, money, reason)
            end
        end
    end
end)

end