--========================================================--
--  ui.lua  |  Column1: Gems+Raw | Column2: Ingots | Column3: Spawner Drops testtesttewst
--========================================================--

local ui = {}
local mon
local ae = require("ae")

------------------------------------------------------------
-- Init
------------------------------------------------------------
function ui.init(m)
    mon = m
    mon.setTextScale(0.5)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.clear()
end

------------------------------------------------------------
-- Gem filters
------------------------------------------------------------
local VANILLA_GEMS = {
    "diamond",
    "emerald",
    "lapis_lazuli",
    "quartz",
    "redstone"
}

local ATO_GEMS = {
    "ruby",
    "sapphire",
    "topaz",
    "peridot",
    "fluorite",
    "opal",
    "garnet",
    "onyx",
    "aquamarine",
    "alexandrite",
    "citrine",
    "malachite"
}

local function isGem(id)
    if not id then return false end

    -- Vanilla gems
    if id:match("^minecraft:") then
        for _, g in ipairs(VANILLA_GEMS) do
            if id:match(":" .. g .. "$") then
                return true
            end
        end
        return false
    end

    -- AllTheOres gems
    if id:match("^alltheores:") then
        for _, g in ipairs(ATO_GEMS) do
            if id:match(":" .. g .. "$") then
                return true
            end
        end
        return false
    end

    return false
end

------------------------------------------------------------
-- Collectors
------------------------------------------------------------
local function collectGems()
    local items = ae.listItems()
    local out = {}
    for _, it in ipairs(items) do
        if isGem(it.id) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end
    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

local function collectRaw()
    local items = ae.listItems()
    local out = {}
    for _, it in ipairs(items) do
        if it.id:match("raw_") then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end
    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

local function collectIngots()
    local items = ae.listItems()
    local out = {}
    for _, it in ipairs(items) do
        if it.id:match("_ingot$") or it.id:match("ingot_") then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end
    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

------------------------------------------------------------
-- Powah Ender Cell Energy
------------------------------------------------------------
local function getEnergyTotals()
    local totalStored = 0
    local totalMax = 0

    for _, name in ipairs(peripheral.getNames()) do
        if name:match("^ender_cell_") then
            local cell = peripheral.wrap(name)
            if cell and cell.getEnergy and cell.getMaxEnergy then
                totalStored = totalStored + (cell.getEnergy() or 0)
                totalMax    = totalMax    + (cell.getMaxEnergy() or 0)
            end
        end
    end

    return totalStored, totalMax
end

------------------------------------------------------------
-- Draw
------------------------------------------------------------
function ui.draw()
    local w, h = mon.getSize()
    local colWidth = math.floor(w / 3)

    local col1 = 1
    local col2 = col1 + colWidth
    local col3 = col2 + colWidth

    -- Full-frame buffer
    local buffer = {}
    for y = 1, h do
        buffer[y] = string.rep(" ", w)
    end

    --------------------------------------------------------
    -- ENERGY BAR (ASCII only, one line)
    --------------------------------------------------------
    local stored, max = getEnergyTotals()
    local pct = (max > 0) and math.floor((stored / max) * 100) or 0

    local left = string.format(
        "[ ENERGY ] %s / %s RF (%d%%) ",
        stored, max, pct
    )

    local barWidth = w - #left
    if barWidth < 10 then barWidth = 10 end

    local filled = math.floor((pct / 100) * barWidth)
    local bar = string.rep("#", filled) .. string.rep("-", barWidth - filled)

    local line = left .. bar
    if #line > w then
        line = line:sub(1, w)
    else
        line = line .. string.rep(" ", w - #line)
    end

    buffer[1] = line

    --------------------------------------------------------
    -- Collect data
    --------------------------------------------------------
    local gems   = collectGems()
    local raw    = collectRaw()
    local ingots = collectIngots()

    --------------------------------------------------------
    -- Column writer
    --------------------------------------------------------
    local function writeColumn(startX, title, list, startY)
        local y = startY

        -- Title
        local t = title
        if #t > colWidth then t = t:sub(1, colWidth) end
        t = t .. string.rep(" ", colWidth - #t)
        buffer[y] = buffer[y]:sub(1, startX - 1) .. t .. buffer[y]:sub(startX + #t)
        y = y + 2

        -- Items
        for i = 1, math.min(#list, h - y) do
            local line = list[i].name .. ": " .. list[i].count
            if #line > colWidth then
                line = line:sub(1, colWidth)
            end
            line = line .. string.rep(" ", colWidth - #line)

            buffer[y] = buffer[y]:sub(1, startX - 1) .. line .. buffer[y]:sub(startX + #line)
            y = y + 1
        end

        return y
    end

    --------------------------------------------------------
    -- Column 1: GEMS then RAW
    --------------------------------------------------------
    local nextY = writeColumn(col1, "[ GEMS ]", gems, 3)
    writeColumn(col1, "[ RAW ]", raw, nextY + 1)

    --------------------------------------------------------
    -- Column 2: INGOTS
    --------------------------------------------------------
    writeColumn(col2, "[ INGOTS ]", ingots, 3)

    --------------------------------------------------------
    -- Column 3: RESERVED FOR SPAWNER DROPS
    --------------------------------------------------------
    writeColumn(col3, "[ SPAWNER DROPS ]", {}, 3)

    --------------------------------------------------------
    -- Flush buffer (no flicker)
    --------------------------------------------------------
    for y = 1, h do
        mon.setCursorPos(1, y)
        mon.write(buffer[y])
    end
end

------------------------------------------------------------
-- Update interval
------------------------------------------------------------
function ui.run()
    while true do
        ui.draw()
        sleep(2)
    end
end

return ui
