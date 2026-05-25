--========================================================--
--  ae.lua  |  ATM10 v7 AE2 Module (count-based)
--========================================================--

local ae = {}

------------------------------------------------------------
-- Locate ME Bridge
------------------------------------------------------------
local function findMEBridge()
    for _, name in ipairs(peripheral.getNames()) do
        local t = peripheral.getType(name)
        if t == "meBridge"
        or t == "me_bridge"
        or t == "advancedperipherals:me_bridge" then
            return peripheral.wrap(name)
        end
    end
    error("ERROR: No ME Bridge found.")
end

local me = findMEBridge()

------------------------------------------------------------
-- Fetch all items (ATM10 uses getItems)
------------------------------------------------------------
local function fetchAll()
    if type(me.getItems) == "function" then
        return me.getItems() or {}
    end
    return {}
end

------------------------------------------------------------
-- Count a single item
------------------------------------------------------------
function ae.getItemCount(name)
    local all = fetchAll()

    for _, item in ipairs(all) do
        if item.name == name then
            return item.count or 0   -- ATM10 uses "count"
        end
    end

    return 0
end

------------------------------------------------------------
-- Build tracked list
------------------------------------------------------------
function ae.getItemList(list)
    local out = {}
    for _, entry in ipairs(list) do
        table.insert(out, {
            name  = entry.name,
            label = entry.label or entry.name,
            count = ae.getItemCount(entry.name)
        })
    end
    return out
end

------------------------------------------------------------
-- Warnings
------------------------------------------------------------
function ae.getWarnings(list)
    local out = {}
    for _, entry in ipairs(list) do
        local count = ae.getItemCount(entry.name)
        if count <= (entry.threshold or 1) then
            table.insert(out, {
                name      = entry.name,
                label     = entry.label or entry.name,
                count     = count,
                threshold = entry.threshold or 1
            })
        end
    end
    return out
end

------------------------------------------------------------
-- Crafting jobs (unchanged)
------------------------------------------------------------
function ae.getCraftingJobs()
    if type(me.getCraftingCPUs) ~= "function" then return {} end

    local cpus = me.getCraftingCPUs()
    local out = {}

    for _, cpu in ipairs(cpus) do
        if cpu.busy and cpu.craftingJob then
            local job = cpu.craftingJob
            table.insert(out, {
                name     = job.output.name or "Unknown",
                label    = job.output.label or job.output.name or "Unknown",
                amount   = job.output.amount or 1,
                progress = job.progress or 0
            })
        end
    end

    return out
end

------------------------------------------------------------
-- Combined dashboard data
------------------------------------------------------------
function ae.getDashboardData(config)
    return {
        items    = ae.getItemList(config.trackedItems),
        warnings = ae.getWarnings(config.warningItems),
        crafting = ae.getCraftingJobs()
    }
end

return ae
