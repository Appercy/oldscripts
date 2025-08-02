activecams = {}
currentactivecam = 1
incamswitch = flase
function startskincam()
    TriggerEvent('esx_skin:getLastSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', Config.DefaultSkin or skin)
    end)
    Config.Functions.onstart()
    disableallcontrols(true)
    SetEntityCoords(PlayerPedId(), Config.Start.coords.x, Config.Start.coords.y, Config.Start.coords.z, 0.0, 0.0, 0.0, 0)
    SetEntityHeading(PlayerPedId(), Config.Start.coords.w or 90.0)
    print(Config.CameraCoords[Config.StartOn].coords.x, Config.CameraCoords[Config.StartOn].coords
        .y,
        Config.CameraCoords[Config.StartOn].coords.z,
        Config.CameraCoords[Config.StartOn].rotx, Config.CameraCoords[Config.StartOn].roty,
        Config.CameraCoords[Config.StartOn].rotz,
        Config.CameraCoords[Config.StartOn].fov)
    firstcam = createcam(Config.CameraCoords[Config.StartOn].coords.x, Config.CameraCoords[Config.StartOn].coords
        .y,
        Config.CameraCoords[Config.StartOn].coords.z,
        Config.CameraCoords[Config.StartOn].rotx, Config.CameraCoords[Config.StartOn].roty,
        Config.CameraCoords[Config.StartOn].rotz,
        Config.CameraCoords[Config.StartOn].fov, true)
    if Config.Start.anim.enabled then
        LoadAnim(Config.Start.anim.dict)
        TaskPlayAnim(PlayerPedId(), Config.Start.anim.dict, Config.Start.anim.name, 1.0, 1.0, 4000, 0, 1, 0, 0, 0)
        Citizen.Wait(Config.Start.anim.wait or 5000)
    end
    currentactivecam = Config.StartOn
end

function nextcam(lastcam, index)
    if index then
        currentactivecam = index
    else
        if currentactivecam + 1 > #Config.CameraCoords then
            currentactivecam = currentactivecam - 1
        else
            currentactivecam = currentactivecam + 1
        end
    end


    return createcam(Config.CameraCoords[currentactivecam].coords.x, Config.CameraCoords[currentactivecam].coords.y,
        Config.CameraCoords[currentactivecam].coords.z,
        Config.CameraCoords[currentactivecam].rotx, Config.CameraCoords[currentactivecam].roty,
        Config.CameraCoords[currentactivecam].rotz,
        Config.CameraCoords[currentactivecam].fov, true, GetRenderingCam() or lastcam, 900)
end

-- function headcam(lastcam)
--     camnow = 1
--     return createcam(Config.CameraCoords.face.x, Config.CameraCoords.face.y, Config.CameraCoords.face.z,
--         Config.CameraCoords.face.rotx, Config.CameraCoords.face.roty, Config.CameraCoords.face.rotz,
--         Config.CameraCoords.face.fov, true, GetRenderingCam() or lastcam, 900)
-- end

-- function torsocam(lastcam)
--     camnow = 2
--     return createcam(Config.CameraCoords.torso.x, Config.CameraCoords.torso.y, Config.CameraCoords.torso.z,
--         Config.CameraCoords.torso.rotx, Config.CameraCoords.torso.roty, Config.CameraCoords.torso.rotz,
--         Config.CameraCoords.torso.fov, true, GetRenderingCam() or lastcam, 900)
-- end

-- function fullbodycam(lastcam)
--     camnow = 3
--     return createcam(Config.CameraPositions[Config.StartOn].x, Config.CameraPositions[Config.StartOn].y, Config.CameraPositions[Config.StartOn].z,
--         Config.CameraPositions[Config.StartOn].rotx, Config.CameraPositions[Config.StartOn].roty, Config.CameraPositions[Config.StartOn].rotz,
--         Config.CameraPositions[Config.StartOn].fov, true, GetRenderingCam() or lastcam, 900)
-- end

function removecam(cam)
    SetCamActive(cam, false)
    DestroyCam(cam)
end

function destroyallcams()
    for k, v in pairs(activecams) do
        SetCamActive(cam, false)
        DestroyCam(v)
    end
end

function getcurrentcam()
    return GetRenderingCam() or activecams[#activecams]
end

function createcam(x, y, z, rotx, roty, rotz, fov, active, secondcam, camtransitiontime)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x or 0, y or 0, z or 0, rotx or (5.54), roty or (1.0),
        rotz or (0),
        fov or (45.0), false, 0)
    table.insert(activecams, cam)
    if active and not secondcam then
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    end
    if active then
        SetCamActiveWithInterp(cam, secondcam, camtransitiontime or 900, true, true)
        incamswitch = true
        Citizen.Wait(900)
        incamswitch = false
        DestroyCam(secondcam)
    end
    return cam
end

-- function createbonecam(bone, xoffset, yoffset, zoffset, rotx, roty, rotz, fov, active, secondcam, camtransitiontime)
--     print(bone)
--     bonecoords = GetPedBoneCoords(PlayerPedId(), bone, xoffset, yoffset, zoffset)
--     cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", bonecoords.x, bonecoords.y, bonecoords.z, rotx or (5.54),
--         roty or (1.0),
--         rotz or (0),
--         fov or (45.0), false, 0)
--     table.insert(activecams, cam)
--     if active and not secondcam then
--         SetCamActive(cam, true)
--         RenderScriptCams(true, false, 1, true, true)
--     end
--     if active then
--         SetCamActiveWithInterp(cam, secondcam, camtransitiontime or 900, true, true)
--         incamswitch = true
--         Citizen.Wait(900)
--         incamswitch = false
--         DestroyCam(secondcam)
--     end
--     return cam
-- end

-- function rotatetonextcam(top)
--     currentcam = getcurrentcam()
--     print(currentactivecam)
--     if currentcam then
--         removecam(currentcam)
--     end
--     if top then
--         bone = false or Config.CameraCoords[currentactivecam].bone
--         camera = false or Config.CameraCoords[currentactivecam].camera
--         if bone then
--             camPos = bone
--             bonecoords = GetPedBoneCoords(PlayerPedId(), camPos.id, camPos.xoffset, camPos.yoffset,
--                 camPos.zoffset)
--             local cam = createcam(bonecoords.x, bonecoords.y, bonecoords.z, camPos.rotx, camPos.roty,
--                 camPos.rotz, camPos.fov, false,
--                 currentcam or GetRenderingCam(),
--                 900)

--             if currentactivecam == #Config.CameraCoords then
--                 currentactivecam = currentactivecam - 1
--             else
--                 currentactivecam = currentactivecam + 1
--             end

--             SetCamActiveWithInterp(cam, currentcam, 900 or camPos.transitiontime, 0, 0)
--             incamswitch = true
--             Citizen.Wait(camPos.transitiontime or camPos.wait)
--             incamswitch = false

--             table.insert(activecams, cam)
--             RenderScriptCams(true, false, 1, true, true)
--             currentactivecam = currentactivecam + 1
--         elseif camera then
--             camPos = camera
--             local cam = createcam(camPos.x, camPos.y, camPos.z, camPos.rotx,
--                 camPos.roty, camPos.rotz, camPos.fov, false,
--                 currentcam or GetRenderingCam(),
--                 900)
--             currentactivecam = currentactivecam + 1
--             SetCamActiveWithInterp(cam, currentcam, 900 or camPos.transitiontime, 0, 0)
--             incamswitch = true
--             Citizen.Wait(camPos.transitiontime or camPos.wait)
--             incamswitch = false

--             table.insert(activecams, cam)
--             RenderScriptCams(true, false, 1, true, true)

--             if currentactivecam ~= #Config.CameraCoords then
--                 currentactivecam = currentactivecam + 1
--             else
--                 currentactivecam = currentactivecam - 1
--             end
--         end
--     elseif not top then

--     end
-- end

currentrotation = 0
function rotateped(left)
    if left then
        if currentrotation == 0 then
            currentrotation = 2
            turnleft()
        elseif currentrotation == 1 then
            currentrotation = 0
            turnforward()
        elseif currentrotation == 2 then
            currentrotation = 1
            turnright()
        end
    else
        if currentrotation == 0 then
            currentrotation = 1
            turnright()
        elseif currentrotation == 1 then
            currentrotation = 2
            turnleft()
        elseif currentrotation == 2 then
            currentrotation = 0
            turnforward()
        end
    end
end
