print("=== ME Bridge Mini Scan ===")

-- Find ME Bridge
local bridge
for _, name in ipairs(peripheral.getNames()) do
    local t = peripheral.getType(name)
    if t == "meBridge" or t == "me_bridge" then
        bridge = peripheral.wrap(name)
        break
    end
end

if not bridge then
    print("No ME Bridge found")
    return
end

-- Try getItems()
local ok, items = pcall(function()
    return bridge.getItems and bridge.getItems()
end)

if not ok or not items then
    print("getItems() returned nothing")
    return
end

-- Count entries
local count = 0
for _ in pairs(items) do count = count + 1 end
print("Item entries:", count)

-- Get first entry key
local firstKey
for k in pairs(items) do
    firstKey = k
    break
end

if not firstKey then
    print("No items found")
    return
end

print("First key type:", type(firstKey))

local entry = items[firstKey]
print("Entry type:", type(entry))

if type(entry) ~= "table" then
    print("Entry is not a table")
    return
end

-- Print fields in the first item
print("Fields:")
for field, val in pairs(entry) do
    print(" -", field, "(" .. type(val) .. ")")
end

print("=== End ===")
