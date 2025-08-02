Framework = {}
Framework.Player = {}
Framework.Player.getName = function(source, identifier)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getName()
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.getName()
    end

    name = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    })
    if name[1] then
        return name[1].firstname .. " " .. name[1].lastname
    end
    return "NAME NOT FOUND"
end

Framework.Player.getIdentifier = function(source)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getIdentifier()
        end
    end
    return "IDENTIFIER NOT FOUND"
end

Framework.Player.getMoney = function(source, identifier)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getMoney()
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.getMoney()
    end
    return 0
end



Framework.Player.addMoney = function(source, identifier, amount)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        xPlayer.addMoney(amount)
    end
end

Framework.Player.removeMoney = function(source, identifier, amount)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeMoney(amount)
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        xPlayer.removeMoney(amount)
    end

end


Framework.Player.getBank = function(source, identifier)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
      
        if xPlayer then
            return xPlayer.getAccount("bank").money
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.getAccount("bank").money
    end
    return 0
end

Framework.Player.setBank = function(source, identifier, amount, reason)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.setAccountMoney("bank", amount, reason)
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        xPlayer.setAccountMoney("bank", amount, reason)
    end
end


Framework.Player.addBank = function(source, identifier, amount)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addAccountMoney("bank", amount)
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        xPlayer.addAccountMoney("bank", amount)
    end
end

Framework.Player.removeBank = function(source, identifier, amount)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeAccountMoney("bank", amount)
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        xPlayer.removeAccountMoney("bank", amount)
    end
end

Framework.Player.getGroup = function(source, identifier)
    if source then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getGroup()
        end
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.getGroup()
    end
    return "NO GROUP"
end


Framework.Player.AddItem = function(source, item, metadata)
    if source then
        if exports.ox_inventory then
            local success, response = exports.ox_inventory:AddItem(source, item, 1, metadata)
            return success
        end
    end
    return false
end



return Framework
