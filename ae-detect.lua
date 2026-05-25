print("=== ME Bridge API Diagnostic ===")

-- Auto-detect ME Bridge peripheral
local bridgeName = nil
for _, name in ipairs(peripheral.getNames()) do
    local t = peripheral.getType(name)
    if t == "meBridge" or t == "me_bridge" or t == "advancedperipherals:me_bridge" then
        bridgeName = name
        break
    end
end

if not bridgeName then
    print("ERROR: No ME Bridge found.")
    return
end

print("Found ME Bridge:", bridgeName)

local me = peripheral.wrap(bridgeName)

local function check(name)
    local fn = me[name]
    if type(fn) == "function" then
        print(name .. ": function")
    else
        print(name .. ": nil")
    end
end

print("\n=== Checking available functions ===")
check("getItem")
check("getItems")
check("listItems")
check("getCraftingCPUs")
check("getEnergy")
check("getEnergyDetails")
check("getFluids")
check("getCraftables")

print("\n=== Sample Data Test ===")

-- Try each method safely
local function try(name, call)
    print("\nTesting " .. name .. ":")
    local ok, result = pcall(call)
    if ok then
        print("Success:", result and "returned data" or "nil")
    else
        print("Error:", result)
    end
end

try("listItems()", function() return me.listItems and me.listItems() end)
try("getItems()", function() return me.getItems and me.getItems() end)
try("getItem({})", function() return me.getItem and me.getItem({}) end)

print("\n=== Done ===")
