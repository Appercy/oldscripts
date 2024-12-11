Config.HasIPL = false -- enables loading IPL's
Config.Debug = true
Config.MenuOptions = {
    Color = { R = 0, G = 0, B = 0, A = 255 },
    Position = { X = nil, Y = nil, }, -- NIL if you want it in the default position
    Font = 1
}
Config.Controls = {
    head = {
        switch = 49,
    },
    torso = {
        switch = 47,
    },
    fullbody = {
        switch = 74,
    },
    foot = {
        switch = 75,
    },
    

    ped = {
        lookleft = 34,
        lookright = 35,
        lookforward = 21,
        turnup = 241,   -- this is mousewheel up,
        turndown = 242, -- this is mousewheel down,
        turnright = { key = 174, heading = 277.0 },
        turnleft = { key = 175, heading = 100.0 },
        turnforward = { key = 173, heading = 187.0 },

    }

}



--- https://docs.fivem.net/docs/game-references/controls/
