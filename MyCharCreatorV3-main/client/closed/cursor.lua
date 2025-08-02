function getcursorpos()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

function getcursorworldpos()
    local pos = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    local fov = GetGameplayCamFov()
    cam = getcurrentcam()
    local camRight, camForward, camUp, camPos = GetCamMatrix(cam)
    screenPosition = getcursorpos()
    screenPosition = vector2(screenPosition.x - 0.5, screenPosition.y - 0.5) * 2.0
    fovradius = (fov * 3.14) / 180.00
    local to = camPos + camForward + (camRight * screenPosition.x * fovradius * GetAspectRatio(false) * 0.534375) -
        (camUp * screenPosition.y * fovradius * 0.534375)
    local direction = (to - camPos) * 50
    local endPoint = camPos + direction
    local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, endPoint.x, endPoint.y, endPoint.z, -1, nil, 0)
    local _, hit, worldPosition, normalDirection, entity = GetShapeTestResult(rayHandle)

    if hit == 1 then
        return true, worldPosition, normalDirection, entity
    else
        return false, vector3(0, 0, 0) or worldPosition, vector3(0, 0, 0) or normalDirection, nil
    end
end

-- function degtorad(degrees)
--     return (degrees * 3.14) / 180.0
-- end

function ismouseonbone(worldPosition, boneid, range)
    return #(GetPedBoneCoords(PlayerPedId(), boneid, 1, 1, 1) - worldPosition) < range
end

function lmbpressed(once)
    if once then
        return IsDisabledControlJustPressed(0, 24)
    else
        return IsDisabledControlPressed(0, 24)
    end
end

function rmbpressed(once)
    if once then
        return IsDisabledControlJustPressed(0, 25)
    else
        return IsDisabledControlPressed(0, 25)
    end
end

function goesright()
    return GetControlNormal(0, 239) > 0.5
end

function goesleft()
    return GetControlNormal(0, 239) < 0.5
end
