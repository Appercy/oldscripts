-- local ilocations = {}
-- local NPC = require "client.functions.npc"
-- for k,v in pairs(Locations) do
--     lib.print.debug("Creating Location" .. k)
--     local point = lib.points.new({
--         coords = v.coords,
--         distance = 20, -- default distance for npc / markers
--     })

--     local marker
--     if v.marker then
--         lib.print.debug("Creating Marker for Location" .. k)
--         marker = lib.marker.new({
--             coords = v.coords,
--             type = v.marker.type,
--             color = v.marker.color,
--             width = v.marker.scale.x,
--             height = v.marker.scale.y,
--         })
--     end

--     local npcid
--     if v.npc then
--         lib.print.debug("Creating NPC for Location" .. k)
--         npcid = NPC.Create(v.npc.model, v.coords, v.data)
--     end

--     function point:nearby()
--         lib.print.verbose("Nearby location: " .. k)
--         if marker then
--             marker:draw()
--         end

--         if self.currentDistance < 1.5 then
--             EF.ShowHelpNotification(lib.locale("etoopenbank"))
--             if IsControlJustReleased(0, 38) then
--                 -- openMenu(k)
--             end
--         end
--     end

--     ilocations[k] = {
--         point = point,
--         marker = marker,
--         npc = npcid,
--         type = v.type
--     }
-- end