--========================================================--
--  main.lua  |  BAER - Big Applied Energistics Readout
--========================================================--

local ae     = require("ae")
local power  = require("power")
local ui     = require("ui")
local config = require("config")

------------------------------------------------------------
-- Find Advanced Monitor
------------------------------------------------------------
local function findMonitor()
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "monitor") then
            return peripheral.wrap(name)
        end
    end
    error("ERROR: No monitor found. Attach an advanced monitor.")
end

local monitor = findMonitor()
ui.init(monitor, config)
ui.bootScreen()

------------------------------------------------------------
-- Main Render Function
------------------------------------------------------------
local function render()
    local w, h = monitor.getSize()
    local y = 1

    monitor.setBackgroundColor(config.ui.backgroundColor)
    monitor.setTextColor(config.ui.textColor)

    --------------------------------------------------------
    -- POWER SECTION
    --------------------------------------------------------
    y = ui.section(config.sections.power, y)

    local pct    = power.getPercent()
    local stored = power.getTotalEnergy()
    local cap    = power.getTotalCapacity()

    y = ui.drawPower(pct, stored, cap, y)
    y = y + 1

    --------------------------------------------------------
    -- ITEMS SECTION
    --------------------------------------------------------
    local dashboardData = ae.getDashboardData(config)

    y = ui.section(config.sections.items, y)
    y = ui.drawItemList(dashboardData.items, y)
    y = y + 1

    --------------------------------------------------------
    -- WARNINGS SECTION
    --------------------------------------------------------
    if #dashboardData.warnings > 0 then
        y = ui.section(config.sections.warnings, y)
        y = ui.drawWarnings(dashboardData.warnings, y)
        y = y + 1
    end

    --------------------------------------------------------
    -- CRAFTING SECTION
    --------------------------------------------------------
    if #dashboardData.crafting > 0 then
        y = ui.section(config.sections.crafting, y)
        y = ui.drawCrafting(dashboardData.crafting, y)
    end
end

------------------------------------------------------------
-- Main Loop
------------------------------------------------------------
while true do
    local ok, err = pcall(render)
    if not ok then
        monitor.setBackgroundColor(colors.black)
        monitor.setTextColor(colors.red)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("DASHBOARD ERROR:")
        monitor.setCursorPos(1, 2)
        monitor.write(err or "unknown error")
    end

    sleep(config.updateInterval or 1.0)
end
