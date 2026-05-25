--========================================================--
--  ui.lua  |  3‑Column Gems + Raw + Ingots (final, no flicker)
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
-- Helpers
------------------------------------------------------------
local GEM_WHITELIST = {
    "diamond",
    "emerald",
    "lapis_lazuli",
    "redstone",
    "quartz",
    "amethyst",
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
    for _, g in ipairs(GEM_WHITELIST) do
        if id:match(":" .. g .. "$") then
            return true
        end
    end
    return false
end

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
-- Draw
------------------------------------------------------------
function ui.draw()
    local w, h = mon.getSize()
    local colWidth = math.floor(w / 3)

    local col1 = 1
    local col2 = col1 + colWidth
    local col3 = col2 + colWidth

    -- Build full-frame buffer
    local buffer = {}
    for y = 1, h do
        buffer[y] = string.rep(" ", w)
    end

    --------------------------------------------------------
    -- ENERGY BAR
    --------------------------------------------------------
    local energyLine = "[ ENERGY ] Stored: N/A   Capacity: N/A"
    buffer[1] = energyLine .. string.rep(" ", w - #energyLine)

    --------------------------------------------------------
    -- Collect data
    --------------------------------------------------------
    local gems = collectGems()
    local raw = collectRaw()
    local ingots = collectIngots()

    --------------------------------------------------------
    -- Column writer
    --------------------------------------------------------
    local function writeColumn(startX, title, list)
        local y = 3

        -- Title
        local t = title .. string.rep(" ", colWidth - #title)
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
    end

    --------------------------------------------------------
    -- Draw columns
    --------------------------------------------------------
    writeColumn(col1, "[ GEMS ]", gems)
    writeColumn(col2, "[ RAW ]", raw)
    writeColumn(col3, "[ INGOTS ]", ingots)

    --------------------------------------------------------
    -- Flush buffer (no flicker)
    --------------------------------------------------------
    for y = 1, h do
        mon.setCursorPos(1, y)
        mon.write(buffer[y])
    end
end

return ui
