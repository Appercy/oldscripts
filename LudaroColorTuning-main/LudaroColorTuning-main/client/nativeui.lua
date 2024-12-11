_menuPool = NativeUI.CreatePool()
if Config.ESX then
    --ESX = exports["es_extended"]:getSharedObject()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

function GetJob()
    local job = exports["kimi_callbacks"]:Trigger("getJob")
    return job
end

function Debug()
    if Config.Debug then
        return true
    else
        return false
    end
end

if Config.Marker.Enabled then

    CreateThread(function()
        while true do
            -- draw every frame
            Wait(0)
            DrawMarker(Config.Marker.MarkerID, Config.Coords.x, Config.Coords.y, Config.Coords.z, 0.0, 0.0, 0.0, 0.0
                , 0.0, 0.0, Config.Marker.Width, 2, Config.Marker.Height, Config.Marker.R, Config.Marker.G,
                Config.Marker.B,
                Config.Marker.Opacity,
                Config.Bobupanddown, Config.Marker.FollowsPlayerCamera, true, nil, nil, false)
        end
    end)
end




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


function isjobright()
    if Config.ESX and Config.Job ~= nil then
        local job = GetJob()
        if job.name == Config.Job then
            return true
        else
            return false
        end
    else
        return true
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local pedCoord = GetEntityCoords(PlayerPedId())
        if vehicle ~= 0 and not _menuPool:IsAnyMenuOpen() and
            GetDistanceBetweenCoords(Config.Coords, pedCoord) < Config.Range then
            if Config.ESX then
                ESX.ShowHelpNotification(Translation[Config.Locale]['notify'])
            end
            if IsControlJustReleased(0, Config.Button) then
                if isjobright() then
                    openmainmenu()
                end

            end
        end
    end
end)

function openmainmenu()
    mainmenu = NativeUI.CreateMenu(Translation[Config.Locale]['MainMenuName'], "")
    _menuPool:Add(mainmenu)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    mainmenu:Visible(true)
    local color = NativeUI.CreateItem(Translation[Config.Locale]['ChangeColor'],
        Translation[Config.Locale]['price'] .. "~g~ " .. Config.ColorsPrice .. Config.Currency)
    color:RightLabel('~g~>>>')
    if Config.Coloring then
        mainmenu:AddItem(color)
    end
    color.Activated = function(sender, index)
        TriggerServerEvent("LT:Pay", Config.ColorsPrice)
        opencolormenu()
    end

    local extras = NativeUI.CreateItem(Translation[Config.Locale]['Extras'],
        Translation[Config.Locale]['price'] .. "~g~ " .. Config.ExtrasPrice .. Config.Currency)
    if Config.Extras then
        mainmenu:AddItem(extras)
    end
    extras:RightLabel('~g~>>>')
    extras.Activated = function(sender, index)
        TriggerServerEvent("LT:Pay", Config.ExtrasPrice)
        openextrasmenu()
    end
    local extrasavailable = 0
    for extraID = 0, 20 do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesExtraExist(vehicle, extraID) then
            extrasavailable = extrasavailable + 1
        end
    end
    if extrasavailable == 0 then
        extras:Enabled(false)
        extras:RightLabel('~r~X')
    else
        extras:RightLabel('~g~>>>')
    end

    --local performance = NativeUI.CreateItem(Translation[Config.Locale]['performance'], "")
    --if Config.Performance then
    --   mainmenu:AddItem(performance)
    --end
    --performance:RightLabel('~g~>>>')
    --erformance.Activated = function(sender, index)
    --  openperformancemenu()
    --end
end

function opencolormenu()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local rr, gg, bb = GetVehicleColor(vehicle)

    --[[
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if not _menuPool:IsAnyMenuOpen() and done == nil then
                print(primaryc, secondaryc)
                SetVehicleCustomPrimaryColour(vehicle, rr, gg, bb)
                SetVehicleCustomSecondaryColour(vehicle, rr, gg, bb)
                break
            end
        end
    end)
]]
    local options = { Translation[Config.Locale]['PrimaryColor'], Translation[Config.Locale]['SecondaryColor'] }
    mainmenu:Visible(false)
    colormenu = NativeUI.CreateMenu(Translation[Config.Locale]['ColorMenuName'], "")
    _menuPool:Add(colormenu)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    colormenu:Visible(true)
    local typee = NativeUI.CreateListItem(Translation[Config.Locale]['Type'], options, options[0])
    colormenu:AddItem(typee)


    for k, v in pairs(Config.Colors) do
        local color = NativeUI.CreateItem(v.colorname, "")
        colormenu:AddItem(color)
        if not v.enabled then
            color:Enabled(false)
            color:SetRightBadge(BadgeStyle.Lock)
        else
            color:RightLabel(v.rlabel)
        end
        color.Activated = function(sender, index)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            progressbarorsomething()
            if typey ~= nil and string.match(typey, Translation[Config.Locale]['SecondaryColor']) then
                if Debug() then
                    print("secondary!")
                end
                SetVehicleCustomSecondaryColour(vehicle, v.r, v.g, v.b)
            elseif typey == nil or string.match(typey, Translation[Config.Locale]['PrimaryColor']) then
                SetVehicleCustomPrimaryColour(vehicle, v.r, v.g, v.b)
            end
        end
    end
    if Config.AllowRGB then
        local rgb = {}
        for i = 1, 255, 1 do
            table.insert(rgb, i)
        end
        local spacing = NativeUI.CreateItem("---------------------------------------------------------------------", "")
        colormenu:AddItem(spacing)
        spacing:Enabled(false)
        local redd, greenn, bluee = GetVehicleColor(vehicle)
        local red = NativeUI.CreateListItem(Translation[Config.Locale]['R'], rgb, redd)
        colormenu:AddItem(red)
        local green = NativeUI.CreateListItem(Translation[Config.Locale]['G'], rgb, greenn)
        colormenu:AddItem(green)
        local blue = NativeUI.CreateListItem(Translation[Config.Locale]['B'], rgb, bluee)
        colormenu:AddItem(blue)

        --local submit = NativeUI.CreateItem(Translation[Config.Locale]['SubmitC'], "")
        -- colormenu:AddItem(submit)
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)

                colormenu.OnListChange = function(sender, item, index)
                    --local one, two, three = GetVehicleColor(vehicle)
                    if item == typee then
                        typey = typee:IndexToItem(index)

                    end
                    if item == red then
                        if red:IndexToItem(index) then
                            one = red:IndexToItem(index)
                            print(one, two, three)
                        end
                    end
                    if item == green then
                        two = green:IndexToItem(index)
                        if green:IndexToItem(index) then
                            print(one, two, three)
                        end
                    end
                    if item == blue then
                        three = blue:IndexToItem(index)
                        if blue:IndexToItem(index) then
                            print(one, two, three)
                        end
                    end
                    if typey == nil or string.match(typey, Translation[Config.Locale]['PrimaryColor']) then
                        SetVehicleCustomPrimaryColour(vehicle, one, two, three)
                    elseif typey ~= nil or string.match(typey, Translation[Config.Locale]['SecondaryColor']) then
                        SetVehicleCustomSecondaryColour(vehicle, one, two, three)
                    end
                end
            end
        end)

    end
    colormenu.OnListChange = function(sender, item, index)
        if item == blue then
            bluee = blue:IndexToItem(index)
        elseif item == green then
            greenn = green:IndexToItem(index)
        end
    end
    backitem(colormenu)
end

function openextrasmenu()
    mainmenu:Visible(false)
    extrasmenu = NativeUI.CreateMenu(Translation[Config.Locale]['ExtrasMenuName'], "")
    _menuPool:Add(extrasmenu)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    extrasmenu:Visible(true)

    local veh_extras = {}
    local items = {}
    local vehicle = GetVehiclePedIsIn(PlayerPedId())

    for extraID = 0, 20 do
        if DoesExtraExist(vehicle, extraID) then
            veh_extras[extraID] = (IsVehicleExtraTurnedOn(vehicle, extraID) == 1)
        end
    end

    local customCar = false

    for _, CustomExtra in pairs(Config.CustomNames) do
        for k, _ in pairs(veh_extras) do
            if GetEntityModel(vehicle) == GetHashKey(CustomExtra.vehicle) then
                x = "" .. k .. ""
                local extraItem = NativeUI.CreateCheckboxItem(CustomExtra.extra[x], veh_extras[k], "")
                extrasmenu:AddItem(extraItem)
                items[k] = extraItem
                customCar = true
            end
        end
    end

    if customCar == false then
        for _, CustomExtra in pairs(Config.CustomNames) do
            for k, _ in pairs(veh_extras) do
                local extraItem = NativeUI.CreateCheckboxItem('Extra ' .. k, veh_extras[k], "")
                extrasmenu:AddItem(extraItem)
                items[k] = extraItem
            end
        end
    end

    extrasmenu.OnCheckboxChange = function(sender, item, checked)
        for k, v in pairs(items) do
            if item == v then
                veh_extras[k] = checked
                if veh_extras[k] then
                    SetVehicleExtra(vehicle, k, 0)
                else
                    SetVehicleExtra(vehicle, k, 1)
                end
            end
        end
    end

    backitem(extrasmenu)
end

function openperformancemenu()
    mainmenu:Visible(false)
    performancemenu = NativeUI.CreateMenu(Translation[Config.Locale]['PerformanceMenuName'], "")
    _menuPool:Add(performancemenu)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    performancemenu:Visible(true)
end

function backitem(menu)
    local back = NativeUI.CreateItem(Translation[Config.Locale]['Back'], "")
    menu:AddItem(back)
    back:RightLabel('~r~>>>')
    back.Activated = function(sender, index)
        _menuPool:CloseAllMenus()
        openmainmenu()
    end
end
