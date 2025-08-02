Config = {}
Config.Vending = { -- https://gtahash.ru/?s=vend
	{modelname = "prop_vend_soda_01"}
}

Config.Range = 1.5

Config.Locale = "de"

Translation = {
    ['de'] = {
       ['nearprop'] = 'Getränkeautomat',
       ['MainMenuname'] = "Getränke Automat!",
       ['MainMenuDesc'] = "Aktuelle Temperatur +7°",
       ['bought'] = "",
       ['bought2'] = "Gekauft"
    },
    ['en'] = {
        ['nearprop'] = 'Vending-Machine',
        ['MainMenuname'] = "Vending Machine!",
        ['MainMenuDesc'] = " Current temperature +7°",
        ['bought'] = "bought",
        ['bought2'] = "!"
    } 
}

Config.Currency = "$"
Config.Items = {
 {itemname = "cola", itemlabel = "Cola", price = 6, Description = ""}, --testgetränk
 {itemname = "water", itemlabel = "Wasser", price = 3, Description = ""} --testgetränk
}