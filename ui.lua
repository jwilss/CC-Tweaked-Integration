--========================================================--
--  ui.lua  |  3‑Column Gems + Raw + Ingots (no flicker)
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
local function clearColumn(x, width, height)
    for y = 1, height do
        mon.setCursorPos(x, y)
        mon.write(string.rep(" ", width))
    end
end

local function matches(str, patterns)
    if not str then return false end
    for _, p in ipairs(patterns) do
        if string.find(str, p) then
            return true
        end
    end
    return false
end

local function collect(patterns)
    local items = ae.listItems()
    local out = {}

    for _, it in ipairs(items) do
        if matches(it.id, patterns) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end

    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

local function drawColumn(x, width, title, list)
    local y = 2

    -- Header
    mon.setCursorPos(x, y)
    mon.setBackgroundColor(colors.yellow)
    mon.setTextColor(colors.black)
    mon.write(title .. string.rep(" ", width - #title))
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    y = y + 2

    -- Items
    for _, item in ipairs(list) do
        mon.setCursorPos(x, y)
        local line = item.name .. ": " .. item.count
        mon.write(line .. string.rep(" ", width - #line))
        y = y + 1
    end
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

    -- Clear columns (prevents ghosting)
    clearColumn(col1, colWidth, h)
    clearColumn(col2, colWidth, h)
    clearColumn(col3, colWidth, h)

    --------------------------------------------------------
    -- ENERGY BAR (full width)
    --------------------------------------------------------
    mon.setCursorPos(1, 1)
    mon.setBackgroundColor(colors.blue)
    mon.setTextColor(colors.white)
    mon.write("[ ENERGY ] Stored: N/A   Capacity: N/A" ..
              string.rep(" ", w - 34))
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)

    --------------------------------------------------------
    -- GEMS
    --------------------------------------------------------
    local gems = collect({
        "diamond",
        "emerald",
        "lapis",
        "redstone",
        "quartz",
        "amethyst",
        "ruby",
        "sapphire",
        "topaz",
        "peridot",
        "fluorite",
        "_gem",
        "gem_",
        "_crystal",
        "crystal_"
    })

    --------------------------------------------------------
    -- RAW MATERIALS
    --------------------------------------------------------
    local raw = collect({
        "raw_",
        "_raw"
    })

    --------------------------------------------------------
    -- INGOTS
    --------------------------------------------------------
    local ingots = collect({
        "_ingot",
        "ingot_"
    })

    --------------------------------------------------------
    -- Draw columns
    --------------------------------------------------------
    drawColumn(col1, colWidth, "[ GEMS ]", gems)
    drawColumn(col2, colWidth, "[ RAW ]", raw)
    drawColumn(col3, colWidth, "[ INGOTS ]", ingots)
end

return ui
