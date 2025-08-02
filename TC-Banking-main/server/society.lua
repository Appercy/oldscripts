Banking = require("functions.server.banking")


function getHighestJobGrades(job, limit)
    local highestJobGrades = MySQL.Async.fetchAll(
        'SELECT grade from job_grades WHERE job = @job ORDER BY grade DESC LIMIT @limit',
        { ["@job"] = job.name, ["@limit"] = limit })
    return highestJobGrades
end

function getHighestJobGradesWithOffset(job, limit, offset)
    local highestJobGrades = getHighestJobGrades(job, limit)
    for i, grade in ipairs(highestJobGrades) do
        highestJobGrades[i].grade = grade.grade + offset
    end
    return highestJobGrades
end

function LeaveSocietyAccount(job, identifier)
    local iban = Banking.IBAN.GetAccountSociety(job)
    if iban[1] then
        MySQL.Async.execute('DELETE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = @iban AND IDENTIFIER = @identifier',
            { ["@iban"] = iban[1].iban, ["@identifier"] = identifier })
    end
end

function JoinSocietyAccount(job, identifier)
    local iban = Banking.IBAN.GetAccountSociety(job)
    if iban then
        MySQL.Async.execute('INSERT INTO TC_BANKING_IBAN_ACCESS (IBAN, IDENTIFIER) VALUES (@iban, @identifier)',
            { ["@iban"] = iban[1].iban, ["@identifier"] = identifier })
    end
end

RegisterNetEvent('esx:setJob', function(player, job, lastJob)
    jobname = job.name
    lastjobname = lastJob.name
    for k, v in pairs(Config.Societies) do
        if jobname == k then
            JoinSocietyAccount(jobname, Framework.Player.getIdentifier(player))
        elseif lastjobname == k then
            LeaveSocietyAccount(jobname, Framework.Player.getIdentifier(player))
        end
    end
    local maxGrade
    if Config.Societies[jobname] and Config.Societies[jobname].offset then
        local highestJobGradesWithOffset = getHighestJobGradesWithOffset(job, 1, Config.Societies[jobname].offset)
        if highestJobGradesWithOffset[1] then
            maxGrade = highestJobGradesWithOffset[1].grade
        end
    else
        local highestJobGrades = getHighestJobGrades(job, 1)
        if highestJobGrades[1] then
            maxGrade = highestJobGrades[1].grade
        end
    end

    if job.grade < maxGrade then
        LeaveSocietyAccount(jobname, Framework.Player.getIdentifier(player))
    end
    if job.grade == maxGrade then
        JoinSocietyAccount(jobname, Framework.Player.getIdentifier(player))
    end
end)

societies = MySQL.Sync.fetchAll('SELECT * FROM TC_BANKING_SOCIETIES')
for k,v in pairs(societies) do 
    print(v.SOCIETY)
    iban = Banking.IBAN.GetAccountSociety(v.SOCIETY)
    if not iban then
        iban = Banking.IBAN.CreateSocietyAccount(v.SOCIETY, v.OWNER)
    end
end