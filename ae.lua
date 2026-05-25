--========================================================--
--  ae.lua  |  Unified AE2 Item, Warning & Crafting Module
--========================================================--

local ae = {}

------------------------------------------------------------
-- Locate ME Bridge (supports all naming variants)
------------------------------------------------------------
local function findMEBridge()
    for _, name in ipairs(peripheral.getNames()) do
        local pType = peripheral.getType(name)

        -- Support all known AP ME Bridge identifiers
        if pType == "meBridge"
        or pType == "me_bridge"
        or pType == "advancedperipherals:me_bridge"
        or pType == "advancedperipherals:mebridge" then
            return peripheral.wrap(name)
        end
    end

    error("ERROR: No ME Bridge found. Ensure Advanced Peripherals ME Bridge is connected.")
end

local me = findMEBridge()

------------------------------------------------------------
-- Item Count Helpers
------------------------------------------------------------

-- Get count of a single item
function ae.getItemCount(itemName)
    local item = me.getItem({ name = itemName })
    if item and item.amount then
        return item.amount
    end
    return 0
end

-- Get counts for a list of items
function ae.getItemList(list)
    local results = {}
    for _, entry in ipairs(list) do
        local name = entry.name
        local label = entry.label or name
        local count = ae.getItemCount(name)

        table.insert(results, {
            name = name,
            label = label,
            count = count
        })
    end
    return results
end

------------------------------------------------------------
-- Warning System (Smithing Templates)
------------------------------------------------------------

function ae.getWarnings(warningList)
    local warnings = {}

    for _, entry in ipairs(warningList) do
        local name = entry.name
        local label = entry.label or name
        local threshold = entry.threshold or 1

        local count = ae.getItemCount(name)
        if count <= threshold then
            table.insert(warnings, {
                name = name,
                label = label,
                count = count,
                threshold = threshold
            })
        end
    end

    return warnings
end

------------------------------------------------------------
-- Crafting Job Monitor
------------------------------------------------------------

function ae.getCraftingJobs()
    local cpus = me.getCraftingCPUs()
    local results = {}

    for _, cpu in ipairs(cpus) do
        if cpu.busy then
            local job = cpu.craftingJob
            if job then
                table.insert(results, {
                    name = job.output.name or "Unknown",
                    label = job.output.label or job.output.name or "Unknown",
                    amount = job.output.amount or 1,
                    progress = job.progress or 0
                })
            end
        end
    end

    return results
end

------------------------------------------------------------
-- Combined Dashboard Data
------------------------------------------------------------

function ae.getDashboardData(config)
    return {
        items = ae.getItemList(config.trackedItems),
        warnings = ae.getWarnings(config.warningItems),
        crafting = ae.getCraftingJobs()
    }
end

return ae
