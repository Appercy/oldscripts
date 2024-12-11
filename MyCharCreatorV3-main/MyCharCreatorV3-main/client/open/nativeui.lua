incharselect = false
_menuPool = NativeUI.CreatePool()
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if _menuPool:IsAnyMenuOpen() then
            _menuPool:ProcessMenus()
        else
            Citizen.Wait(150) -- this small line
        end
    end
end)

function openskinmenu()
    if not _menuPool:IsAnyMenuOpen() then
        startskincam()
        incharselect = true
        mainmenu = NativeUI.CreateMenu(translation("MainMenuname"), "", Config.MenuOptions.Position.X,
            Config.MenuOptions.Position.Y, nil, nil, nil, Config.MenuOptions.Color.R, Config.MenuOptions.Color.G,
            Config.MenuOptions.Color.B, Config.MenuOptions.Color.A)

        _menuPool:Add(mainmenu)
        local headmenu = _menuPool:AddSubMenu(mainmenu, "Head", "Change your head")
        local bodymenu = _menuPool:AddSubMenu(mainmenu, "Body", "Change your body")
        local legsmenu = _menuPool:AddSubMenu(mainmenu, "Legs", "Change your legs")
        local shoesmenu = _menuPool:AddSubMenu(mainmenu, "Shoes", "Change your shoes")
        local accessoriesmenu = _menuPool:AddSubMenu(mainmenu, "Accessories", "Change your accessories")
        local finishmenu = _menuPool:AddSubMenu(mainmenu, "Finish", "Finish your character")

        mainmenu.Controls.Back.Enabled = false
        mainmenu.Settings.ControlDisablingEnabled = false
        -- mainmenu:AddInstructionButton({ GetControlInstructionalButton(2, Config.Controls.head.switch, 0),
        --     translation("Head") })
        -- mainmenu:AddInstructionButton({ GetControlInstructionalButton(2, Config.Controls.torso.switch, 0),
        --     translation("Torso") })
        -- mainmenu:AddInstructionButton({ GetControlInstructionalButton(2, Config.Controls.fullbody.switch, 0),
        --     translation("Fullbody") })
        for k, v in pairs(Config.CameraCoords) do
            if v.control.id and v.control.name then
                mainmenu:AddInstructionButton({ GetControlInstructionalButton(2, v.control.id, 0),
                    v.control.name })
            end
        end
        mainmenu:Visible(true)
        checkcameracontrols()
    else
        _menuPool:CloseAllMenus()
        openskinmenu()
    end
end
