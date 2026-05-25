print("=== ME Bridge Item Shape Scanner ===")

-- Auto-detect ME Bridge
local bridge = nil
for _, name in ipairs(peripheral.getNames()) do
    local t = peripheral.getType(name)
    if t == "meBridge" or t == "me_bridge" then
        bridge = peripheral.wrap(name)
        break
    end
end

if not bridge then
    print("ERROR: No ME Bridge found")
    return
end

print("ME Bridge detected")

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
for k, v in pairs(items) do
    count = count + 1
end

print("Entries:", count)

-- Print first 3 entries only
local printed = 0
for k, v in pairs(items) do
    printed = printed + 1
    print("\nEntry key:", k)

    if type(v) ~= "table" then
        print("Value is not a table:", v)
    else
        for field, val in pairs(v) do
            print("  field:", field, "type:", type(val))
        end
    end

    if printed >= 3 then break end
end

print("\n=== Done ===")
