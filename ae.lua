local ae = {}

local BRIDGE = "me_bridge_1"
local bridge = peripheral.wrap(BRIDGE)

function ae.listItems()
    local raw = bridge.listItems()
    local out = {}

    for _, it in pairs(raw) do
        table.insert(out, {
            name        = it.name,
            displayName = it.displayName or it.name,
            amount      = it.amount or 0,
            tags        = it.tags or {}
        })
    end

    return out
end

return ae
