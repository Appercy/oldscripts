if (GetResourceState("es_extended") == "started") then
    if (exports["es_extended"] and exports["es_extended"].getSharedObject) then
        ESX = exports["es_extended"]:getSharedObject()
    else
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end
end


function debug(msg)
    if Config.Debug then
        if type(msg) == "table" then
            print(print(ESX.DumpTable(msg)))
        else
            print("[Ludaro|Debug] : " .. tostring(msg))
        end
    end
end
local hasenoughmoney
function openmenu()
    debug("opening menu..")
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if skin ~= nil then
            TriggerEvent(Config.Event) 
            Wait(2000)
              TriggerEvent('skinchanger:loadSkin', skin)
        end
    end)
    Wait(2000)
end
function onEnter(self)
    textuistart(Translation[Config.Locale]["textui"])
    debug('entered zone ' .. self.id)
    hasenoughmoney = lib.callback.await('ludaro:getprice', false)
    debug(hasenoughmoney)
end

function onExit(self)
    textuiend()
    debug('exited zone ' .. self.id)
end

function insideZone(self)
    textuithread()
    if IsControlJustReleased(0, 38) then
        if Config.Price ~= nil then
            debug(hasenoughmoney)
                if hasenoughmoney == true then
                    openmenu()
                    notify(string.format(Translation[Config.Locale]["done"], Config.Price))
                    TriggerServerEvent("ludaro:removeprice")
                else
                 
                    notify(string.format(Translation[Config.Locale]["notenough"], Config.Price))
                end
            elseif Config.Price == nil then
    openmenu()
        end
    end
end

for k,v in pairs(Config.Coords) do 

local box = lib.zones.box({
    coords = v.coords,
    size = v.range,
    rotation = v.rotation,
    debug = Config.Debug,
    inside = insideZone,
    onEnter = onEnter,
    onExit = onExit
})
if v.blip.enabled then
    local name = v.blip.name
local blip = AddBlipForCoord(v.coords)
		SetBlipSprite (blip, v.blip.id)
		SetBlipScale  (blip, v.blip.scale)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, v.blip.colorid)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING') 
		AddTextComponentString(name)
		EndTextCommandSetBlipName(blip)
end
end
local marker 
for k,v in pairs(Config.Coords) do 
    if v.marker.enabled then
        marker = true
        debug("starting to draw marker..")
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
 if marker ~= nil then
    for k,v in pairs(Config.Coords) do 
        DrawMarker(v.marker.markerid, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, v.marker.rotx, v.marker.roty, v.marker.rotz, v.marker.scalex, v.marker.scaley, v.marker.scalez, v.marker.red, v.marker.green, v.marker.blue, v.marker.alpha, v.marker.bobUpAndDown, v.marker.faceCamera, 2, nil, nil, false)
    end
 end
    end
end)
