if Config.ESX then
    ESX = exports["es_extended"]:getSharedObject()

    exports["kimi_callbacks"]:Register("getJob", function(source)
        -- get money from player with source
        _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        local job = xPlayer.getJob()
        return job
    end) --TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end


RegisterNetEvent('LT:Pay', function(money)
    _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeAccountMoney('money', money)
end)
