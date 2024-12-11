function disableallcontrols(toggle)
   if toggle then
      Citizen.CreateThread(function()
         while true do
            Citizen.Wait(0)
            if toggle then
               DisableAllControlActions(0)
               EnableControlAction(0, 1)
               EnableControlAction(0, 2)
               EnableControlAction(0, 4)
               EnableControlAction(0, 6)
               EnableControlAction(0, 10)
               EnableControlAction(0, 11)
               EnableControlAction(0, 18)
               EnableControlAction(0, 202) -- ESC ONE OF BOTH IS ESC LOL
               EnableControlAction(0, 200) --ESC
               DisableControlAction(0, 73)
               DisableControlAction(0, 0)
               EnableControlAction(0, Config.Controls.head.switch)
               EnableControlAction(0, Config.Controls.torso.switch)
               EnableControlAction(0, Config.Controls.fullbody.switch)
               HideHudComponentThisFrame(11)
               HideHudComponentThisFrame(12)
               HideHudComponentThisFrame(21)
               HideHudAndRadarThisFrame()
               DisplayRadar(false)

               SetEntityInvincible(PlayerPedId(), true)
               SetEntityVisible(PlayerPedId(), true)
            else
               return
            end
         end
      end)
   end
end

if Config.HasIPL then
   Citizen.CreateThread(function()
      Config.Functions.LoadIPL()
   end)
end

function checkcameracontrols()
   -- cursor + controls will be fixed soon
   Citizen.CreateThread(function()
      while true do
         Citizen.Wait(0)
         -- check controls
         for k, v in pairs(Config.Controls) do
            if (v.switch and not IsControlEnabled(v.switch)) then
               EnableControlAction(0, v.switch, true)
            end

            if (v.lookleft and not IsControlEnabled(v.lookleft)) then
               EnableControlAction(0, v.lookleft, true)
            end

            if (v.lookright and not IsControlEnabled(v.lookright)) then
               EnableControlAction(0, v.lookright, true)
            end

            if (v.lookforward and not IsControlEnabled(v.lookforward)) then
               EnableControlAction(0, v.lookforward, true)
            end

            if (v.turnright and v.turnright.key and not IsControlEnabled(v.turnright.key)) then
               EnableControlAction(0, v.turnright.key, true)
            end

            if (v.turnleft and v.turnleft.key and not IsControlEnabled(v.turnleft.key)) then
               EnableControlAction(0, v.turnleft.key, true)
            end

            if (v.turnforward and v.turnforward.key and not IsControlEnabled(v.turnforward.key)) then
               EnableControlAction(0, v.turnforward.key, true)
            end

            if (v.turnup and not IsControlEnabled(v.turnup)) then
               EnableControlAction(0, v.turnup, true)
            end

            if (v.turndown and not IsControlEnabled(v.turndown)) then
               EnableControlAction(0, v.turndown, true)
            end
         end
         if (not IsControlEnabled(0, 239)) then
            EnableControlAction(0, 239, true)
         end
         if (not IsControlEnabled(0, 240)) then
            EnableControlAction(0, 240, true)
         end

         -- use the god damn controls
         -- if IsControlJustPressed(0, Config.Controls.head.switch) then
         --    headcam()
         --    Citizen.Wait(100)
         -- end
         -- if IsControlJustPressed(0, Config.Controls.torso.switch) then
         --    torsocam()
         --    Citizen.Wait(100)
         -- end
         -- if IsControlJustPressed(0, Config.Controls.fullbody.switch) then
         --    fullbodycam()
         --    Citizen.Wait(100)
         -- end

         -- if IsControlJustPressed(0, Config.Controls.foot.switch) then
         --    footcam()
         --    Citizen.Wait(100)
         -- end

         -- for k, v in pairs(Config.CameraCoords) do
         --    if v.control and IsControlJustPressed(0, v.control.key) then
         --       if v.bone and v.bone.id and v.bone.fov then
         --          createbonecam(v.bone.id, v.bone.fov, v.bone.xoffset, v.bone.yoffset, v.bone.zoffset, v.bone.rotx,
         --             v.bone.roty, v.bone.rotz, v.bone.transitiontime, v.bone.wait)
         --       end
         --    end
         -- end

         -- if IsControlJustPressed(0, Config.Controls.ped.lookleft) then
         --    local heading = GetGameplayCamRelativeHeading()
         --    SetGameplayCamRelativeHeading(heading - 1.0)
         --    Citizen.Wait(100)
         -- end

         -- if IsControlJustPressed(0, Config.Controls.ped.lookright) then
         --    local heading = GetGameplayCamRelativeHeading()
         --    SetGameplayCamRelativeHeading(heading + 1.0)
         --    Citizen.Wait(100)
         -- end

         -- if IsControlJustPressed(0, Config.Controls.ped.lookforward) then
         --    SetGameplayCamRelativeHeading(0.0)
         --    Citizen.Wait(100)
         -- end

         -- if IsControlJustPressed(2, Config.Controls.ped.turnup) then
         --    Citizen.Trace("what the fuck")
         -- end
         hit, worldPosition, normalDirection, entity = getcursorworldpos()

         for k, v in pairs(Config.CameraCoords) do
            if v.control and v.control.id then
               if IsControlJustPressed(0, v.control.id) then
                  nextcam(k)
               end
               if v.bone then
                  ismouseonbone
                  if ismouseonbone(worldPosition, v.bone.id, 0.4 or v.bone.range) then
                     if v.bone.mousesprite then
                        SetCursorSprite(1 or v.bone.mousesprite)
                        if lmbpressed(true) then
                           nextcam(k)
                        end
                     end
                  end
               end
            end
         end

         if Config.RotatePed.mouse == true then
            if getcursorpos().y > 0.90 then
               SetCursorSprite(9)
               if lmbpressed(true) then
                  SetCursorSprite(9)
                  turnped
               end
            elseif getcursorpos().y < 0.04 then

            elseif getcursorpos().x > 0.90 and lmbpressed(true) then
               rotateped()
               SetCursorSprite(10)
            elseif getcursorpos().x < 0.04 and lmbpressed(true) then
               rotateped()
               SetCursorSprite(10)
            end
         end

         if Config.RoratePed.Controls ~= nil then

            for k,v in pairs(Config.RotatePed) do
               if IsControlJustPressed(0, v.controlid) then
                  SlowlyTurnPedHeading(PlayerPedId(), v.heading)
               end
            end
            
         end 
      end
   end)

   Citizen.CreateThread(function()
      while true do
         for _, sprite in ipairs(sprites) do
            sprite:Draw()
         end
         Citizen.Wait(0)
      end
   end)
end

function drawsprites()
   Citizen.CreateThread(function()
      while true do
         for _, sprite in ipairs(sprites) do
            sprite:Draw()
         end
         Citizen.Wait(0)
      end
   end)
end
