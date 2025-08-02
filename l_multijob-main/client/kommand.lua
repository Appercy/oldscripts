local Menu = require("functions.client.menu")
local Callback = require("functions.client.callbacks")
Framework.Init()

RegisterCommand(Config.CommandName, function()
    data = Callback.GetJobs()
   Menu.Open(data)
end, false)
-- kommadn bc if its c its above init :(