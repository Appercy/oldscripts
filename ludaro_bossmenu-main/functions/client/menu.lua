--- Menu Module
-- This module handles the creation and management of menus for the boss system.
-- It includes functionality for employee management, recruitment, and society management.

local Menu = {}
local Permission = require("functions.client.permissions")
local Callback = require("functions.client.callback")

--- Opens a menu with the given name.
-- @param name The name of the menu to open.
Menu.Open = function(name)
    local hasPermission = Permission.CanOpenMenu()
    lib.print.debug("Menu:Open", name)
    lib.print.debug("Menu:CanOpenMenu", hasPermission)

    if hasPermission then
        lib.registerMenu({
            id = name,
            title = name,
            position = 'top-right',
            options = {
                {label = "Mitarbeiter Liste", description = "Zeigt die Mitarbeiter Liste an", args = {action = "employee_list"}},
                {label = "Rekrutieren", description = "Rekrutiert einen neuen Mitarbeiter", args = {action = "recruit"}},
                {label = "Gesellschaft", description = "Verwalte die Gesellschaft", args = {action = "society"}}
            }
        }, function(selected, scrollIndex, args)
            if args.action == "employee_list" and Permission.IsAllowed("showPlayers") then
                Menu.OpenEmployeeList(name)
            elseif args.action == "recruit" and Permission.IsAllowed("hire") then
                Menu.OpenRecruitmentMenu(name)
            elseif args.action == "society" then
                Menu.OpenSocietyMenu(name)
            else
                Framework.Client.ShowNotification("Du hast keine Rechte, diese Aktion auszuführen.")
            end
        end)

        lib.showMenu(name)
    else
        Framework.Client.ShowNotification("Du hast keine Rechte, dieses Menü zu öffnen.")
    end
end

--- Opens the employee list menu.
-- @param name The name of the menu.
Menu.OpenEmployeeList = function(name)
    if not Permission.IsAllowed("showPlayers") then
        Framework.Client.ShowNotification("Du hast keine Rechte, die Mitarbeiterliste anzuzeigen.")
        return
    end

    local employeeList = Callback.GetEmployees(name)
    local grades = Callback.GetGrades(name)

    if employeeList and #employeeList > 0 then
        local options = {}
        for _, employee in ipairs(employeeList) do
            table.insert(options, {
                label = employee.name .. " | " .. employee.grade_label,
                description = "Rang: " .. employee.grade .. " / " .. #grades,
                args = {employee = employee}
            })
        end

        lib.registerMenu({
            id = name .. "_employee_list",
            title = "Mitarbeiter Liste",
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            local employee = args.employee

            lib.registerMenu({
                id = name .. "_employee_actions_" .. employee.id,
                title = "Aktionen für " .. employee.name,
                position = 'top-right',
                options = {
                    {label = "Rang ändern", description = "Ändere den Rang von " .. employee.name, args = {action = "change_grade", employee = employee}},
                    {label = "Feuern", description = "Feuere " .. employee.name, args = {action = "fire", employee = employee}},
                    {label = "Zurück", description = "Zurück zur Mitarbeiter Liste", args = {action = "back"}}
                }
            }, function(selectedAction, scrollIndexAction, actionArgs)
                if actionArgs.action == "change_grade" and Permission.IsAllowed("hire") then
                    Menu.ChangeGrade(name, actionArgs.employee, grades)
                elseif actionArgs.action == "fire" and Permission.IsAllowed("fire") then
                    local success = Callback.AwaitFireEmployee(actionArgs.employee.id, name)
                    if success then
                        Framework.Client.ShowNotification(actionArgs.employee.name .. " wurde erfolgreich gefeuert.")
                        Menu.OpenEmployeeList(name)
                    else
                        Framework.Client.ShowNotification("Fehler beim Feuern des Mitarbeiters.")
                    end
                elseif actionArgs.action == "back" then
                    Menu.OpenEmployeeList(name)
                else
                    Framework.Client.ShowNotification("Du hast keine Rechte, diese Aktion auszuführen.")
                end
            end)

            lib.showMenu(name .. "_employee_actions_" .. employee.id)
        end)

        lib.showMenu(name .. "_employee_list")
    else
        Framework.Client.ShowNotification("Keine Mitarbeiter gefunden.")
    end
end

--- Changes the grade of an employee.
-- @param name The name of the menu.
-- @param employee The employee whose grade is to be changed.
-- @param grades The list of available grades.
Menu.ChangeGrade = function(name, employee, grades)
    local ownJob, ownGrade = Callback.GetJob()

    if grades and #grades > 0 then
        local gradeOptions = {}

        for _, grade in ipairs(grades) do
            if grade.grade <= ownGrade then
                table.insert(gradeOptions, {
                    label = grade.name .. " | " .. grade.grade,
                    description = "Setze den Rang auf " .. grade.name,
                    args = {grade = grade}
                })
            end
        end

        if #gradeOptions > 0 then
            lib.registerMenu({
                id = name .. "_change_grade_" .. employee.id,
                title = "Rang ändern für " .. employee.name,
                position = 'top-right',
                options = gradeOptions
            }, function(selectedGrade, scrollIndexGrade, gradeArgs)
                if gradeArgs.grade.grade > ownGrade then
                    Framework.Client.ShowNotification("Du kannst diesen Rang nicht setzen, da er höher ist als dein eigener Rang.")
                    return
                end

                local success = Callback.AwaitChangeGrade(employee.id, name, gradeArgs.grade.grade)
                if success then
                    Framework.Client.ShowNotification(employee.name .. " wurde auf den Rang " .. gradeArgs.grade.name .. " gesetzt.")
                    Menu.OpenEmployeeList(name)
                else
                    Framework.Client.ShowNotification("Fehler beim Ändern des Rangs.")
                end
            end)

            lib.showMenu(name .. "_change_grade_" .. employee.id)
        else
            Framework.Client.ShowNotification("Keine gültigen Ränge verfügbar, die du setzen kannst.")
        end
    else
        Framework.Client.ShowNotification("Keine Ränge gefunden.")
    end
end

--- Opens the recruitment menu.
-- @param name The name of the menu.
Menu.OpenRecruitmentMenu = function(name)
    if not Permission.IsAllowed("hire") then
        Framework.Client.ShowNotification("Du hast keine Rechte, neue Mitarbeiter zu rekrutieren.")
        return
    end

    local nearbyPlayers = lib.getnearbyplayers(GetEntityCoords(PlayerPedId()), 5.0, Config.Debug)

    if #nearbyPlayers <= 0 then
        Framework.Client.ShowNotification("Keine Spieler in der Nähe.")
        Menu.Open(name)
    else
        local options = {}
        for _, player in ipairs(nearbyPlayers) do
            local playerName = Callback.GetPlayerName(GetPlayerServerId(NetworkGetPlayerIndexFromPed(player.ped)))
            table.insert(options, {
                label = playerName,
                description = "Rekrutiere " .. playerName,
                args = {player = player, name = playerName}
            })
        end

        lib.registerMenu({
            id = name .. "_recruitment",
            title = "Rekrutierung",
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            local player = args.player
            local success = Callback.RecruitPlayer(GetPlayerServerId(NetworkGetPlayerIndexFromPed(player.ped)), name)
            if success then
                name = Callback.GetNameOfPlayer(GetPlayerServerId(NetworkGetPlayerIndexFromPed(player.ped)))
                Framework.Client.ShowNotification("Du hast erfolgreich " .. name .. " rekrutiert.")
            else
                Framework.Client.ShowNotification("Fehler beim Rekrutieren.")
            end
        end)
        Menu.Open(name)
    end
end

--- Opens the society management menu.
-- @param name The name of the menu.
Menu.OpenSocietyMenu = function(name)
    local societyBalance = Callback.GetSocietyMoney(name)
    local grades = Callback.GetGrades(name)

    local menuData = {
        {label = "Kontostand: $" .. societyBalance, description = "Zeigt den aktuellen Kontostand an", args = {action = "view_balance"}},
        {label = "Einzahlen", description = "Geld in die Gesellschaft einzahlen", args = {action = "deposit"}},
        {label = "Abheben", description = "Geld von der Gesellschaft abheben", args = {action = "withdraw"}},
        {label = "Gehalt ändern", description = "Ändere das Gehalt der Ränge", args = {action = "change_salary"}}
    }

    if Config.Locations[name] and Config.Locations[name].washmoney then
        table.insert(menuData, {label = "Geld waschen", description = "Schmutziges Geld waschen", args = {action = "wash_money"}})
    end


    lib.registerMenu({
        id = name .. "_society",
        title = "Gesellschaft",
        position = 'top-right',
        options = menuData
    }, function(selected, scrollIndex, args)
        if args.action == "deposit" and Permission.IsAllowed("deposit") then
            local amount = lib.inputDialog("Einzahlen", {"Betrag"})
            if amount and tonumber(amount[1]) then
                TriggerServerEvent('esx_society:depositMoney', name, tonumber(amount[1]))
                Framework.Client.ShowNotification("Einzahlungsanfrage gesendet: $" .. amount[1])
            end
        elseif args.action == "withdraw" and Permission.IsAllowed("withdraw") then
            local amount = lib.inputDialog("Abheben", {"Betrag"})
            if amount and tonumber(amount[1]) then
                TriggerServerEvent('esx_society:withdrawMoney', name, tonumber(amount[1]))
                Framework.Client.ShowNotification("Abhebungsanfrage gesendet: $" .. amount[1])
            end
        elseif args.action == "wash_money" and Permission.IsAllowed("washMoney") then
            local amount = lib.inputDialog("Geld waschen", {"Betrag"})
            if amount and tonumber(amount[1]) then
                TriggerServerEvent('esx_society:washMoney', name, tonumber(amount[1]))
                Framework.Client.ShowNotification("Anfrage zum Waschen von $" .. amount[1] .. " gesendet.")
            end
        elseif args.action == "change_salary" and Permission.IsAllowed("changeSalary") then
            if grades and #grades > 0 then
                local gradeOptions = {}

                for _, grade in ipairs(grades) do
                    table.insert(gradeOptions, {
                        label = grade.name,
                        description = "Aktuelles Gehalt: $" .. grade.salary,
                        args = {grade = grade}
                    })
                end

                lib.registerMenu({
                    id = name .. "_change_salary",
                    title = "Gehalt ändern",
                    position = 'top-right',
                    options = gradeOptions
                }, function(selectedGrade, scrollIndexGrade, gradeArgs)
                    local newSalary = lib.inputDialog("Gehalt ändern", {"Neues Gehalt"})
                    if newSalary and tonumber(newSalary[1]) then
                        ESX.TriggerServerCallback('esx_society:setJobSalary', function()
                        end, name, tonumber(newSalary[1]), gradeArgs.grade.grade)
                        local success = Callback.ChangeGradeSalary(name, gradeArgs.grade.grade, tonumber(newSalary[1]), name)
                        if success then
                            Framework.Client.ShowNotification("Das Gehalt für " .. gradeArgs.grade.name .. " wurde auf $" .. newSalary[1] .. " geändert.")
                        else
                            Framework.Client.ShowNotification("Fehler beim Ändern des Gehalts.")
                        end
                    end
                end)

                lib.showMenu(name .. "_change_salary")
            else
                Framework.Client.ShowNotification("Keine Ränge gefunden.")
            end
        else
            Framework.Client.ShowNotification("Du hast keine Rechte, diese Aktion auszuführen.")
        end
    end)

    lib.showMenu(name .. "_society")
end

return Menu