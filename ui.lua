--========================================================--
--  ui.lua  |  Full Dashboard: Gems+Raw | Ingots | Player/Server Info
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
    "ruby","sapphire","topaz","peridot","fluorite","opal",
    "garnet","onyx","aquamarine","alexandrite","citrine","malachite"
}

local function isGem(id)
    if not id then return false end

    if id:match("^minecraft:") then
        for _, g in ipairs(VANILLA_GEMS) do
            if id:match(":" .. g .. "$") then return true end
        end
        return false
    end

    if id:match("^alltheores:") then
        for _, g in ipairs(ATO_GEMS) do
            if id:match(":" .. g .. "$") then return true end
        end
        return false
    end

    return false
end

------------------------------------------------------------
-- Collectors
------------------------------------------------------------
local function collectGems()
    local out = {}
    for _, it in ipairs(ae.listItems()) do
        if isGem(it.id) then table.insert(out, {name=it.displayName,count=it.amount}) end
    end
    table.sort(out, function(a,b) return a.name < b.name end)
    return out
end

local function collectRaw()
    local out = {}
    for _, it in ipairs(ae.listItems()) do
        if it.id:match("raw_") then table.insert(out, {name=it.displayName,count=it.amount}) end
    end
    table.sort(out, function(a,b) return a.name < b.name end)
    return out
end

local function collectIngots()
    local out = {}
    for _, it in ipairs(ae.listItems()) do
        if it.id:match("_ingot$") or it.id:match("ingot_") then
            table.insert(out, {name=it.displayName,count=it.amount})
        end
    end
    table.sort(out, function(a,b) return a.name < b.name end)
    return out
end

------------------------------------------------------------
-- Powah Energy
------------------------------------------------------------
local function getEnergyTotals()
    local stored, max = 0, 0
    for _, name in ipairs(peripheral.getNames()) do
        if name:match("^ender_cell_") then
            local c = peripheral.wrap(name)
            if c and c.getEnergy then
                stored = stored + (c.getEnergy() or 0)
                max    = max    + (c.getMaxEnergy() or 0)
            end
        end
    end
    return stored, max
end

------------------------------------------------------------
-- Player Info Helpers
------------------------------------------------------------
local function getPlayers()
    if not commands then return {} end
    local ok, data = pcall(commands.list)
    if ok and data then return data end
    return {}
end

local function getPlayerInfoSafe(p)
    if not commands then return {} end
    local ok, data = pcall(commands.getPlayerInfo, p)
    if ok and data then return data end
    return {}
end

------------------------------------------------------------
-- Server Info Helpers
------------------------------------------------------------
local function getTPS()
    if not commands or not commands.tps then return {mean=0,min=0,max=0} end
    local ok, data = pcall(commands.tps)
    if ok and data then return data end
    return {mean=0,min=0,max=0}
end

local function getWeather()
    if not commands or not commands.weather then return "?" end
    local ok, data = pcall(commands.weather)
    if ok and data then return tostring(data) end
    return "?"
end

local function getWorldTime()
    if not commands or not commands.time then return 0 end
    local ok, data = pcall(commands.time)
    if ok and data then return data end
    return 0
end

local function getMemory()
    if not commands or not commands.memory then return 0 end
    local ok, data = pcall(commands.memory)
    if ok and data then return data end
    return 0
end

------------------------------------------------------------
-- Draw
------------------------------------------------------------
function ui.draw()
    local w, h = mon.getSize()

    -- Column widths
    local col3Width = math.floor(w * 0.20)
    local col1Width = math.floor((w - col3Width) * 0.50)
    local col2Width = w - col3Width - col1Width

    local col1 = 1
    local col2 = col1 + col1Width
    local col3 = col2 + col2Width

    -- Full buffer
    local buffer = {}
    for y=1,h do buffer[y] = string.rep(" ", w) end

    --------------------------------------------------------
    -- ENERGY BAR (ASCII)
    --------------------------------------------------------
    local stored, max = getEnergyTotals()
    local pct = (max > 0) and math.floor((stored/max)*100) or 0

    local left = string.format("[ ENERGY ] %s / %s RF (%d%%) ", stored, max, pct)
    local barWidth = w - #left
    if barWidth < 10 then barWidth = 10 end

    local filled = math.floor((pct/100)*barWidth)
    local bar = string.rep("#", filled) .. string.rep("-", barWidth - filled)

    local line = left .. bar
    if #line < w then line = line .. string.rep(" ", w - #line) end
    buffer[1] = line

    --------------------------------------------------------
    -- Collect data
    --------------------------------------------------------
    local gems   = collectGems()
    local raw    = collectRaw()
    local ingots = collectIngots()
    local players = getPlayers()

    --------------------------------------------------------
    -- Column writer
    --------------------------------------------------------
    local function writeColumn(startX, width, title, list, startY)
        local y = startY
        local t = title .. string.rep(" ", width - #title)
        buffer[y] = buffer[y]:sub(1,startX-1) .. t .. buffer[y]:sub(startX+width)
        y = y + 2

        for i=1, math.min(#list, h-y) do
            local line = list[i].name .. ": " .. list[i].count
            if #line > width then line = line:sub(1,width) end
            line = line .. string.rep(" ", width - #line)
            buffer[y] = buffer[y]:sub(1,startX-1) .. line .. buffer[y]:sub(startX+width)
            y = y + 1
        end

        return y
    end

    --------------------------------------------------------
    -- Column 1: GEMS then RAW
    --------------------------------------------------------
    local nextY = writeColumn(col1, col1Width, "[ GEMS ]", gems, 3)
    writeColumn(col1, col1Width, "[ RAW ]", raw, nextY + 1)

    --------------------------------------------------------
    -- Column 2: INGOTS
    --------------------------------------------------------
    writeColumn(col2, col2Width, "[ INGOTS ]", ingots, 3)

    --------------------------------------------------------
    -- Column 3: PLAYER + SERVER INFO
    --------------------------------------------------------
    local y = 3

    -- PLAYERS
    local function writeC3(str)
        if #str > col3Width then str = str:sub(1,col3Width) end
        str = str .. string.rep(" ", col3Width - #str)
        buffer[y] = buffer[y]:sub(1,col3-1) .. str .. buffer[y]:sub(col3+col3Width)
        y = y + 1
    end

    writeC3("[ PLAYERS ]")
    y = y + 1

    for _, p in ipairs(players) do
        local info = getPlayerInfoSafe(p)
        local dim  = info.dimension or "?"
        local pos  = info.pos or {0,0,0}
        local afk  = (info.movement == 0) and "yes" or "no"

        writeC3(p)
        writeC3("Dim: " .. dim)
        writeC3(string.format("XYZ: %d %d %d", pos[1] or 0, pos[2] or 0, pos[3] or 0))
        writeC3("AFK: " .. afk)
        y = y + 1
    end

    y = y + 1

    -- TPS
    writeC3("[ TPS ]")
    y = y + 1

    local tps = getTPS()
    writeC3(string.format("Mean: %.1f", tps.mean))
    writeC3(string.format("Min:  %.1f", tps.min))
    writeC3(string.format("Max:  %.1f", tps.max))
    y = y + 2

    -- UPTIME
    writeC3("[ UPTIME ]")
    y = y + 1

    local uptimeTicks = os.clock() * 20
    local uptimeHours = math.floor(uptimeTicks / 72000)
    local uptimeMins  = math.floor((uptimeTicks % 72000) / 1200)
    writeC3(string.format("%dh %dm", uptimeHours, uptimeMins))
    y = y + 2

    -- TIME
    writeC3("[ TIME ]")
    y = y + 1

    local worldTime = getWorldTime()
    local dayTime = worldTime % 24000
    writeC3("Ticks: " .. dayTime)
    writeC3("Phase: " .. ((dayTime > 13000) and "Night" or "Day"))
    y = y + 2

    -- WEATHER
    writeC3("[ WEATHER ]")
    y = y + 1
    writeC3(getWeather())
    y = y + 2

    -- MEMORY
    writeC3("[ MEMORY ]")
    y = y + 1
    local mem = getMemory()
    writeC3(string.format("%d MB", mem))
    y = y + 1

    --------------------------------------------------------
    -- Flush buffer
    --------------------------------------------------------
    for yy=1,h do
        mon.setCursorPos(1,yy)
        mon.write(buffer[yy])
    end
end

------------------------------------------------------------
-- Update loop
------------------------------------------------------------
function ui.run()
    while true do
        ui.draw()
        sleep(2)
    end
end

return ui
