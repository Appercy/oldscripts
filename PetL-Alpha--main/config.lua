-- CONFIGURATION --
Translation                    = {}
Config                    = {}
Config.Debug = false -- Does nothing for now
Config.PetModel = "a_c_chop" --https://docs.fivem.net/docs/game-references/ped-models/ only there until i fucking do it to get multiple pets,
Config.PayWithBank = false
Config.NicknameLength = 12
Config.Pets = { -- job is for restricted jobs if u want that ;)
   {name = "Rottweiler", model = "a_c_chop", price = 10, job= nil}

}

Config.FoodItems = {
    -- name is the item name -- type is the type (0 for water 1 for food) -- value is how much it gives (1-100)
    {name = "waterbottle", type = 0, value= 100}

}

function notify(msg, source)
    ESX.ShowNotification(msg)

end
Config.Blip = false
Config.Currency = "€"
Config.ESXEvent = 'esx:getSharedObject'  
Config.Blipname = "Pet-Shop!"
Config.Blipcoord = vector3(1233.8623, -3235.2698, 5.5287)
Config.NPCPositionrot = 255
Config.BlipID = 477
Config.BlipColorID = 1
Config.MarkerID = 31
Config.Locale = 'en'
Config.Yeet = false
Config.SellerNPC = "a_m_m_beach_02"
Config.SpawnAway = false -- THIS IS A BUGGY MODE THAT WONT WORK ALL THE TIME
Config.ResetCommand = "reset"
Translation = {
    ['de'] = {
        ['GetIncar'] = 'Befehl dem Hund ins auto zu Steigen',
        ['CallPet'] = 'Ruf dein Haustier!',
        ['AttackPerson'] = 'Greif diese Person an!',
        ['FollowPerson'] = 'Folg dieser Person!',
        ['GoHere'] = 'Hundi Komm Hierher!',
        ['GoHome'] = 'Hundi geh nachhause.',
        ['MainMenuName'] = "Haustier-Shop",
        ['MainMenuDesc'] = 'Alles was dein Hunde-Herz Begehrt!!',
        ['BuyMenuName'] = 'Haustier Kaufen!',
        ['notify'] = 'Drücke ~INPUT_CONTEXT~ um den Haustier-Shop zu Öffnen!',
        ['BuyItemName'] = 'Haustier-Kaufen',
        ['SellMenuName'] = 'Bist du Sicher das du dein Haustier Verkaufen willst?',
        ['yes'] = 'Ja',
        ['no'] = 'nein',
        ['sold'] = 'Du hast dein Haustier Erfologreich verkauft!',
        ['close'] = 'Menü Schließen',
        ['BuyItemDesc'] = 'Hier kannst du dein Haustier holen! <3',
        ['Bought'] = 'Du hast ein Haustier gekauft! <3',
        ['ChooseNickname'] = 'Gib deinem Haustier ein Spitzname! <3',
        ['SellItemName'] = 'Haustier-verkaufen',
        ['SellItemDesc'] = 'Hier kannst du dein Haustier Zurrückgeben ;('
    },
    ['en'] = {
        ['GetIncar'] = 'Tell your dog to get in the car',
        ['CallPet'] = 'Call your Pet',
        ['AttackPerson'] = 'Tell your dog to Attack this Person',
        ['FollowPerson'] = 'Tell your dog to Follow this Person!',
        ['GoHere'] = 'Tell your dog to go there',
        ['GoHome'] = 'Tell your dog to go home',
        ['MainMenuName'] = 'Pet-Shop',
        ['BuyMenuName'] = 'Buy A pet Here!',
        ['MainMenuDesc'] = 'everything that your Pet-Heart Desires!',
        ['BuyItemName'] = 'Buy a Pet!',
        ['SellMenuName'] = 'Are you sure you wanna sell your Pet?',
        ['yes'] = 'yes',
        ['no'] = 'no',
        ['close'] = 'Close',
        ['sold'] = 'You Sold your Pet!',
        ['Bought'] = 'You Bought a Pet! <3',
        ['BuyItemDesc'] = 'you can get a Pet here! <3',
        ['ChooseNickname'] = 'Give your Pet a Nickname!',
        ['SellItemName'] = 'Sell your Pet!',
        ['SellItemDesc'] = 'you can give back your pet here ;(',
        ['notify'] = 'Press ~INPUT_CONTEXT~ to open the Pet-Shop'
    }
}