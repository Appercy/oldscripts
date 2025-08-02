--[[ 
    @file init.lua
    @description This script initializes the framework for the server. 
    It requires the shared framework module and calls its initialization function.
    @dependencies functions.shared.framework
]]

-- Framework module import
-- Importiert das Framework-Modul
local Framework = require("functions.shared.framework")

-- Initialize the framework
-- Initialisiert das Framework
-- @usage Ruft die `init`-Funktion des Frameworks auf, um es zu starten.
Framework.init()
