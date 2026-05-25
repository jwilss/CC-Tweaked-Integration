-- ============================================================
--  ATM10 Smart Integration  |  startup.lua
--  Entry point. Loads all modules, then runs the dashboard.
-- ============================================================

package.path = package.path .. ";/modules/?.lua"

local Config   = require("config.settings")
local Display  = require("modules.display")
local Storage  = require("modules.storage")
local Energy   = require("modules.energy")
local Machines = require("modules.machines")
local Magic    = require("modules.magic")
local Crafting = require("modules.crafting")
local Alerts   = require("modules.alerts")
local Utils    = require("modules.utils")

-- ── Boot ────────────────────────────────────────────────────
local function boot()
    term.clear()
    term.setCursorPos(1, 1)
    print("[ATM10] Booting smart integration...")

    Utils.discoverPeripherals()

    local monitor = Display.init(Config.monitor.side, Config.monitor.textScale)
    if not monitor then
        error("[ATM10] No advanced monitor found on side: " .. Config.monitor.side)
    end

    print("[ATM10] Monitor OK.")
    print("[ATM10] Modules: Storage, Energy, Machines, Magic, Crafting")
    print("[ATM10] Starting dashboard loop (refresh: " .. Config.refreshRate .. "s)")
    sleep(1)

    -- ── Main loop ────────────────────────────────────────────
    while true do
        local ok, err = pcall(function()
            local data = {
                storage  = Storage.collect(),
                energy   = Energy.collect(),
                machines = Machines.collect(),
                magic    = Magic.collect(),
                crafting = Crafting.collect(),
            }
            Alerts.evaluate(data)
            Display.render(monitor, data, Alerts.getActive())
        end)

        if not ok then
            Display.renderError(monitor, err)
        end

        sleep(Config.refreshRate)
    end
end

boot()
