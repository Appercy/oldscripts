if Config.Debug then
    inskinmenu = false
    RegisterCommand('testskin', function(source, args, rawCommand)
        if not inskinmenu then
            inskinmenu = true
            openskinmenu()
        end
    end)
end
