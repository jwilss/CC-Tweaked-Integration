-- ============================================================
--  config/settings.lua  –  Edit everything here
--  Tip: change values, save, then reboot the computer in-game.
-- ============================================================

local Config = {}

-- ── Display ─────────────────────────────────────────────────
Config.monitor = {
    side      = "top",   -- side the Advanced Monitor is on
    textScale = 0.5,     -- 0.5 works well for a 3×2 monitor array
}

Config.refreshRate = 2   -- seconds between full redraws

-- ── Storage (Refined Storage bridge OR AE2 bridge) ──────────
Config.storage = {
    -- The peripheral name/side for your RS Bridge or AE2 ME Bridge.
    -- To find the exact name: open the CC shell and type peripheral.getNames()
    bridgeSide = "rs_bridge_0",

    -- Items to highlight on the dashboard
    watchedItems = {
        "Iron Ingot",
        "Gold Ingot",
        "Diamond",
        "Redstone",
        "Obsidian",
    },

    -- Alert (red) if a watched item drops below this
    lowStockThreshold = 64,
}

-- ── Energy ──────────────────────────────────────────────────
Config.energy = {
    -- Sides for Mekanism sources (Induction Matrix, Energy Cube)
    mekanismSides = { "right", "back" },

    -- Sides for Thermal Series energy cells
    thermalSides  = { "bottom" },

    -- Cosmetic unit label – does NOT change the conversion
    -- "FE" | "RF" | "J"
    displayUnit = "FE",
}

-- ── Machines ────────────────────────────────────────────────
Config.machines = {
    -- Add one entry per machine you want tracked.
    -- label: friendly name shown on screen
    -- side:  peripheral side or wired modem name
    list = {
        { label = "Crusher",           side = "east"  },
        { label = "Enrichment",        side = "north" },
        { label = "Os. Compressor",    side = "south" },
        { label = "Pulverizer",        side = "west"  },
    },
}

-- ── Magic ────────────────────────────────────────────────────
--  Requires a CC:Tweaked peripheral integration for your magic mod.
--  Botania: "Botanic Additions" or similar addon.
--  Astral Sorcery: community CC compat mod.
--  Leave the sides tables empty to rely on auto-detection.
Config.magic = {
    botaniaSides = {},     -- e.g. { "north" }  for Mana Pool sides
    astralSides  = {},     -- e.g. { "south" }  for Altar/Infuser sides
}

-- ── Crafting Queue ──────────────────────────────────────────
Config.crafting = {
    -- Items you always want to keep stocked.
    -- The crafting module will flag anything below its target.
    -- Your RS/AE2 autocrafting must have a pattern set up for these.
    keepStocked = {
        { item = "Iron Ingot",   target = 512  },
        { item = "Gold Ingot",   target = 256  },
        { item = "Diamond",      target = 128  },
        { item = "Redstone",     target = 512  },
        { item = "Glass",        target = 256  },
    },
}

-- ── Alerts ──────────────────────────────────────────────────
Config.alerts = {
    lowEnergyPct   = 15,    -- warn when total charge is below X%
    machineOffline = true,  -- warn on machines showing OFFLINE
    flashOnAlert   = true,  -- flash monitor border red on critical
}

-- ── Colours (Advanced Monitor palette) ──────────────────────
--  These map to CC colour constants. Change to taste.
Config.colors = {
    bg           = colors.black,
    header       = colors.cyan,
    headerText   = colors.black,
    sectionTitle = colors.yellow,
    value        = colors.white,
    good         = colors.green,
    warn         = colors.orange,
    bad          = colors.red,
    dim          = colors.gray,
    alertBg      = colors.red,
    alertText    = colors.white,
    mana         = colors.blue,       -- Botania mana bar
    starlight    = colors.lightBlue,  -- Astral starlight bar
}

return Config
