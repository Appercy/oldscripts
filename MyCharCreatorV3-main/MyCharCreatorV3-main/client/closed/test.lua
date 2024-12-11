-- RegisterCommand('testyy', function(source, args, rawCommand)
--     --     mainmenu = NativeUI.CreateMenu("yay", "", 0, 0, nil, nil, 0, 0, 0, 0)
--     --     _menuPool:ControlDisablingEnabled(false)
--     --     _menuPool:Add(mainmenu)
--     --     _menuPool:RefreshIndex()
--     --     _menuPool:MouseControlsEnabled(false)
--     --     _menuPool:MouseEdgeEnabled(false)
--     --     _menuPool:ControlDisablingEnabled(false)
--     --     --mainmenu:Visible(true)
--     --     local function DrawGlare(scaleform)
--     --         local width = GetActiveScreenResolution()
--     --         local height = width / 2 -- Use any suitable height

--     --         local x = (width - width) / 2
--     --         local y = (height - height) / 2

--     --         local heading = GetGameplayCamRelativeHeading()

--     --         while true do
--     --             Citizen.Wait(0)

--     --             BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
--     --             ScaleformMovieMethodAddParamFloat(heading)
--     --             EndScaleformMovieMethod()

--     --             DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
--     --         end
--     --     end

--     --     Citizen.CreateThread(function()
--     --         local scaleform = RequestScaleformMovie("MP_MENU_GLARE")

--     --         while not HasScaleformMovieLoaded(scaleform) do
--     --             Citizen.Wait(0)
--     --         end

--     --         DrawGlare(scaleform)
--     --     end)


--     local scaleform = RequestScaleformMovie("MP_RESULTS_PANEL")
--     while not HasScaleformMovieLoaded(scaleform) do
--         Citizen.Wait(0)
--     end

--     BeginScaleformMovieMethod(scaleform, "INITIALISE")
--     PushScaleformMovieMethodParameterInt(5000)
--     BeginScaleformMovieMethod(scaleform, "SHOW")

--     BeginScaleformMovieMethod(scaleform, "STAY_ON_SCREEN")


--     PushScaleformMovieMethodParameterString("test")
--     EndScaleformMovieMethod()

--     Citizen.CreateThread(function()
--         while true do
--             Citizen.Wait(0)
--             DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
--         end
--     end)
-- end)
