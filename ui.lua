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
    local barWidth = w - 2
    local filled = math.floor(barWidth * (percent / 100))

    -- Draw bar background
    monitor.setCursorPos(1, y)
    monitor.write("Power: " .. percent .. "%")
    y = y + 1

    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(colors.gray)
    monitor.write(string.rep(" ", barWidth))

    -- Draw filled portion
    monitor.setCursorPos(1, y)
    monitor.setBackgroundColor(colors.lime)
    monitor.write(string.rep(" ", filled))

    monitor.setBackgroundColor(config.ui.backgroundColor)
    y = y + 1

    -- Energy numbers
    monitor.setCursorPos(1, y)
    monitor.write(string.format("%d / %d RF", stored, cap))
    y = y + 1

    return y
end

------------------------------------------------------------
-- Draw item list
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
-- Draw warnings (FIXED VERSION)
------------------------------------------------------------
function ui.drawWarnings(warnings, y)
    local w, _ = monitor.getSize()

    -- Always clear a block so old warnings disappear
    local clearLines = 6
    for i = 0, clearLines - 1 do
        monitor.setCursorPos(1, y + i)
        monitor.write(string.rep(" ", w))
    end

    if #warnings == 0 then
        return y
    end

    for _, wItem in ipairs(warnings) do
        monitor.setCursorPos(1, y)
        monitor.write("⚠ " .. wItem.label .. " LOW (" .. wItem.count .. ")")
        y = y + 1
    end

    return y
end

------------------------------------------------------------
-- Draw crafting jobs
------------------------------------------------------------
function ui.drawCrafting(jobs, y)
    for _, job in ipairs(jobs) do
        monitor.setCursorPos(1, y)
        monitor.write("Crafting: " .. job.label .. " (" .. job.amount .. ")")
        y = y + 1

        -- Progress bar
        local w, _ = monitor.getSize()
        local barWidth = w - 2
        local filled = math.floor(barWidth * (job.progress / 100))

        monitor.setCursorPos(1, y)
        monitor.setBackgroundColor(colors.gray)
        monitor.write(string.rep(" ", barWidth))

        monitor.setCursorPos(1, y)
        monitor.setBackgroundColor(colors.orange)
        monitor.write(string.rep(" ", filled))

        monitor.setBackgroundColor(config.ui.backgroundColor)
        y = y + 1
    end

    return y
end

return ui
