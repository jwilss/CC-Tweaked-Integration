--========================================================--
--  tabs.lua  |  BAER Tab State
--========================================================--

local tabs = {}

local currentTab = 1
local storagePage = 1

function tabs.getTab()
    return currentTab
end

function tabs.getStoragePage()
    return storagePage
end

function tabs.handleKey(key)
    if key == keys.one then currentTab = 1 end
    if key == keys.two then currentTab = 2 end
    if key == keys.three then currentTab = 3 end
    if key == keys.four then currentTab = 4 end
    if key == keys.five then currentTab = 5 end

    if currentTab == 2 then
        if key == keys.left then storagePage = 1 end
        if key == keys.right then storagePage = 2 end
    end
end

function tabs.drawBar(m)
    local w = m.getSize()
    m.setCursorPos(1,1)
    m.setBackgroundColor(colors.black)
    m.setTextColor(colors.white)

    local labels = {
        "[1] POWER",
        "[2] STORAGE",
        "[3] MACHINES",
        "[4] FARMS",
        "[5] WARN"
    }

    local line = ""
    for i, label in ipairs(labels) do
        if i == currentTab then
            line = line .. "> " .. label .. "  "
        else
            line = line .. "  " .. label .. "  "
        end
    end

    if #line < w then
        line = line .. string.rep(" ", w - #line)
    end

    m.write(line:sub(1,w))
end

return tabs
