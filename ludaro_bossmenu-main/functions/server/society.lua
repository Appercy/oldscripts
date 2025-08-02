--[[ 
    Society Module
    This module provides functions to interact with society accounts in the database.
    It includes methods to retrieve the money of a specific society.

    @module Society
]]

-- Define the Society table
Society = {}

--[[ 
    GetMoney
    Retrieves the current amount of money for a specified society from the database.

    @param society (string) - The name of the society (without the "society_" prefix).
    @return (number) - The amount of money in the society's account. Returns 0 if the society does not exist.
]]
Society.GetMoney = function(society)
    -- Prefix the society name with "society_"
    society = "society_" .. society

    -- Query the database for the society's account data
    local result = MySQL.Sync.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @society', {
        ['@society'] = society,
    })

    -- Debugging: Print the result table to the console
   
    -- Check if the result contains data and return the money amount, or 0 if not found
    if result[1] then
        return result[1].money
    else
        return 0
    end
end

-- Return the Society module
return Society
