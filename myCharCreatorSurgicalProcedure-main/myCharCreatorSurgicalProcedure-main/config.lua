Config = {}
Config.Debug = true
Config.Locale = "de" 
Config.Price =  20 -- nil for free!
Config.Account = "money"-- "money", "bank", or "both"

Config.Coords = {  -- https://docs.fivem.net/docs/game-references/blips/ -- https://docs.fivem.net/docs/game-references/markers/  
    { 
    coords = vector3(9.1409, -981.0445, 29.4971),
    range = vec3(3, 3, 3), 
    rotation = 0,
     blip = { enabled = true, name = "Schönheitschirug", id = 267, colorid = 3, scale = 0.55},
     marker = { enabled = true, zoffset = 1,markerid = 36, scalex = 0.9, scaley = 0.9, scalez = 0.9, red = 0, green = 0, blue = 255, alpha = 150, bobUpAndDown = false, faceCamera = true, rotx = 0.0, roty = 180.0, rotz = 0, rotx = 0.0, roty = 0.0, rotz = 0,  }
    },

    { 
    coords = vector3(14.3987, -985.1759, 29.4150),
    range = vec3(3, 3, 3), 
    rotation = 0, 
    blip = { enabled = false}, 
    marker = {enabled = false},
},
}
Config.Event = 'myCreator:openMenu'
Translation = {
        ['de'] = {
            ['textui'] = "[E] - Öffne SchönheitsChirug",
            ['done'] = "Dir wurden %s $ Abgezogen für die Behandlung viel Spaß mit deinem neuen aussehen!!",
            ['notenough'] = "Du hast nicht genug geld, der Preis beträgt: %s $", 
        },
        ['en'] = {
            ['textui'] = "[E] - Open CharCreator",
            ['done'] = "%s $ got removed from your Pocket for the Surgical Procedure have fun!",
            ['notenough'] = "You Dont have Enough money, the price is: %s$", 
        }
}

function notify(msg)
    lib.notify({
        id = 'LC',
        title = 'SchönheitsChirug',
        description = msg,
        position = 'bottom',
        style = {
            backgroundColor = 'black',
            color = "white"
        },
        icon = "user-doctor",
        iconColor = 'white'
    })
    --ESX.ShowNotification(msg)
    
end

function textuistart(msg)

    lib.showTextUI(msg, {
        position = "top-center",
        icon = 'user-doctor',
        style = {
            borderRadius = 0,
            backgroundColor = 'black',
            color = 'white'
        }
    })
end

function textuiend(msg)
    lib.hideTextUI()
end

function textuithread()
    -- ESX.ShowNotification()
end
