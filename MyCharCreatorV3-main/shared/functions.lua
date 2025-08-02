Config.Functions = {

    LoadIPL = function()
        -- -- Getting the object to interact with
        -- GTAOHouseHi1 = exports['bob74_ipl']:GetGTAOHouseHi1Object()
        -- GTAOHouseHi1 = exports['bob74_ipl']:GetGTAOHouseHi2Object()
        -- GTAOHouseHi1 = exports['bob74_ipl']:GetGTAOHouseHi8Object()
        -- -- Enable all strip-tease clothes
        -- GTAOHouseHi1.Strip.Enable({ GTAOHouseHi1.Strip.A, GTAOHouseHi1.Strip.B, GTAOHouseHi1.Strip.C }, true)

        -- -- Enable a bit of booze bottles
        -- GTAOHouseHi1.Booze.Enable(GTAOHouseHi1.Booze.A, true)

        -- -- Enable a bit of cigarettes
        -- GTAOHouseHi1.Smoke.Enable({ GTAOHouseHi1.Smoke.A, GTAOHouseHi1.Smoke.B }, false)

        -- RefreshInterior(GTAOHouseHi1.interiorId)
    end,

    onstart = function()
        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(PlayerPedId(), false)
    end,
    onend = function()
        DisableIdleCamera(false)
        SetPedCanPlayAmbientAnims(PlayerPedId(), true)
        _menuPool:CloseAllMenus()
        destroyallcams()
    end
}
