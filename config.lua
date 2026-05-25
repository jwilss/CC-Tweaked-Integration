local config = {}

------------------------------------------------------------
-- UI SETTINGS (REQUIRED)
------------------------------------------------------------
config.ui = {
    scale            = 0.5,
    backgroundColor  = colors.black,
    textColor        = colors.white,
    sectionBackground = colors.yellow,
    sectionText       = colors.black,
    warnBackground   = colors.red,
    warnText         = colors.white,
    bootBackground   = colors.black,
    bootText         = colors.yellow,
    bootDelay        = 0.02,
    warnPulseSpeed   = 0.4
}

------------------------------------------------------------
-- ITEM IDS FOR REAL COUNTS (REQUIRED)
------------------------------------------------------------
config.items = {
    industrial_foregoing = {
        latex   = { "industrialforegoing:latex_bucket" },
        plastic = { "industrialforegoing:plastic" }
    },

    essences = {
        inferium   = { "mysticalagriculture:inferium_essence" },
        prudentium = { "mysticalagriculture:prudentium_essence" },
        supremium  = { "mysticalagriculture:supremium_essence" }
    },

    mob_drops = {
        gunpowder = { "minecraft:gunpowder" },
        pearls    = { "minecraft:ender_pearl" },
        skulls    = { "minecraft:wither_skeleton_skull" }
    }
}

------------------------------------------------------------
-- WARNING ITEMS (REQUIRED)
------------------------------------------------------------
config.warningItems = {
    { name="minecraft:netherite_upgrade_smithing_template", label="Netherite", threshold=1 },
    { name="allthemodium:allthemodium_upgrade_smithing_template", label="Allthemodium", threshold=1 },
    { name="allthemodium:vibranium_upgrade_smithing_template", label="Vibranium", threshold=1 },
    { name="allthemodium:unobtainium_upgrade_smithing_template", label="Unobtainium", threshold=1 }
}

------------------------------------------------------------
-- UPDATE SPEED
------------------------------------------------------------
config.updateInterval = 0.5

return config
