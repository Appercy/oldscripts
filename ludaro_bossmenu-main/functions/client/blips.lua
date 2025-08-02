-- Blips = {}
-- BlipsList = {}
-- function Blips:CreateBlip(x, y, z, sprite, color, scale, alpha)
--     local blip = AddBlipForCoord(x, y, z)
--     SetBlipSprite(blip, sprite)
--     SetBlipColour(blip, color)
--     SetBlipScale(blip, scale)
--     SetBlipAlpha(blip, alpha)
--     BlipsList[#BlipsList + 1] = blip
--     return blip
-- end
-- function Blips:RemoveBlip(id)

--     if DoesBlipExist(blip) then
--         RemoveBlip(blip)
--     end
-- end

-- function Blips:CreateBlips()
--     for k, v in pairs(Config.Locations) do
--         if v.blip then
--             local blip = Blips:CreateBlip(v.coords.x, v.coords.y, v.coords.z, v.blip.sprite, v.blip.color, v.blip.scale, 255)
--             SetBlipAsShortRange(blip, true)
--             BeginTextCommandSetBlipName("STRING")
--             AddTextComponentString(v.name)
--             EndTextCommandSetBlipName(blip)
--         end
--     end
-- end

-- function Blips:RemoveBlips()
--     for k, v in pairs(BlipsList) do
--         if DoesBlipExist(v) then
--             RemoveBlip(v)
--         end
--     end
--     BlipsList = {}
-- end

