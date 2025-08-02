SQL = require("functions.server.sql")
Framework = require("functions.shared.framework")

lib.callback.register('l_multijob:getJobs', function(source)
return SQL.GetJobs(source)
end)

lib.callback.register('l_multijob:getJob', function(source)
    local player = Framework.Server.GetPlayer(source)
    if player then
        local job = player.getJob()
        return job
    end
    return nil
end)