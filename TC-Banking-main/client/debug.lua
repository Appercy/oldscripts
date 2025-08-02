if Config.Debug then
    ESX = exports.es_extended:getSharedObject()
    local Callback = require("functions.client.callback")
    menuOpen = false
    RegisterCommand("Debug.OpenBankUI", function(source, args, rawCommand)

    SetNuiFocus(not menuOpen, not menuOpen)
    SendNUIMessage({
        display = "banking"
    })
    end, false)

    RegisterCommand("Debug.Data", function(source, args, rawCommand)
        data = Callback.GetBankingTabletData()
        print(ESX.DumpTable(data))
    end, false)
end