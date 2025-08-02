if Config.Debug then
    local Banking = require("functions.server.banking")
    local Framework = require("functions.server.framework")
    local Billing = require("functions.server.billing")

    RegisterCommand('IBAN.Create', function(source, args)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end

        local identifier = Framework.Player.getIdentifier(source)
        if identifier then 
            testidentifier = identifier
        else
        local testidentifier = args[1] 
    end
    

        Banking.IBAN.Create(testidentifier)
    end)



    RegisterCommand('IBAN.Remove', function(source, args)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local testiban = tostring(args[1])
        if not testiban then
            lib.print.debug("Please provide an IBAN to remove")
            return
        end

        Banking.IBAN.Remove(testiban)
    end)

    RegisterCommand("Transfer.GetHistory", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        if not iban then
            lib.print.debug("Please provide an IBAN to check history")
            return
        end

        local history = Banking.Transfer.GetHistory(iban)
        print(ESX.DumpTable(history))
    end)

    RegisterCommand("IBAN.GetBalance", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        if not iban then
            lib.print.debug("Please provide an IBAN to check balance")
            return
        end

        local balance = Banking.IBAN.GetBalance(iban)
    end)

    RegisterCommand("Transfer.TransferMoney", function(source, args, rawcommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        local amount = tonumber(args[2])
        local targetiban = tostring(args[3])

        if not iban or not amount or not targetiban then
            lib.print.debug("Please provide an IBAN, amount and target IBAN")
            return
        end

        Banking.Transfer.TransferMoney(iban, targetiban, amount, "Test transfer")
    end)

    

    RegisterCommand("IBAN.SetIBANPrimary", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        iban = tostring(args[1])
        identifier = tostring(args[2])

        if not iban or not identifier then
            lib.print.debug("Please provide an IBAN and an identifier")
            return
        end

        Banking.IBAN.SetIBANPrimary(iban, identifier)
    end)

    RegisterCommand("BAN.getRole", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
    local iban = tostring(args[1])
    local identifier = tostring(args[2])

    if not iban or not identifier then
        lib.print.debug("Please provide an IBAN and an identifier")
        return

    end

    local data = Banking.IBAN.getRole(iban, identifier)
    lib.print.debug(data)
    end)

    RegisterCommand("IBAN.setRole", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        local identifier = tostring(args[2])
    
        if not iban or not identifier then
            lib.print.debug("Please provide an IBAN and an identifier")
            return
    
        end
    
        local data = Banking.IBAN.setRole(iban, identifier)
        lib.print.debug(data)
        end)

    RegisterCommand("IBAN.RemoveUser", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        local identifier = tostring(args[2])
    
        if not iban or not identifier then
            lib.print.debug("Please provide an IBAN and an identifier")
            return
    
        end
    
        local data = Banking.IBAN.RemoveUser(iban, identifier)
        lib.print.debug(data)
    end)

    RegisterCommand("IBAN.AddUser", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local iban = tostring(args[1])
        local identifier = tostring(args[2])
        local role = tostring(args[3])

        if not iban or not identifier or not role then
            lib.print.debug("Please provide an IBAN, an identifier and a role")
            return
        end
    
        local data = Banking.IBAN.AddUser(iban, identifier)
        lib.print.debug(data)
    end)

    RegisterCommand("IBAN.getAllAssociated", function(source, args, rawCommand)
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end
        local identifier = tostring(args[1])
    
        if not identifier then
            lib.print.debug("Please provide an identifier")
            return
    
        end
    
        local data = Banking.IBAN.getAllAssociated(identifier)
        lib.print.debug(data)
    end)
    
    RegisterCommand("IBAN.AddUser", function(source, args, raw)
        
        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end

        local iban = tostring(args[1])
        local identifier = tostring(args[2])
        local role = tostring(args[3])

        if not iban or not identifier or not role then
            lib.print.debug("Please provide an IBAN, an identifier and a role")
            return
        end

        local data = Banking.IBAN.AddUser(identifier, iban, role)
        lib.print.debug(data)
    end)

    RegisterCommand("IBAN.RemoveUser", function(source, args, raw)

        if source ~= 0  and Framework.Player.getGroup(source) ~= "admin"then
            lib.print.debug("You are not allowed to use this command")
            return
        end

        local iban = tostring(args[1])
        local identifier = tostring(args[2])

        if not iban or not identifier then
            lib.print.debug("Please provide an IBAN and an identifier")
            return
        end

        local data = Banking.IBAN.RemoveUser(identifier, iban)
        lib.print.debug(data)
    end)

    RegisterCommand("Card.CreateCard", function(source, args, rawCommand)
        if args[1] == nil then lib.print.debug("Please provide an IBAN") return end
        local IBAN = tostring(args[1])
        local data = Banking.Card.CreateCard(IBAN, cardnumber, expirationdate, mwph)
    end)
    
    RegisterCommand("Billing.bill", function(source, args, rawCommand)
    
        Billing.CreateBill(nil, "BILLTEST" , 100, {days = 0, minutes = 5}, nil, nil, "US3171559566831799")
    end)
end


