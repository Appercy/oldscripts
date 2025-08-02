-- print system
-- lib.print.error (for errors)
-- lib.print.info (for info messages) -- NORMAL
-- lib.print.warn (for warnings for user)
-- lib.print.verbose (for verbose output) debugging
-- lib.print.debug (for debugging)

-- set ox:printlevel:tc_banking "warn"

-- for debug prints
if Config.Debug then
    SetConvar('ox:printlevel:' .. GetCurrentResourceName(), 'debug')
end
