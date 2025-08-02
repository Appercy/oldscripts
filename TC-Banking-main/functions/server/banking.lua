---@class IBAN
local IBAN = {}
local Transfer = {}
local Data = {}
local existingIbans = {}  
local Card = {}
lib.locale()

Framework = require("functions.server.framework")

--------------------------------------------------------------------------------
-- Role & Group Management Functions (using TC_BANKING_IBAN_ACCESS)
--------------------------------------------------------------------------------

local function doesIdentifierExist(identifier)
    return MySQL.scalar.await(
        'SELECT COUNT(*) FROM users WHERE identifier = ?',
        { identifier }
    ) > 0
end

function IBAN.HasAccess(source, iban)
    local identifier = Framework.Player.getIdentifier(source)
    local role = IBAN.getRole(identifier, iban)
    if role == "owner" or role == "co-owner" or role == "user" then
        return true
    else
        return false
    end
end

function IBAN.IsAdministrator(source)
    local identifier = Framework.Player.getIdentifier(source)
    local iban = IBAN.getPrimaryAccount(identifier)
    local role = IBAN.getRole(identifier, iban)
    if role == "owner" or role == "co-owner" then
        return true
    else
        return false
    end
end

function IBAN.IsOwner(source, iban)
    local identifier = Framework.Player.getIdentifier(source)
    local owner = IBAN.GetOwner(iban)
    if owner == identifier then
        return true
    else
        return false
    end
end
--- Retrieves the role for a given identifier and IBAN.
--- @param identifier string The user's identifier.
--- @param iban string The IBAN to check.
--- @return string|nil The role ("owner", "co-owner", "user") if found, otherwise nil.
function IBAN.getRole(identifier, iban)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    local role = MySQL.scalar.await(
        'SELECT ROLE FROM TC_BANKING_IBAN_ACCESS WHERE IDENTIFIER = ? AND IBAN = ?',
        { identifier, iban }
    )
    return role
end

-- Set the role for a given identifier and IBAN.
--- @param identifier string The user's identifier.
--- @param iban string The IBAN to set.
--- @param role string The role to set ("owner", "co-owner", "user").
function IBAN.setRole(identifier, iban, role)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    MySQL.update.await(
        'UPDATE TC_BANKING_IBAN_ACCESS SET ROLE = ? WHERE IDENTIFIER = ? AND IBAN = ?',
        { role, identifier, iban }
    )
end

-- Add a user to an IBAN with a given role.
--- @param identifier string The user's identifier.
--- @param iban string The IBAN to add.
--- @param role string The role to set ("owner", "co-owner", "user").
function IBAN.AddUser(identifier, iban, role)

    if role ~= "user" and role ~= "co-owner" and role ~= "owner" then
        lib.print.debug("Invalid role: " .. tostring(role))
        return false
    end
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if identifier == nil then lib.print.debug("Identifier doesnt exist")return nil end
    if IBAN.Exists(iban) then
        local exists = MySQL.scalar.await(
            'SELECT COUNT(*) FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND IDENTIFIER = ?',
            { iban, identifier }
        ) > 0

        if not exists then
            MySQL.insert.await(
                'INSERT INTO TC_BANKING_IBAN_ACCESS (IBAN, IDENTIFIER, ROLE) VALUES (?, ?, ?)',
                { iban, identifier, role }
            )
            name = Framework.Player.getName(nil, identifier)
            lib.print.debug("Added " .. tostring(name) .. " to IBAN: " .. tostring(iban) .. " with role: " .. tostring(role))
            return true, name
        else
            lib.print.debug("Entry already exists for IBAN: " .. tostring(iban) .. " and identifier: " .. tostring(identifier))
        end
    else
        lib.print.debug("IBAN does not exist: " .. tostring(iban))
    end
    return false
end

function IBAN.DeleteAccess(iban, identifier)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if identifier == nil then lib.print.debug("Identifier doesnt exist")return nil end




    if IBAN.Exists(iban) then
        local exists = MySQL.scalar.await(
            'SELECT COUNT(*) FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND IDENTIFIER = ?',
            { iban, identifier }
        ) > 0

        if exists then
            MySQL.update.await(
                'DELETE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND IDENTIFIER = ?',
                { iban, identifier }
            )
            return true
        else
            lib.print.debug("Entry does not exist for IBAN: " .. tostring(iban) .. " and identifier: " .. tostring(identifier))
        end
    else
        lib.print.debug("IBAN does not exist: " .. tostring(iban))
    end
    return false
end

-- Remove a user from an IBAN.
--- @param identifier string The user's identifier.
--- @param iban string The IBAN to remove.
--- @return boolean success True if removed successfully.
function IBAN.RemoveUser(identifier, iban)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    MySQL.update.await(
        'DELETE FROM TC_BANKING_IBAN_ACCESS WHERE IDENTIFIER = ? AND IBAN = ?',
        { identifier, iban }
    )
end

-- alias
IBAN.DeleteUser = IBAN.RemoveUser

--- Retrieves all group members for a given IBAN or the role for a specific identifier and IBAN.
--- @param iban string The IBAN to check.
--- @param identifier string|nil The user's identifier (optional).
--- @return table|string A list of entries with fields IDENTIFIER and ROLE, or the role if both identifier and IBAN are valid.
function IBAN.getGroup(iban, identifier)
    if identifier then
        local role = MySQL.scalar.await(
            'SELECT ROLE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND IDENTIFIER = ?',
            { iban, identifier }
        )
        if role then
            return role
        end
    end

    local group = MySQL.query.await(
        'SELECT IDENTIFIER, ROLE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ?',
        { iban }
    )
    return group or {}
end

--- Retrieves all IBANs (with full data) that the identifier is associated with.
--- @param identifier string The user's identifier.
--- @return table A list of IBAN records joined with access data.
function IBAN.getAllAssociated(identifier)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    local accounts = MySQL.query.await([[
        SELECT B.*, A.ROLE
        FROM TC_BANKING_IBAN AS B
        INNER JOIN TC_BANKING_IBAN_ACCESS AS A ON B.IBAN = A.IBAN
        WHERE A.IDENTIFIER = ?
    ]], { identifier })
    return accounts or {}
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

--- Generates a unique IBAN.
--- @return string iban The generated IBAN.
local function generateIBAN()
    local countryCode = Config.LocalCode or "US"
    local lastCode = MySQL.scalar.await(
        'SELECT MAX(CAST(SUBSTRING(IBAN, -10) AS UNSIGNED)) FROM TC_BANKING_IBAN'
    ) or 999999999
    local newCode = lastCode + 1

    -- Generate a random 5-6 digit number for the unique part.
    local uniquePart = math.random(100000, 999999)
    while MySQL.scalar.await(
        'SELECT COUNT(*) FROM TC_BANKING_IBAN WHERE SUBSTRING(IBAN, -6) = ?',
        { tostring(uniquePart) }
    ) > 0 do
        uniquePart = math.random(100000, 999999)  -- Retry if already exists.
    end

    return string.format("%s%02d%08d%06d",
        countryCode,
        math.random(10, 99),
        math.random(10000000, 99999999),
        uniquePart
    )
end

--- Fetches the full IBAN from a partial IBAN.
--- @param iban string The IBAN (or partial IBAN) to fetch.
--- @return string fulliban The full IBAN.
local function fetchFullIBAN(iban)
    lib.print.debug("Fetching full IBAN for: " .. tostring(iban))
    iban = tostring(iban)
    if #iban < 9 then
        local fulliban = MySQL.scalar.await(
            'SELECT IBAN FROM TC_BANKING_IBAN WHERE RIGHT(IBAN, ?) = ? LIMIT 1',
            { #iban, iban }
        )
        lib.print.debug("Full IBAN: " .. tostring(fulliban))
        return fulliban
    else
        lib.print.debug("IBAN is assumed complete: " .. tostring(iban))
        return iban
    end
end

--------------------------------------------------------------------------------
-- IBAN Functions
--------------------------------------------------------------------------------

function IBAN.GetAccountSociety(society)
    local iban = MySQL.scalar.await('SELECT IBAN FROM TC_BANKING_IBAN WHERE SOCIETY = ? OR SOCIETY = ?', { society, "society_" .. society })
    return iban
end
function IBAN.GetSocietyAccount(iban)
    iban = fetchFullIBAN(iban)
    local society = MySQL.scalar.await('SELECT SOCIETY FROM TC_BANKING_IBAN WHERE SOCIETY = ?', { iban })
    return society
end

function IBAN.CreateSocietyAccount(society, owner)
    local iban = generateIBAN()
    existingIbans[iban] = true
    MySQL.insert.await(
        'INSERT INTO TC_BANKING_IBAN (IBAN, BALANCE, `PRIMARY`, SOCIETY) VALUES (?, ?, ?, ?)',
        { iban, 0, 1, society }
    )
    if owner then
        IBAN.AddUser(owner, iban, "owner")
    end
    return iban
end

--- Creates a new IBAN and assigns access for the given identifier.
--- The "primary" flag is set to 1 if the identifier has no primary account yet (ESX standard),
--- otherwise 0. The creator always gets an "owner" role.
--- @param identifier string The user's identifier.
--- @return string|false iban The created IBAN or false on failure.
function IBAN.Create(identifier)
     identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    lib.print.debug("Creating IBAN for: " .. tostring(identifier))
    if not identifier then
        if Config.Debug then
            lib.print.debug("No identifier provided; generating one.")
            identifier = ESX.GetRandomString(20)
            lib.print.debug("Generated identifier: " .. tostring(identifier))
        else
            lib.print.debug("No identifier provided")
            return false
        end
    end

    -- Check if the user already has a primary IBAN.
    local hasPrimary = MySQL.scalar.await([[
        SELECT COUNT(*) FROM TC_BANKING_IBAN AS B
        INNER JOIN TC_BANKING_IBAN_ACCESS AS A ON B.IBAN = A.IBAN
        WHERE A.IDENTIFIER = ? AND B.PRIMARY = 1
    ]], { identifier }) > 0
    local isPrimary = hasPrimary and 0 or 1

    local iban = generateIBAN()
    lib.print.debug("Generated IBAN: " .. tostring(iban))
    existingIbans[iban] = true

    -- For ESX, the bank account is based on the primary IBAN.

    local balance = (isPrimary == 1) and (Framework.Player.getBank(nil, identifier) or 0) or 0

    -- Insert into the main IBAN table.
    MySQL.insert.await(
        'INSERT INTO TC_BANKING_IBAN (IBAN, BALANCE, `PRIMARY`) VALUES (?, ?, ?)',
        { iban, balance, isPrimary }
    )
    -- Insert into the access table with role "owner".
    MySQL.insert.await(
        'INSERT INTO TC_BANKING_IBAN_ACCESS (IBAN, IDENTIFIER, ROLE) VALUES (?, ?, ?)',
        { iban, identifier, "owner" }
    )

    lib.print.debug("IBAN created with `PRIMARY´ = " .. tostring(isPrimary) .. " and role 'owner'")
    return iban
end

--- Retrieves the primary IBAN for an identifier.
--- @param identifier string The user's identifier.
--- @return string The IBAN marked as primary for this identifier.
function IBAN.getPrimaryAccount(identifier)
lib.print.debug("Getting primary IBAN for identifier: " .. tostring(identifier))

if not doesIdentifierExist(identifier) then
    lib.print.debug("Identifier doesn't exist")
    return nil
end

local primaryIban = MySQL.scalar.await([[
    SELECT B.IBAN FROM TC_BANKING_IBAN AS B
    INNER JOIN TC_BANKING_IBAN_ACCESS AS A ON B.IBAN = A.IBAN
    WHERE B.PRIMARY = 1 AND A.IDENTIFIER = ?
]], { identifier })

lib.print.debug("Primary IBAN: " .. tostring(primaryIban))

return primaryIban

end

--- Checks if an IBAN exists in the IBAN table.
--- @param iban string The IBAN to check.
--- @return boolean exists True if exists, false otherwise.
function IBAN.Exists(iban)
    iban = fetchFullIBAN(iban)
    if existingIbans[iban] then
        return true
    end
    local fulliban = MySQL.scalar.await(
        'SELECT IBAN FROM TC_BANKING_IBAN WHERE IBAN = ? LIMIT 1',
        { iban }
    )
    if fulliban then
        existingIbans[fulliban] = true
        return true
    end
    return false
end

--- Removes an IBAN FROM the system 
--- @param iban string The IBAN to remove.
--- @return boolean success True if removed successfully.
function IBAN.Delete(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Deleting IBAN: " .. tostring(iban))
    local success = pcall(function()
        MySQL.transaction.await({
            {'DELETE FROM TC_BANKING_IBAN WHERE IBAN = ?', { iban }},
        })
    end)
    if success then
        lib.print.debug("IBAN deleted")
    else
        lib.print.error("Failed to delete IBAN: " .. tostring(iban))
    end
    return success
end


function IBAN.Leave(iban, identifier)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Leaving IBAN: " .. tostring(iban))
    local success = pcall(function()
        MySQL.transaction.await({
            {'DELETE FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND IDENTIFIER = ?', { iban, identifier }},
        })
    end)
    if success then
        lib.print.debug("IBAN left")
    else
        lib.print.error("Failed to leave IBAN: " .. tostring(iban))
    end
    return success
end


--- Gets the balance for an IBAN.
--- @param iban string The IBAN to query.
--- @return number balance The account balance.
function IBAN.GetBalance(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Getting balance for IBAN: " .. tostring(iban))
    local balance = MySQL.scalar.await('SELECT BALANCE FROM TC_BANKING_IBAN WHERE IBAN = ?', { iban })
    if balance == nil then balance = 0 end
    lib.print.debug("Balance: " .. tostring(balance))
    return balance or 0
end



--- Sets the interest rate for an IBAN.
--- @param iban string The IBAN to update.
--- @param rate number The new interest rate.
--- @return boolean success True if updated successfully.
function IBAN.SetInterestRate(iban, rate)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Setting interest rate for IBAN: " .. tostring(iban))
    local success = pcall(function()
        MySQL.update.await('UPDATE TC_BANKING_IBAN SET INTRATE = ? WHERE IBAN = ?', { rate, iban })
    end)
    if success then
        lib.print.debug("Interest rate set to " .. tostring(rate))
    else
        lib.print.debug("Failed to set interest rate for IBAN: " .. tostring(iban))
    end
    return success
end

--- Gets the interest rate for an IBAN.
--- @param iban string The IBAN to query.
--- @return number rate The interest rate.
function IBAN.GetInterestRate(iban)
    iban = fetchFullIBAN(iban)
    local success, rate = pcall(function()
        return MySQL.scalar.await('SELECT INTRATE FROM TC_BANKING_IBAN WHERE IBAN = ?', { iban })
    end)
    if not success then
        lib.print.debug("Failed to get interest rate for IBAN: " .. tostring(iban))
        return false
    end
    return rate
end

--- Sets the primary IBAN for an identifier.
--- This function resets all IBANs associated with the identifier to non-primary
--- and then sets the provided IBAN as primary (ESX standard).
--- @param identifier string The user's identifier.
--- @param iban string The IBAN to mark as primary.
--- @return boolean success True if updated successfully.
function IBAN.SetIBANPrimary(identifier, iban)
    identifier = doesIdentifierExist(identifier) and identifier or nil
    if not identifier then lib.print.debug("Identifier doesnt exist")return nil end
    iban = fetchFullIBAN(iban)
    -- Reset all IBANs associated with this identifier to PRIMARY = 0.
    MySQL.update.await([[
        UPDATE TC_BANKING_IBAN AS B
        INNER JOIN TC_BANKING_IBAN_ACCESS AS A ON B.IBAN = A.IBAN
        SET B.PRIMARY = 0
        WHERE A.IDENTIFIER = ?
    ]], { identifier })
    -- Set the specified IBAN as PRIMARY.
    MySQL.update.await('UPDATE TC_BANKING_IBAN SET PRIMARY = 1 WHERE IBAN = ?', { iban })
    lib.print.debug("Set IBAN " .. tostring(iban) .. " as PRIMARY for identifier: " .. tostring(identifier))
    return true
end

--- Sets the society for an IBAN.
--- @param iban string The IBAN to update.
--- @param society string The society value.
function IBAN.SetSociety(iban, society)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Setting society for IBAN: " .. tostring(iban))
    MySQL.update.await('UPDATE TC_BANKING_IBAN SET SOCIETY = ? WHERE IBAN = ?', { society, iban })
    lib.print.debug("Society set")
end

--- Gets the society for an IBAN.
--- @param iban string The IBAN to query.
--- @return string society The society value.
function IBAN.GetSociety(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Getting society for IBAN: " .. tostring(iban))
    local society = MySQL.scalar.await('SELECT SOCIETY FROM TC_BANKING_IBAN WHERE IBAN = ?', { iban })
    lib.print.debug("Society: " .. tostring(society))
    return society
end

--- Gets the total currency in the bank (sum of all IBAN balances).
--- @return number total The total balance.
function IBAN.GetTotalCurrency()
    return MySQL.scalar.await('SELECT SUM(BALANCE) FROM TC_BANKING_IBAN')
end

--------------------------------------------------------------------------------
-- Transfer Functions
--------------------------------------------------------------------------------

--- Transfers money between two IBANs.
--- @param from string Sender IBAN.
--- @param to string Receiver IBAN.
--- @param amount number The amount to transfer.
--- @param reason string The transfer reason.
--- @return boolean success True if successful, false otherwise.
function Transfer.TransferMoney(from, to, amount, reason)
    lib.print.debug("Transferring " .. tostring(amount) .. " from " .. tostring(from) .. " to " .. tostring(to))
    from = fetchFullIBAN(from)
    to = fetchFullIBAN(to)
    if not IBAN.Exists(from) or not IBAN.Exists(to) then
        lib.print.debug("One of the IBANs does not exist")
        return false
    end
    local fromBalance = IBAN.GetBalance(from)
    if amount <= 0 then
        lib.print.debug("Amount must be greater than 0")
        return false
    end
    if fromBalance < amount then
        lib.print.debug("Not enough funds in sender's account")
        return false
    end

    MySQL.transaction.await({
        {'UPDATE TC_BANKING_IBAN SET BALANCE = BALANCE - ? WHERE IBAN = ?', { amount, from }},
        {'UPDATE TC_BANKING_IBAN SET BALANCE = BALANCE + ? WHERE IBAN = ?', { amount, to }},
        {'INSERT INTO TC_BANKING_TRANSFER_HISTORY (IBAN_FROM, IBAN_TO, AMOUNT, DESCRIPTION) VALUES (?, ?, ?, ?)', { from, to, amount, reason }}
    })
    lib.print.debug("Transfer complete")
    return true
end

--- Retrieves the transfer history for an IBAN.
--- @param iban string The IBAN to query.
--- @return table history A list of transfer records.
function Transfer.GetHistory(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Getting transfer history for IBAN: " .. tostring(iban))
    local query1 = MySQL.query.await(
        'SELECT * FROM TC_BANKING_TRANSFER_HISTORY WHERE (IBAN_FROM = ? OR IBAN_TO = ?) ORDER BY DATE DESC',
        { iban, iban }
    )

    local query2 = MySQL.query.await(
        'SELECT * FROM TC_BANKING_TRANSACTION_HISTORY WHERE IBAN = ? ORDER BY DATE DESC',
        { iban }
    )

    query = lib.table.merge(query1, query2)
    lib.print.debug("Transfer history: " .. ESX.DumpTable(query))
    return query
end

--- Retrieves the last transfer involving an IBAN.
--- @param iban string The IBAN to query.
--- @return table lastTransfer Details of the last transfer.
function Transfer.GetLast(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Getting last transfer for IBAN: " .. tostring(iban))
    return MySQL.query.await(
        'SELECT * FROM TC_BANKING_TRANSFER_HISTORY WHERE IBAN_FROM = ? OR IBAN_TO = ? ORDER BY DATE DESC LIMIT 1',
        { iban, iban }
    )
end

function IBAN.GetOwner(iban)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Getting owner for IBAN: " .. tostring(iban))
    local owner = MySQL.scalar.await('SELECT IDENTIFIER FROM TC_BANKING_IBAN_ACCESS WHERE IBAN = ? AND ROLE = "owner"', { iban })
    lib.print.debug("Owner: " .. tostring(owner))
    return owner
end
-- only used for billing
function IBAN.RemoveMoney(iban, amount)
    lib.print.debug("Removing " .. tostring(amount) .. " from " .. tostring(iban))
    iban = fetchFullIBAN(iban)
    local currentmoney = IBAN.GetBalance(iban)
    if currentmoney < amount then
        lib.print.debug("Not enough funds in account")
        return false
    end
    MySQL.update.await('UPDATE TC_BANKING_IBAN SET BALANCE = BALANCE - ? WHERE IBAN = ?', { amount, iban })
    lib.print.debug("Money removed")
    return true
end

function IBAN.Deposit(iban, amount, source, reason)
    lib.print.debug("IBAN.Deposit Depositing" .. tostring(amount) .. " to " .. tostring(iban))
    hasenough = Framework.Player.getMoney(source) >= amount
    lib.print.debug("Money in hand: " .. tostring(Framework.Player.getMoney(source)))
    lib.print.debug("Has enough money: " .. tostring(hasenough))
    if hasenough then
        currentmoney = IBAN.GetBalance(iban)
        currentDate = os.date('%Y-%m-%d %H:%M:%S')
        Framework.Player.removeMoney(source, nil, amount)
        lib.print.debug("Money in hand after deposit: " .. tostring(Framework.Player.getMoney(source)))
        iban = fetchFullIBAN(iban)
        local success = pcall(function()
            MySQL.update.await('UPDATE TC_BANKING_IBAN SET BALANCE = BALANCE + ? WHERE IBAN = ?', { amount, iban })
        end)
        if not success then
            lib.print.debug("Failed to set balance for IBAN: " .. tostring(iban))
            return false
        end
        if IBAN.IsAccountPrimary(iban) == 1 then
            Framework.Player.addBank(source, nil, amount)
        end

        IBAN.LogTransaction(iban, amount, reason, nil, source, 1)
        return true
    else
        return false
    end
end

function IBAN.Withdraw(iban, amount, source, reason)
    lib.print.debug("IBAN.Withdraw Withdrawing" .. tostring(amount) .. " from " .. tostring(iban))
    local currentmoney = IBAN.GetBalance(iban)
    local hasenough = currentmoney >= amount
    lib.print.debug("Money in account: " .. tostring(currentmoney))
    lib.print.debug("Has enough money: " .. tostring(hasenough))
    if hasenough then
        iban = fetchFullIBAN(iban)
        local success = pcall(function()
            MySQL.update.await('UPDATE TC_BANKING_IBAN SET BALANCE = BALANCE - ? WHERE IBAN = ?', { amount, iban })
        end)
        if not success then
            lib.print.debug("Failed to set balance for IBAN: " .. tostring(iban))
            return false
        end
        if IBAN.IsAccountPrimary(iban) == 1 then
            Framework.Player.addBank(source, nil, amount)
        end
        Framework.Player.addMoney(source, nil, amount)
        IBAN.LogTransaction(iban, amount, reason, nil, source, 0)
        return true
    else
        return false
    end
end

function IBAN.CheckPrimary(source)
    if not source or type(source) ~= "number" then
        print("Invalid source parameter")
        return
    end

    local identifier = Framework.Player.getIdentifier(source)
    local primary = IBAN.getPrimaryAccount(identifier)
    local primarymoney = IBAN.GetBalance(primary)

    if primarymoney == Framework.Player.getBank(source) then
        -- nothing
    else
        Framework.Player.setBank(source, "bank", primarymoney)
    end
end


--- Sets the balance for an IBAN.
--- @param iban string The IBAN to update.
--- @param amount number The new balance.
--- @param reason string The reason for the balance change.
--- @return boolean success True if updated successfully, false otherwise.
function IBAN.SetMoney(iban, amount, reason)
local currentmoney = IBAN.GetBalance(iban)
local additive = amount - currentmoney
local isDeposit = additive >= 0 and 1 or 0
lib.print.debug("Setting balance for IBAN: " .. tostring(iban) .. "to " .. tostring(amount))
lib.print.debug("Additive: " .. tostring(additive))
lib.print.debug("Is deposit: " .. tostring(isDeposit))

    iban = fetchFullIBAN(iban)
    lib.print.debug("Setting balance for IBAN: " .. tostring(iban) .. "to " .. tostring(amount))
    local success = pcall(function()
        MySQL.update.await('UPDATE TC_BANKING_IBAN SET BALANCE = ? WHERE IBAN = ?', { amount, iban })
    end)
    if not success then
        lib.print.debug("Failed to set balance for IBAN: " .. tostring(iban))
        return false
    end

    identifier = IBAN.GetOwner(iban)
    primary = IBAN.getPrimaryAccount(identifier)
    
    if identifier and primary then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
   
        if xPlayer then
            Wait(1000)
            if xPlayer.getAccount("bank").money == amount then
                -- nothing
            else
            xPlayer.setAccountMoney("bank", amount)

            end
        end
    end
    if  amount ~= currentmoney then
        if amount == 0 then
            isDeposit = 0
            amount = currentmoney
        end
        IBAN.LogTransaction(iban, amount, reason, nil, "System", isDeposit)
    end
    return true
end

function IBAN.LogTransaction(iban, amount, description, status, issuer, Additive)
    lib.print.debug("Logging transaction for IBAN: " .. tostring(iban) .. " amount: " .. tostring(amount) .. " description: " .. tostring(description).. " status: " .. tostring(status).. " issuer: " .. tostring(issuer) .. " Additive: " .. tostring(Additive))
    local fullIban = fetchFullIBAN(iban)
    status = status or "completed"
    issuer = issuer or "system"
    MySQL.insert.await('INSERT INTO TC_BANKING_TRANSACTION_HISTORY (IBAN, AMOUNT, DESCRIPTION, STATUS, ISSUER, ADDITIVE) VALUES (?, ?, ?, ?, ?, ?)', { fullIban, amount, description, status, issuer, Additive})
end

function IBAN.UpdateAccessRole(iban, role, identifier)
    iban = fetchFullIBAN(iban)
    lib.print.debug("Updating access role for IBAN: " .. tostring(iban) .. " to " .. tostring(role) .. " for identifier: " .. tostring(identifier))
    
    if role ~= "co-owner" and role ~= "user" then
        lib.print.debug("Invalid role: " .. tostring(role))
        return false
    end

    local success = pcall(function()
        MySQL.update.await('UPDATE TC_BANKING_IBAN_ACCESS SET ROLE = ? WHERE IBAN = ? AND IDENTIFIER = ?', { role, iban, identifier })
    end)
    if not success then
        lib.print.debug("Failed to update access role for IBAN: " .. tostring(iban))
        return false
    end
    return true
end

function IBAN.IsAccountPrimary(iban)
    iban = fetchFullIBAN(iban)
    local primary = MySQL.scalar.await('SELECT `PRIMARY` FROM TC_BANKING_IBAN WHERE IBAN = ?', { iban })
    return primary or 0
end

function Data.GetBankingData(source)
    IBAN.CheckPrimary(source)
    lib.print.debug("Getting banking data for source: " .. tostring(source))
    returndata = {}
    local identifier = Framework.Player.getIdentifier(source)
    local ibans = IBAN.getAllAssociated(identifier)
    lib.print.debug("Found " .. tostring(#ibans) .. " associated IBANs")
    for _, iban in ipairs(ibans) do
        transactions = Transfer.GetHistory(iban.IBAN)
        local balance = IBAN.GetBalance(iban.IBAN)
        local society = IBAN.GetSociety(iban.IBAN)
        local owngroup = IBAN.getGroup(iban.IBAN, identifier)
        local interest = IBAN.GetInterestRate(iban.IBAN)
        local groups = IBAN.getGroup(iban.IBAN)
        for k,v in pairs(groups) do 
            v.name = Framework.Player.getName(nil, v.IDENTIFIER)
        end
        local transfers = Transfer.GetHistory(iban.IBAN)
        local Cards = { Card.GetCards(iban.IBAN) }
        local primary = IBAN.IsAccountPrimary(iban.IBAN)
        table.insert(returndata, {
            owngroup = owngroup,
            cards = Cards,
            IBAN = iban.IBAN,
            Balance = balance,
            Society = society,
            Primary = primary,
            Interest = interest,
            Group = groups,
            Transfers = transfers,
            Transactions = transactions
        })
    end

    -- add billing data later here.. (or make it extra?)
    return returndata
end

function Data.GetBankingDataForSingleAccount(iban, identifier)
    returndata = {}
    transactions = Transfer.GetHistory(iban)
    local balance = IBAN.GetBalance(iban)
    local society = IBAN.GetSociety(iban)
    local owngroup = IBAN.getGroup(iban, identifier)
    local interest = IBAN.GetInterestRate(iban)
    local groups = IBAN.getGroup(iban)
    local transfers = Transfer.GetHistory(iban)
    local Cards = { Card.GetCards(iban) }
    local primary = IBAN.IsAccountPrimary(iban)
    table.insert(returndata, {
        owngroup = owngroup,
        cards = Cards,
        IBAN = iban.IBAN,
        Balance = balance,
        Society = society,
        Primary = primary,
        Interest = interest,
        Group = groups,
        Transfers = transfers,
        Transactions = transactions
    })
    return returndata
end

Card.CreateCardNumber = function()
    local cardnumber = math.random(1000000000000000, 9999999999999999)
    return cardnumber
end

Card.CreateCard = function(iban, pin, cardnumber, source)
    Framework.Player.AddItem(source, Config.CardItem, {["metadata"] = {["cardnumber"] = cardnumber}})
    lib.print.debug("Creating card for IBAN: " .. tostring(iban) .. " with cardnumber: " .. tostring(cardnumber))
    if IBAN.Exists(iban) then
    local expiration = os.date('%Y-%m-%d', os.time() + 31536000)
    local mwph = 1000
    MySQL.insert.await('INSERT INTO TC_BANKING_CARDS (IBAN, CARD_NUMBER, EXPIRATION_DATE, MWPH, PIN) VALUES (?, ?, ?, ?, ?)', { iban, cardnumber, expiration, mwph, pin })
    return cardnumber
    else
        lib.print.debug("IBAN does not exist")
        return false
    end
    -- add ox item here later with metadata
end

Card.RecreateCard = function(source, cardnumber)
    Framework.Player.AddItem(source, Config.CardItem, {["metadata"] = {["cardnumber"] = cardnumber}})
end

Card.GetCard = function(cardnumber)
    return MySQL.query.await('SELECT * FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.DeleteCard = function(iban, cardnumber)
    lib.print.debug("Deleting card for IBAN: " .. tostring(iban) .. " with cardnumber: " .. tostring(cardnumber))
    if not Card.GetCard(cardnumber) then
        lib.print.debug("Card does not exist")
        return false
    end
    if IBAN.Exists(iban) then
        MySQL.update.await('DELETE FROM TC_BANKING_CARDS WHERE IBAN = ? AND CARD_NUMBER = ?', { iban, cardnumber })
        return true
    else
        lib.print.debug("IBAN does not exist")
        return false
    end
end

Card.GetCards = function(IBAN)
    return MySQL.query.await('SELECT * FROM TC_BANKING_CARDS WHERE IBAN = ?', { IBAN })
end

Card.SetExpirationDate = function(cardnumber, expiration)
    MySQL.update.await('UPDATE TC_BANKING_CARDS SET EXPIRATION_DATE = ? WHERE CARD_NUMBER = ?', { expiration, cardnumber })
end

Card.GetExpirationDate = function(cardnumber)
    return MySQL.scalar.await('SELECT EXPIRATION_DATE FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.SetMWPH = function(cardnumber, mwph)
    MySQL.update.await('UPDATE TC_BANKING_CARDS SET MWPH = ? WHERE CARD_NUMBER = ?', { mwph, cardnumber })
end

Card.GetMWPH = function(cardnumber)
    return MySQL.scalar.await('SELECT MWPH FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.LockCard = function(cardnumber)
    MySQL.update.await('UPDATE TC_BANKING_CARDS SET LOCKED = 1 WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.UnlockCard = function(cardnumber)
    MySQL.update.await('UPDATE TC_BANKING_CARDS SET LOCKED = 0 WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.IsLocked = function(cardnumber)
    return MySQL.scalar.await('SELECT LOCKED FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber }) == 1
end

Card.GetIBAN = function(cardnumber)
    return MySQL.scalar.await('SELECT IBAN FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.GetCards = function(IBAN)
    return MySQL.query.await('SELECT * FROM TC_BANKING_CARDS WHERE IBAN = ?', { IBAN })
end

Card.GetCard = function(cardnumber)
    return MySQL.query.await('SELECT * FROM TC_BANKING_CARDS WHERE CARD_NUMBER = ?', { cardnumber })
end

Card.GetCardOwner = function(cardnumber)
    local iban = Card.GetIBAN(cardnumber)
    return IBAN.GetOwner(iban)
end

Card.GetCardBalance = function(cardnumber)
    local iban = Card.GetIBAN(cardnumber)
    return IBAN.GetBalance(iban)
end
--------------------------------------------------------------------------------
-- Return Module
--------------------------------------------------------------------------------

return { Data = Data, IBAN = IBAN, Transfer = Transfer, Card = Card }
