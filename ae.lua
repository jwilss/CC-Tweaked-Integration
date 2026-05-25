--========================================================--
--  ae.lua  |  Universal AE2 Module (getItems compatible)
--========================================================--

local ae = {}

------------------------------------------------------------
-- Locate ME Bridge (supports all naming variants)
------------------------------------------------------------
local function findMEBridge()
    for _, name in ipairs(peripheral.getNames()) do
        local t = peripheral.getType(name)
        if t == "meBridge"
        or t == "me_bridge"
        or t == "advancedperipherals:me_bridge"
        or t == "advancedperipherals:mebridge" then
            return peripheral.wrap(name)
        end
    end
    error("ERROR: No ME Bridge found.")
end

local me = findMEBridge()

------------------------------------------------------------
-- Detect which item API is available
------------------------------------------------------------
local HAS_GET_ITEMS   = type(me.getItems)   == "function"
local HAS_LIST_ITEMS  = type(me.listItems)  == "function"
local HAS_GET_ITEM    = type(me.getItem)    == "function"

------------------------------------------------------------
-- Internal: fetch all items from ME system
------------------------------------------------------------
local function fetchAllItems()
    if HAS_GET_ITEMS then
        return me.getItems() or {}
    elseif HAS_LIST_ITEMS then
        return me.listItems() or {}
    else
        return {}
    end
end

------------------------------------------------------------
-- Get count of a single item
------------------------------------------------------------
function ae.getItemCount(name)
    -- Fast path: getItems()
    if HAS_GET_ITEMS then
        local all = me.getItems()
        if not all then return 0 end

        for _, item in pairs(all) do
            if item.name == name then
                return item.amount or 0
            end
        end

        return 0
    end

    -- Fallback: listItems()
    if HAS_LIST_ITEMS then
        local all = me.listItems()
        if not all then return 0 end

        for _, item in pairs(all) do
            if item.name == name then
                return item.amount or 0
            end
        end

        return 0
    end

    -- Last resort: getItem()
    if HAS_GET_ITEM then
        local item = me.getItem({ name = name })
        return (item and item.amount) or 0
    end

    return 0
end

------------------------------------------------------------
-- Build tracked item list
------------------------------------------------------------
function ae.getItemList(list)
    local results = {}
    for _, entry in ipairs(list) do
        table.insert(results, {
            name  = entry.name,
            label
