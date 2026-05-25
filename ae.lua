local ae = {}

local BRIDGE = "me_bridge_1"
local bridge = peripheral.wrap(BRIDGE)
if not bridge then error("No ME Bridge '" .. BRIDGE .. "' found") end

function ae.listItems()
    local raw = bridge.getItems()
    local out = {}

    for _, it in pairs(raw) do
        local id = it.name
        if not id and it.fingerprint and it.fingerprint.id then
            id = it.fingerprint.id
        end
        id = id or "unknown"

        table.insert(out, {
            id          = id,
            displayName = it.displayName or id,
            amount      = it.amount or it.count or 0
        })
    end

    return out
end


return ae
