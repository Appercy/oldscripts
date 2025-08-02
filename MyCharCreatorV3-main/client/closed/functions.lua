function translation(string, secondVariable)
    local result = Translation[Config.Locale][string]
    if secondVariable then
        result = result:gsub("%%s", secondVariable)
    end
    return result or string
end

function isincharselect()
    return incharselect
end

-- Function to make a ped slowly turn their heading
function SlowlyTurnPedHeading(ped, heading)
    local targetHeading

    -- Determine the target heading based on the turn direction
    if heading == nil then
        targetHeading = GetEntityHeading(ped)
    else
        targetHeading = heading
    end

    local currentHeading = GetEntityHeading(ped)

    Citizen.CreateThread(function()
        while currentHeading ~= targetHeading do
            local headingDifference = targetHeading - currentHeading
            local rotationSpeed = 1.0 -- Adjust as needed

            if headingDifference < -180.0 then
                headingDifference = headingDifference + 360.0
            elseif headingDifference > 180.0 then
                headingDifference = headingDifference - 360.0
            end

            local newHeading = currentHeading + rotationSpeed * headingDifference
            if newHeading < 0.0 then
                newHeading = newHeading + 360.0
            elseif newHeading >= 360.0 then
                newHeading = newHeading - 360.0
            end

            SetEntityHeading(ped, newHeading)
            Citizen.Wait(0) -- Adjust the delay as needed

            currentHeading = newHeading
        end
    end)
end

function reset()
    destroyallcams()
end
