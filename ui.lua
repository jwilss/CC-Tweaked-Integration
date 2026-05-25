--========================================================--
--  ui.lua  |  Styled Dashboard UI
--========================================================--

local ui = {}
local monitor
local cfg

------------------------------------------------------------
-- Init
------------------------------------------------------------
function ui.init(mon, config)
    monitor = mon
    cfg = config

    monitor.setTextScale(cfg.ui.scale)
    monitor.setBackgroundColor(cfg.ui.background)
    monitor.setTextColor(cfg.ui.text)
    monitor.clear()
end

------------------------------------------------------------
-- Boot Animation
------------------------------------------------------------
function ui.bootScreen()
    local w, h = monitor.getSize()
    monitor.setBackgroundColor(cfg.ui.bootBg)
    monitor.setTextColor(cfg.ui.bootText)
    monitor.clear()

    local logo = {
        " ██████╗  █████╗ ███████╗██████╗ ",
        " ██╔══██╗██╔══██╗██╔════╝██╔══██╗",
        " ██████╔╝███████║█████╗  ██████╔╝",
        " ██╔══██╗██╔══██║██╔══╝  ██╔══██╗",
        " ██████╔╝██║  ██║███████╗██║  ██║",
        " ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝",
        " Big Applied Energistics Readout "
    }

    local startY = math.floor((h - #logo) / 2)

    for i, line in ipairs(logo) do
        monitor.setCursorPos(math.floor((w - #line) / 2), startY + i)
        monitor.write(line)
        sleep(cfg.ui.bootDelay)
    end

    sleep(0.5)
    monitor.clear()
end

------------------------------------------------------------
-- Section Header
------------------------------------------------------------
function ui.section(title, y)
    local w = select(1, monitor.getSize())

    monitor.setBackgroundColor(cfg.ui.sectionBg)
    monitor.setTextColor(cfg.ui.sectionText)

    monitor.setCursorPos(1, y)
    monitor.write(string.rep(" ", w))

    monitor.setCursorPos(2, y)
    monitor.write(title)

    monitor.setBackgroundColor(cfg.ui.background)
    monitor.setTextColor(cfg.ui.text)

    return y + 1
end

------------------------------------------------------------
-- Power Bar
------------------------------------------------------------
function ui.drawPower(percent, stored, cap, y)
    local w = select(1, monitor.getSize())
    local barWidth = w - 2
    local filled = math.floor(barWidth * (percent / 100))

    monitor.setCursorPos(1, y)
    monitor.write("Power: " .. percent .. "%")
    y = y + 1

    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(colors.gray)
    monitor.write(string.rep(" ", barWidth))

    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(colors.lime)
    monitor.write(string.rep(" ", filled))

    monitor.setBackgroundColor(cfg.ui.background)
    y = y + 1

    monitor.setCursorPos(1, y)
    monitor.write(stored .. " / " .. cap .. " RF")
    y = y + 1

    return y
end

------------------------------------------------------------
-- Item List
------------------------------------------------------------
function ui.drawItemList(items, y)
    for _, item in ipairs(items) do
        monitor.setCursorPos(1, y)
        monitor.write(item.label .. ": " .. item.count)
        y = y + 1
    end
    return y
end

------------------------------------------------------------
-- Warning Bar (clean + auto-clear)
------------------------------------------------------------
function ui.drawWarnings(warnings, y)
    local w = select(1, monitor.getSize())

    -- Clear area
    for i = 0, 3 do
        monitor.setCursorPos(1, y + i)
        monitor.write(string.rep(" ", w))
    end

    if #warnings == 0 then
        return y + 1
    end

    local wItem = warnings[1]

    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(cfg.ui.warnBg)
    monitor.setTextColor(cfg.ui.warnText)
    monitor.write("⚠ " .. wItem.label .. " LOW (" .. wItem.count .. ")")

    monitor.setBackgroundColor(cfg.ui.background)
    monitor.setTextColor(cfg.ui.text)

    return y + 1
end

------------------------------------------------------------
-- Crafting Jobs
------------------------------------------------------------
function ui.drawCrafting(jobs, y)
    for _, job in ipairs(jobs) do
        monitor.setCursorPos(1, y)
        monitor.write("Crafting: " .. job.label .. " (" .. job.amount .. ")")
        y = y + 1

        local w = select(1, monitor.getSize())
        local barWidth = w - 2
        local filled = math.floor(barWidth * (job.progress / 100))

        monitor.setCursorPos(1, y)
        monitor.setBackgroundColor(colors.gray)
        monitor.write(string.rep(" ", barWidth))

        monitor.setCursorPos(1, y)
        monitor.setBackgroundColor(colors.orange)
        monitor.write(string.rep(" ", filled))

        monitor.setBackgroundColor(cfg.ui.background)
        y = y + 1
    end

    return y
end

return ui
