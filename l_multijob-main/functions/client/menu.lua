Menu = {}

Menu.Open = function(data)
    if not data or next(data) == nil then
        Framework.Client.ShowNotification("Keine Jobs gefunden..")
        return
    end

    local menuOptions = {}
    for jobName, jobData in pairs(data) do
        table.insert(menuOptions, {
            label = string.format('%s - %s (%s)', jobData.label, jobData.gradeLabel or "NICHT GEFUNDEN", jobData.grade),
            args = { job = jobName, grade = jobData.grade }
        })
    end

    table.insert(menuOptions, {
        label = 'Offduty schalten',
        args = { action = 'offduty' }
    })

    lib.registerMenu({
        id = 'job_menu',
        title = 'Jobauswahl',
        position = 'top-right',
        options = menuOptions
    }, function(_, _, args)
        if args.action == 'offduty' then
            TriggerServerEvent('changePlayerJob', "unemployed", 0)
        end
        if args.job then
            lib.registerMenu({
                id = 'job_action_menu',
                title = 'Jobaktionen',
                position = 'top-right',
                options = {
                    { label = 'Job auswählen', args = { action = 'pick', job = args.job, grade = args.grade } },
                    { label = 'Job löschen', args = { action = 'delete', job = args.job } },
                    { label = 'Zurück', args = { action = 'back' } }
                }
            }, function(_, _, actionArgs)
                if actionArgs.action == 'pick' and actionArgs.job and actionArgs.grade then
                    TriggerServerEvent('changePlayerJob', actionArgs.job, actionArgs.grade)
                elseif actionArgs.action == 'delete' and actionArgs.job then
                    TriggerServerEvent('deleteMultijob', actionArgs.job)
                elseif actionArgs.action == 'back' then
                    lib.showMenu('job_menu')
                end
            end)

            lib.showMenu('job_action_menu')
        end
    end)

    lib.showMenu('job_menu')
end

return Menu