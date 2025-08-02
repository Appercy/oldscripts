-- NPC = {}
-- iNPC = {}
-- NPC.Create = function(model, coords, data)
--     local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.heading, false, false)
--     SetEntityAsMissionEntity(ped, true, true)
--     SetBlockingOfNonTemporaryEvents(ped, true)
--     SetPedCanBeTargetted(ped, false)
--     SetPedCanBeTargettedByPlayer(ped, false)
--     SetPedCanBeTargettedByTeam(ped, false)
--     iNPC[#iNPC+1] = { ped = ped, data = data, coords = coords }
--     return ped
-- end

-- NPC.Delete = function(ped)
--     DeleteEntity(v.ped)
--     iNPC[ped] = nil
-- end

-- NPC.DeleteAll = function()
--     for k,v in pairs(iNPC) do
--         DeleteEntity(v.ped)
--         iNPC[k] = nil
--     end
-- end

-- NPC.GetNPCByCoords = function(coords)
--     for k,v in pairs(iNPC) do
--         if v.coords == coords then
--             return v
--         end
--     end
--     return nil
-- end


-- return NPC