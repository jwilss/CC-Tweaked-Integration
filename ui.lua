--========================================================--
--  ui.lua  |  Dashboard UI Rendering Module
--========================================================--

local ui = {}
local monitor
local config

------------------------------------------------------------
-- Initialize UI
------------------------------------------------------------
function ui.init(mon, cfg)
    monitor = mon
    config = cfg

    monitor.setBackgroundColor(config.ui.backgroundColor)
    monitor.setTextColor(config.ui.textColor)
    monitor.clear()
    monitor.setCursorPos(1, 1)

    if config.ui.scale then
        monitor.setTextScale(config.ui.scale)
    end
end

------------------------------------------------------------
-- Draw a section header
------------------------------------------------------------
function ui.section(title, y)
    local w, _ = monitor.getSize()

    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(config.ui.sectionBackground)
    monitor.setTextColor(config.ui.sectionText)
    monitor.write(string.rep(" ", w))

    monitor.setCursorPos(2, y)
    monitor.write(title)

    monitor.setBackgroundColor(config.ui.backgroundColor)
    monitor.setTextColor(config.ui.textColor)

    return y + 1
end

------------------------------------------------------------
-- Draw power bar
------------------------------------------------------------
function ui.drawPower(percent, stored, cap, y)
    local w, _ = monitor.getSize()

    -- Bar width
    local barWidth
