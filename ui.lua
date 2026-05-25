--========================================================--
--  ui.lua  |  3‑Column Gems + Raw + Ingots (buffered)
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
local function matchesStrict(id, patterns)
    if not id then return false end
    for _, p in ipairs(patterns) do
        if string.match(id, p) then
            return true
        end
    end
    return false
end

local function collect(patterns)
    local items = ae.listItems()
    local out = {}

    for _, it in ipairs(items) do
        if matchesStrict(it.id, patterns) then
            table.insert(out, { name = it.displayName, count = it.amount })
        end
    end

    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

------------------------------------------------------------
-- Draw a column into a buffer
------------------------------------------------------------
local function drawColumn(buf, x, title, list, colWidth)
    local y = 2

    buf[y] = buf[y] or {}
    buf[y][x] = title
    y = y + 2

    for _, item in ipairs(list) do
        local line = item.name .. ": " .. item.count
        line = line .. string.rep(" ", colWidth - #line)
        buf[y] = buf[y] or {}
        buf[y][x] = line
        y = y + 1
    end
end

------------------------------------------------------------
-- Main draw
------------------------------------------------------------
function ui.draw()
    local w, h = mon.getSize()
    local colWidth = math.floor(w / 3)

    local col1 = 1
    local col2 = col1 + colWidth
    local col3 = col2 + colWidth

    --------------------------------------------------------
    -- Strict gem patterns (no tools/armor)
    --------------------------------------------------------
    local gemPatterns = {
        ":diamond$",
        ":emerald$",
        ":lapis_lazuli$",
        ":redstone$",
        ":quartz$",
        ":amethyst$",
        ":ruby$",
        ":sapphire$",
        ":topaz$",
        ":peridot$",
        ":fluorite$",
        ":opal$",
        ":garnet$",
        ":onyx$",
        ":aquamarine$",
        ":malachite$",
        ":citrine$",
        ":alexandrite$"
    }

    local gems = collect(gemPatterns)
    local raw = collect({ "raw_" })
    local ingots = collect({ "_ingot$", "ingot_" })

    --------------------------------------------------------
    -- Build buffer
    --------------------------------------------------------
    local buffer = {}

    -- ENERGY BAR
    buffer[1] = {}
    buffer[1][1] = "[ ENERGY ] Stored: N/A   Capacity: N/A" ..
                   string.rep(" ", w - 34)

    -- Columns
    drawColumn(buffer, col1, "[ GEMS ]", gems, colWidth)
    drawColumn(buffer, col2, "[ RAW ]", raw, colWidth)
    drawColumn(buffer, col3, "[ INGOTS ]", ingots, colWidth)

    --------------------------------------------------------
    -- Flush buffer to monitor (no flicker)
    --------------------------------------------------------
    for y = 1, h do
        mon.setCursorPos(1, y)
        local line = ""

        if buffer[y] then
            for x = 1, w do
                line = line .. (buffer[y][x] or " ")
            end
        else
            line = string.rep(" ", w)
        end

        mon.write(line)
    end
end

return ui
