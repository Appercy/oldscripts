Callback = {}

Callback.GetJobs = function()
    return lib.callback.await('l_multijob:getJobs', false)
end

Callback.GetJob = function()
    return lib.callback.await('l_multijob:getJob', false)
end

return Callback