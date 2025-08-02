--[[ 
    Configurations for the Boss Menu Script
    This script defines the configuration for locations, permissions, markers, and NPCs.
    @file config.lua
    @description This file contains the configuration for the ESX Legacy Boss Menu.
]]

-- Main configuration table
Config = {}

-- Debug mode (set to true for debugging purposes)
Config.Debug = false

-- Locations configuration
Config.Locations = {
    ["police"] = { -- Polizeistation
        -- Koordinaten für die Polizeistation
        ["coords"] = vector4(224.7363, -810.1734, 30.5726, 194.4957),
        
        -- Distanz für Interaktionen
        ["distance"] = 10.0,
        
        -- Geldwäsche aktivieren (Einstellungen in esx_society)
        ["washmoney"] = true,

        -- Berechtigungen für verschiedene Ränge
        ["permissions"] = {
            [4] = { 
                max = true -- Alle Berechtigungen für diesen Rang und alle darüber (auser anderst definiert)
            },
            [3] = { -- Rang 3 Berechtigungen
                ["withdraw"] = true, -- Geld abheben
                ["deposit"] = true, -- Geld einzahlen
                ["hire"] = true, -- Spieler einstellen
                ["fire"] = false, -- Spieler entlassen
                ["showPlayers"] = true, -- Spieler anzeigen
                ["washMoney"] = true, -- Geld waschen
                ["changeSalary"] = true, -- Gehalt ändern
            },
            [2] = { -- Rang 2 Berechtigungen
                ["withdraw"] = false,
                ["deposit"] = true,
                ["hire"] = false,
                ["fire"] = false,
                ["showPlayers"] = false,
                ["washMoney"] = false,
                ["changeSalary"] = false,
            },
            [1] = { -- Rang 1 Berechtigungen
                ["withdraw"] = false,
                ["deposit"] = false,
                ["hire"] = false,
                ["fire"] = false,
                ["showPlayers"] = false,
                ["washMoney"] = false,
                ["changeSalary"] = false,
            },
        },

        -- Marker-Konfiguration
        ["marker"] = {
            -- Offset des Markers
            ["offset"] = vector3(0.0, 0.0, -1.0),
            
            -- Breite und Höhe des Markers
            ["width"] = 2.5,
            ["height"] = 2.5,
            
            -- Typ und Skalierung des Markers
            ["type"] = 1,
            ["scale"] = vector3(0.5, 0.5, 0.5),
            
            -- Farbe des Markers (RGBA)
            ["color"] = {r = 0, g = 0, b = 100, a = 255},
            
            -- Richtung und Rotation des Markers
            ["direction"] = vector3(0.0, 0.0, 0.0),
            ["rotation"] = vector3(0.0, 0.0, 0.0),
        },

        -- NPC-Konfiguration
        ["ped"] = {
            -- Modell des NPCs
            ["model"] = "s_m_y_cop_01",
            
            -- Koordinaten des NPCs
            ["coords"] = vector4(224.7363, -810.1734, 29.5726, 194.4957),
        },
    },
}