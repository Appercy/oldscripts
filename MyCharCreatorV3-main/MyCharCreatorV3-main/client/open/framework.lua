if (GetResourceState("es_extended") == "started") then
  if (exports["es_extended"] and exports["es_extended"].getSharedObject) then
    ESX = exports["es_extended"]:getSharedObject()
  else
    TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
  end
end

function getPlayerSkin()
  TriggerEvent('skinchanger:getSkin', function(skin)
    skin = currentskin
  end)
  return currentskin
end

function saveSkin(skin)
  skinn = Config.DefaultSkin or skin or getplayerskin()
  TriggerServerEvent("esx_skin:save", skinn)
end

function getplayermoney()
end

function removeplayermoney(amount)
end

function hasenoughmoney(amount)
end
