--========================================================--
--  ui.lua  |  BAER Industrial ASCII UI
--========================================================--

local ui = {}
local monitor
local cfg

local pulsePhase = 1
local lastPulseTime = 0

------------------------------------------------------------
-- Init
------------------------------------------------------------
function ui.init(mon, config)
    monitor = mon
    cfg = config

    monitor.setTextScale(cfg.ui.scale)
    monitor.setBackgroundColor(cfg.ui.backgroundColor)
    monitor.setTextColor(cfg.ui.textColor)
    monitor.clear()
end

------------------------------------------------------------
-- Centered write helper
------------------------------------------------------------
local function writeCentered(y, text)
    local w = select(1, monitor.getSize())
    local x = math.floor((w - #text) / 2) + 1
    monitor.setCursorPos(x, y)
    monitor.write(text)
end

------------------------------------------------------------
-- ASCII‑Safe Boot Screen
------------------------------------------------------------
function ui.bootScreen()
    local w, h = monitor.getSize()
    monitor.setBackgroundColor(cfg.ui.bootBackground)
    monitor.setTextColor(cfg.ui.bootText)
    monitor.clear()

    local logo = {
        "   ###    ##   #####   #####        ",
        "   #  #  #  #  #       #    #       ",
        "   ###   ####  ####    #####        ",
        "   #  #  #  #  #       #   #        ",
        "   ###   #  #  #####   #    #       ",
        "                                    ",
        "   BIG APPLIED ENERGETICS READOUT   ",
        "               (BAER)               "
    }

    local top = math.floor((h - #logo) / 2)

    writeCentered(top - 2, string.rep("=", math.min(w - 2, 60)))

    for i, line in ipairs(logo) do
        writeCentered(top - 1 + i, line)
        sleep(cfg.ui.bootDelay)
    end

    writeCentered(top + #logo + 1, string.rep("=", math.min(w - 2, 60)))
    sleep(0.4)

    local checks = {
        "[ OK ] Peripheral Scan",
        "[ OK ] ME Bridge Online",
        "[ OK ] Powah Link Established",
        "[ OK ] Storage Index Loaded",
        "[ OK ] Dashboard Renderer Ready",
        "",
        "BAER SYSTEM ONLINE"
    }

    local y = top + #logo + 3
    for _, line in ipairs(checks) do
        writeCentered(y, line)
        y = y + 1
        sleep(0.2)
    end

    sleep(0.8)
    monitor.setBackgroundColor(cfg.ui.backgroundColor)
    monitor.setTextColor(cfg.ui.textColor)
    monitor.clear()
end

------------------------------------------------------------
-- Section Header (ASCII Hazard Style)
------------------------------------------------------------
function ui.section(title, y)
    local w = select(1, monitor.getSize())

    monitor.setBackgroundColor(cfg.ui.sectionBackground)
    monitor.setTextColor(cfg.ui.sectionText)

    monitor.setCursorPos(1, y)
    local line = title .. string.rep("=", math.max(0, w - #title))
    monitor.write(line:sub(1, w))

    monitor.setBackgroundColor(cfg.ui.backgroundColor)
    monitor.setTextColor(cfg.ui.textColor)

    return y + 1
end

------------------------------------------------------------
-- Power Section
------------------------------------------------------------
function ui.drawPower(percent, stored, cap, y)
    local w = select(1, monitor.getSize())
    local barWidth = math.max(10, w - 2)

    monitor.setCursorPos(1, y)
    monitor.setTextColor(colors.yellow)
    monitor.write(string.format("Power: %3d%%", percent or 0))
    y = y + 1

    local pct = math.max(0, math.min(100, percent or 0))
    local filled = math.floor(barWidth * (pct / 100))

    monitor.setCursorPos(1, y)
    monitor.write("[" .. string.rep("#", filled) .. string.rep("-", barWidth - filled) .. "]")
    y = y + 1

    monitor.setCursorPos(1, y)
    monitor.setTextColor(cfg.ui.textColor)
    monitor.write(string.format("%d / %d RF", stored or 0, cap or 0))
    y = y + 1

    return y
end

------------------------------------------------------------
-- Item List
------------------------------------------------------------
function ui.drawItemList(items, y)
    monitor.setTextColor(cfg.ui.textColor)
    for _, item in ipairs(items) do
        monitor.setCursorPos(1, y)
        monitor.write(string.format("%-20s %d", item.label, item.count))
        y = y + 1
    end
    return y
end

------------------------------------------------------------
-- Pulsing ASCII Warning Banner
------------------------------------------------------------
local function updatePulse()
    local t = os.clock()
    if t - lastPulseTime >= (cfg.ui.warnPulseSpeed or 0.5) then
        lastPulseTime = t
        pulsePhase = (pulsePhase % 3) + 1
    end
end

function ui.drawWarnings(warnings, y)
    local w = select(1, monitor.getSize())
    updatePulse()

    for i = 0, 2 do
        monitor.setCursorPos(1, y + i)
        monitor.write(string.rep(" ", w))
    end

    if #warnings == 0 then
        return y + 1
    end

    local wItem = warnings[1]
    local msg = string.format("! WARNING: %s LOW - %d REMAINING !", wItem.label, wItem.count)

    local bg, fg
    if pulsePhase == 1 then
        bg, fg = cfg.ui.warnBackground, cfg.ui.warnText
    elseif pulsePhase == 2 then
        bg, fg = colors.black, cfg.ui.warnBackground
    else
        bg, fg = colors.red, colors.white
    end

    monitor.setBackgroundColor(bg)
    monitor.setTextColor(fg)

    monitor.setCursorPos(1, y)
    monitor.write(string.rep("#", w))

    monitor.setCursorPos(1, y + 1)
    monitor.write(msg .. string.rep(" ", math.max(0, w - #msg)))

    monitor.setCursorPos(1, y + 2)
    monitor.write(string.rep("#", w))

    monitor.setBackgroundColor(cfg.ui.backgroundColor)
    monitor.setTextColor(cfg.ui.textColor)

    return y + 3
end

------------------------------------------------------------
-- Crafting Jobs
------------------------------------------------------------
function ui.drawCrafting(jobs, y)
    local w = select(1, monitor.getSize())
    for _, job in ipairs(jobs) do
        monitor.setCursorPos(1, y)
        monitor.setTextColor(colors.orange)
        monitor.write(string.format("Crafting: %s (%d)", job.label, job.amount))
        y = y + 1

        local barWidth = math.max(10, w - 2)
        local pct = math.max(0, math.min(100, job.progress or 0))
        local filled = math.floor(barWidth * (pct / 100))

        monitor.setCursorPos(1, y)
        monitor.write("[" .. string.rep("#", filled) .. string.rep("-", barWidth - filled) .. "]")
        y = y + 1
    end

    monitor.setTextColor(cfg.ui.textColor)
    return y
end

return ui
