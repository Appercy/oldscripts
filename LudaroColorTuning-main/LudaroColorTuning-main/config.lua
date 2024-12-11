Config = {}
Translation = {}


-- General SETTINGS!!
Config.Locale = 'en'
Config.Debug = false
Config.Button = 38 -- https://docs.fivem.net/docs/game-references/controls/

Config.Coloring = true
Config.Extras = true
Config.ESX = true -- is only there for showhelpnotification, nothing else :)


-- Prices!
Config.ExtrasPrice = 50 -- how much it costs to access the extras menu
Config.ColorsPrice = 50 -- how much it costs to access the extras menu
Config.Currency = "$"
-- Prices End!
Config.Coords = vector3(-340.3820, -1464.1198, 30.1756) -- will be there as a table
Config.Marker = { Enabled = true, MarkerID = 2, R = 0, B = 255, G = 0, Opacity = 100, Width = 1.0, Height = 1.0,
    FollowsPlayerCamera = false, }
Config.Range = 20
-- General Settings end!!
Config.Job = "unemployed" -- for the job filtering if you want it only if esx exists

-- Coloring!!

Config.AllowRGB = true
Config.Colors = {
    { colorname = "~r~red", r = 255, g = 0, b = 0, enabled = true, rlabel = '~r~>>>' },
    { colorname = "~g~green", r = 0, g = 255, b = 0, enabled = true, rlabel = '~g~>>>' },
    { colorname = "~b~blue", r = 0, g = 255, b = 0, enabled = false, rlabel = '~b~>>>' },
}

-- EXTRAS!!--
Config.CustomNames = {
    -- for extras!
    { vehicle = '19Charger', extra = {
        ['1'] = 'Ram Bar', ['2'] = 'Light Bar', ['3'] = 'Visor Lights', ['4'] = 'Dashboard Lights', ['5'] = 'Spot Lights'
    } },
}
--EXTRAS END!!--

-- Performance!!--
--Config.Performance = true

function progressbarorsomething()

    -- this will always apply when a color gets changed, or an extra gets done, you can input anything here, :)
end

-- Coloring END!!

Translation = {
    ['de'] = {
        ['MainMenuName'] = "Tuning-shop",
        ['ChangeColor'] = "Ändere die farbe deines autos",
        ['Extras'] = "Ändere die Extras deines autos",
        ['ExtrasMenuName'] = "Extras-shop",
        ['ColorMenuName'] = "Farb-shop",
        ['R'] = "~r~Rot!",
        ['B'] = "~b~Blau",
        ['G'] = "~g~Grün",
        ['SubmitC'] = "Auto Färben",
        ['ExtraC'] = "Extra Farb Optionen",
        ['Type'] = "Farb-Modus",
        ['PrimaryColor'] = "Primärfarbe",
        ['SecondaryColor'] = "Sekündärfarbe",
        ['Back'] = "Zurück",
        ['notify'] = 'Drücke ~INPUT_CONTEXT~ um dein Auto-Verschönerungs Menü zu öffnen',
        ['price'] = 'Der Preis Beträgt: ',



    },
    ['en'] = {
        ['MainMenuName'] = "Tuning-shop",
        ['ChangeColor'] = "Change the Colors of your car",
        ['Extras'] = "Change the Extras of your car!",
        ['ExtrasMenuName'] = "Extras-shop",
        ['ColorMenuName'] = "Color-shop",
        ['R'] = "~r~Red!",
        ['B'] = "~b~Blue",
        ['G'] = "~g~Green",
        ['SubmitC'] = "Color it!",
        ['Type'] = "Color-Type",
        ['PrimaryColor'] = "Primary-Color",
        ['SecondaryColor'] = "Secondary-Color",
        ['Back'] = "back",
        ['notify'] = 'Press ~INPUT_CONTEXT~ to open the Car Menu',
        ['price'] = 'The Price is: ',
    }
}
