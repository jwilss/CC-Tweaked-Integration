--========================================================--
--  ui.lua  |  Dashboard UI Rendering Engine
--========================================================--

local ui = {}

------------------------------------------------------------
-- Initialize Monitor
------------------------------------------------------------
function ui.init(monitor, config)
    ui.m = monitor
    ui.cfg = config

    ui.m.setTextScale(config.ui.textScale or 0.5)
    ui.m.setBackgroundColor(colors.black)
    ui.m.setTextColor(config.ui.textColor)
    ui.m.clear()
end

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function centerText(m, y, text)
    local w, _ = m.getSize()
    local x = math.floor((w - #text) / 2) + 1
    m.setCursorPos(x, y)
    m.write(text)
end

local function drawLine(m, y, char)
    local w, _ = m.getSize()
    m.setCursorPos(1, y)
    m.write(string.rep(char, w))
end

------------------------------------------------------------
-- Section Header
------------------------------------------------------------
function ui.section(title, y)
    local m = ui.m
    m.setBackgroundColor(colors.black)
    m.setTextColor(ui.cfg.ui.titleColor)

    centerText(m, y, title)

    m.setTextColor(ui.cfg.ui.textColor)
    return y + 2
end

------------------------------------------------------------
-- Draw a horizontal bar (power, crafting, etc.)
------------------------------------------------------------
function ui.bar(x, y, width, percent)
    local m = ui.m

    -- Background
    m.setBackgroundColor(ui.cfg.ui.barBackground)
    m.setCursorPos(x, y)
    m.write(string.rep(" ", width))

    -- Determine fill color
    local fillColor = ui.cfg.ui.barFill
    if percent < 30 then
        fillColor = ui.cfg.ui.barFillLow
    elseif percent < 60 then
        fillColor = ui.cfg.ui.barFillMid
    end

    -- Fill
    local fill = math.floor((percent / 100) * width)
    m.setBackgroundColor(fillColor)
    m.setCursorPos(x, y)
    m.write(string.rep(" ", fill))

    -- Reset
    m.setBackgroundColor(colors.black)
end

------------------------------------------------------------
-- Draw Item List
------------------------------------------------------------
function ui.drawItemList(items, startY)
    local m = ui.m
    local y = startY

    for _, item in ipairs(items) do
        m.setCursorPos(2, y)
        m.write(string.format("%-20s %s", item.label .. ":", item.count))
        y = y + 1
    end

    return y + ui.cfg.ui.sectionSpacing
end

------------------------------------------------------------
-- Draw Warning List
------------------------------------------------------------
function ui.drawWarnings(warnings, startY)
    local m = ui.m
    local y = startY

    for _, w in ipairs(warnings) do
        m.setTextColor(ui.cfg.ui.warningColor)
        m.setCursorPos(2, y)
        m.write("⚠ " .. w.label .. " LOW (" .. w.count .. ")")
        y = y + 1
    end

    m.setTextColor(ui.cfg.ui.textColor)
    return y + ui.cfg.ui.sectionSpacing
end

------------------------------------------------------------
-- Draw Crafting Jobs
------------------------------------------------------------
function ui.drawCrafting(jobs, startY)
    local m = ui.m
    local y = startY

    for _, job in ipairs(jobs) do
        m.setCursorPos(2, y)
        m.write(job.label .. " (" .. job.amount .. ")")
        y = y + 1

        ui.bar(2, y, 30, job.progress)
        y = y + 2
    end

    return y + ui.cfg.ui.sectionSpacing
end

------------------------------------------------------------
-- Draw Power Section
------------------------------------------------------------
function ui.drawPower(percent, stored, capacity, startY)
    local m = ui.m
    local y = startY

    -- Power bar
    ui.bar(2, y, 40, percent)
    y = y + 2

    -- Text
    m.setCursorPos(2, y)
    m.write(string.format("%s / %s RF",
        ui.formatNumber(stored),
        ui.formatNumber(capacity)
    ))

    return y + ui.cfg.ui.sectionSpacing + 1
end

------------------------------------------------------------
-- Number Formatter (1,234,567)
------------------------------------------------------------
function ui.formatNumber(n)
    local s = tostring(n)
    local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1,1) == "," then
        formatted = formatted:sub(2)
    end
    return formatted
end

return ui
