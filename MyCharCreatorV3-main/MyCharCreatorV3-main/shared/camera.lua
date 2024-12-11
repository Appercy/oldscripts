Config = {}
-- Config.SeperateRoom = true -- enables being in a seperate room instead of where you are right now
Config.PedCoords = vector4(405.59, -997.18, -99.00, 90.00)

-- https://wiki.rage.mp/index.php?title=Bones
-- 1 will always be shown, and fullbodycam is always 0
-- if bone not existent it will take camera
Config.StartOn = 1 -- if nil then it starts on fullbodycam
Config.Start = {
    coords = vector4(405.59, -997.18, -99.00, 90.0),
    anim = { enabled = true, dict = "mp_character_creation@customise@male_a", name = "intro", wait = 5000 }
}

Config.CameraCoords = {
    [1] = { coords = vector3(402.92, -1000.72, -99.01), fov = nil, rotx = nil, roty = nil, rotz = nil, h = nil, control = {
        id = 74, name = "Full Body" }, },
    [2] = { coords = vector3(402.99, -998.02, -99.00), fov = nil, rotx = nil, roty = nil, rotz = nil, h = nil, control = {
        id = 47, name = "Torso" }, bone = { id = 14021, mousesprite = 3, range = 0.2 }, },
    [3] = { coords = vector3(402.92, -998.02, -98.45), fov = nil, rotx = nil, roty = nil, rotz = nil, h = nil, control = {
        id = 48, name = "Face" } },
}

Config.RotatePed = { mouse = true, 

[1] = { controlid = 20, heading = 100.0 }

},
Config.RotationHeadings = { front = 200.0, left = 100.0, right = 100.0, back = 200.0 } -- front = reset
-- Config.CameraPositions = {
--     [1] = {
--         camera = {W
--             x = 402.92,
--             y = -1000.72,
--             z = -99.01,
--             fov = 40.00,
--             rotx = nil,
--             roty = nil,
--             rotz = nil,
--             h = nil,
--             fov = nil,
--             wait = 5000
--         } -- this is the cam thats shown in the beginning
--     },
--     [2] = {
--         bone = {
--             id = 12844,
--             fov = 45.0,
--             xoffset = 0.0,
--             yoffset = 0.0,
--             zoffset = 0.0,
--             rotx = 0.0,
--             roty = 0.0,
--             rotz = 0.0,
--             transitiontime = 5000,
--             wait = 5000
--         },
--         control = { name = "Head", key = 49 },
--     },
--     [3] = {
--         bone = {
--             id = 24818,
--             fov = 45.0,
--             xoffset = 0.0,
--             yoffset = 0.0,
--             zoffset = 0.0,
--             rotx = 0.0,
--             roty = 0.0,
--             rotz = 0.0,
--             transitiontime = 5000,
--             wait = 5000
--         },
--         control = { name = "Full Body", key = 74 },
--     },
--     [4] = {
--         boneid = 24818,
--         control = { name = "Foot", key = 75 },
--     }
-- }
