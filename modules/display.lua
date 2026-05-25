-- ============================================================
--  modules/display.lua  –  Advanced Monitor renderer
-- ============================================================
--  Sections (top to bottom):
--    HEADER       – title + clock
--    ENERGY       – total bar, flow rate, per-cell rows
--    STORAGE      – item types/total, watched items, fluids
--    MACHINES     – active/idle/offline, progress bars
--    MAGIC        – Botania mana pools, Astral starlight
--    CRAFTING     – live autocrafting jobs + keep-stocked needs
--    ALERTS       – colour-coded alert ticker
-- ============================================================

local Config = require("config.settings")
local Utils  = require("modules.utils")
local Alerts = require("modules.alerts")

local Display = {}
local C = Config.colors

-- ── Monitor init ─────────────────────────────────────────────
function Display.init(side, scale)
    local m = Utils.safewrap(side)
    if not m then
        local found = Utils.getPeripheral("monitor")
        if found then m = found.wrapped end
    end
    if not m then return nil end
    m.setTextScale(scale or 0.5)
    m.setBackgroundColor(C.bg)
    m.clear()
    return m
end

-- ── Low-level primitives ─────────────────────────────────────
local function mw(m) local x,_ = m.getSize() return x end
local function mh(m) local _,y = m.getSize() return y end

local function fill(m, row, bg)
    m.setBackgroundColor(bg or C.bg)
    m.setTextColor(C.dim)
    m.setCursorPos(1, row)
    m.write(string.rep(" ", mw(m)))
end

local function put(m, col, row, text, fg, bg)
    m.setBackgroundColor(bg or C.bg)
    m.setTextColor(fg or C.value)
    m.setCursorPos(col, row)
    m.write(text)
end

local function divider(m, row)
    fill(m, row, C.bg)
    put(m, 1, row, string.rep("\140", mw(m)), C.dim, C.bg)
end

-- Colour-coded percentage helper
local function pctFg(pct)
    if pct > 0.5 then return C.good
    elseif pct > 0.15 then return C.warn
    else return C.bad end
end

-- Coloured bar: returns two strings (filled part, empty part)
-- Call them separately with different text colours.
local BAR_FULL  = "\x7f"   -- solid block in CC font
local BAR_EMPTY = "."

local function barParts(pct, width)
    pct = math.max(0, math.min(1, pct))
    local n = math.floor(pct * width + 0.5)
    return string.rep(BAR_FULL, n), string.rep(BAR_EMPTY, width - n)
end

-- Draw a coloured progress bar at (col, row) of given width
local function drawBar(m, col, row, pct, width, fg, bgFg)
    fg   = fg   or pctFg(pct)
    bgFg = bgFg or C.dim
    local full, empty = barParts(pct, width)
    put(m, col,         row, full,  fg,   C.bg)
    put(m, col+#full,   row, empty, bgFg, C.bg)
end

-- ── Section renderers ────────────────────────────────────────

local function drawHeader(m, row)
    fill(m, row, C.header)
    put(m, 1,            row, "  ATM10 SYSTEM MONITOR", C.headerText, C.header)
    local t = " " .. textutils.formatTime(os.time(), true) .. " "
    put(m, mw(m)-#t+1,   row, t,                          C.headerText, C.header)
    return row + 1
end

-- ── Energy ───────────────────────────────────────────────────
local function drawEnergy(m, row, data)
    local e = data.energy
    put(m, 1, row, "[ ENERGY ]", C.sectionTitle)
    row = row + 1

    if not e.available then
        put(m, 1, row, "  No energy peripherals found", C.dim)
        return row + 1
    end

    -- Total bar
    local pct = e.totalPct
    drawBar(m, 3, row, pct, 14, pctFg(pct), C.dim)
    put(m, 18, row, string.format("%5.1f%%", pct*100), pctFg(pct))
    row = row + 1

    -- Stored / Capacity
    put(m, 1, row,
        string.format("  %s / %s %s",
            Utils.fmtNum(e.totalEnergy),
            Utils.fmtNum(e.totalMax),
            e.unit),
        C.dim)
    row = row + 1

    -- Net flow
    local flow = e.flowFE or 0
    local flowStr, flowFg
    if math.abs(flow) < 50 then
        flowStr = "  ~ stable"
        flowFg  = C.dim
    elseif flow > 0 then
        flowStr = string.format("  +%s %s/s", Utils.fmtNum(flow), e.unit)
        flowFg  = C.good
    else
        flowStr = string.format("  -%s %s/s", Utils.fmtNum(math.abs(flow)), e.unit)
        flowFg  = C.bad
    end
    -- Time to full/empty annotation
    if e.tte then
        local mins = math.floor(e.tte / 60)
        local secs = math.floor(e.tte % 60)
        flowStr = flowStr .. string.format("  (%dm%02ds)", mins, secs)
    end
    put(m, 1, row, flowStr, flowFg)
    row = row + 1

    -- Per-cell compact rows
    for _, cell in ipairs(e.cells) do
        local lbl = string.format("  %-7s", cell.side:sub(1,7))
        put(m, 1, row, lbl, C.dim)
        drawBar(m, 10, row, cell.pct, 8, pctFg(cell.pct), C.dim)
        put(m, 19, row, string.format("%5.1f%%", cell.pct*100), pctFg(cell.pct))
        row = row + 1
    end

    return row
end

-- ── Storage ──────────────────────────────────────────────────
local function drawStorage(m, row, data)
    local s = data.storage
    put(m, 1, row, "[ STORAGE ]", C.sectionTitle)
    row = row + 1

    if not s.available then
        put(m, 1, row, "  No RS/AE2 bridge found", C.dim)
        return row + 1
    end

    put(m, 1, row,
        string.format("  Types: %s   Items: %s",
            Utils.fmtNum(s.totalTypes),
            Utils.fmtNum(s.totalItems)),
        C.dim)
    row = row + 1

    -- Watched items (2-column layout if monitor wide enough)
    local w = mw(m)
    local colW = math.floor(w / 2)
    local col  = 0
    local baseRow = row

    for name, qty in pairs(s.watchedItems) do
        local cx = 1 + col * colW
        local fg = qty < Config.storage.lowStockThreshold and C.bad or C.good
        local short = string.format("  %-12s", name:sub(1,12))
        local qstr  = string.format("%6s", Utils.fmtNum(qty))
        put(m, cx,            row, short, C.dim)
        put(m, cx+#short,     row, qstr,  fg)
        col = col + 1
        if col >= 2 then
            col = 0
            row = row + 1
        end
    end
    if col > 0 then row = row + 1 end

    -- Fluids (first 4, compact)
    if #s.fluid > 0 then
        put(m, 1, row, "  Fluids:", C.dim)
        row = row + 1
        for i = 1, math.min(4, #s.fluid) do
            local f = s.fluid[i]
            put(m, 1, row,
                string.format("    %-10s %s mB",
                    f.name:sub(1,10), Utils.fmtNum(f.amount)),
                C.value)
            row = row + 1
        end
    end

    return row
end

-- ── Machines ─────────────────────────────────────────────────
local function drawMachines(m, row, data)
    put(m, 1, row, "[ MACHINES ]", C.sectionTitle)
    row = row + 1

    if #data.machines == 0 then
        put(m, 1, row, "  None configured", C.dim)
        return row + 1
    end

    -- Two-column layout
    local colW = math.floor(mw(m) / 2)
    local col  = 0

    for _, mch in ipairs(data.machines) do
        local cx = 1 + col * colW
        local fg = mch.active and C.good
                   or (mch.status == "OFFLINE" and C.bad or C.warn)
        local icon = mch.active and "\4" or (mch.status == "OFFLINE" and "!" or "-")
        put(m, cx, row, string.format(" %s %-" .. (colW-4) .. "s", icon, mch.label:sub(1,colW-4)), fg)
        col = col + 1

        if col >= 2 then
            col = 0
            row = row + 1
            -- Draw progress bars on next line for active machines
            -- (only if there's something to show)
            local leftMch  = data.machines[math.ceil(#data.machines/2) - 1]   -- approximate
            local showProg = false
            for _, mm in ipairs(data.machines) do
                if mm.progress then showProg = true break end
            end
            if showProg then
                -- progress bars drawn inline in next pass – skipped here for column sync
            end
        end
    end
    if col > 0 then row = row + 1 end

    -- Separate pass: progress bars for active machines with progress
    for _, mch in ipairs(data.machines) do
        if mch.progress and mch.active then
            local pct = mch.progress / 100
            put(m, 1, row, string.format("  %-10s", mch.label:sub(1,10)), C.dim)
            drawBar(m, 14, row, pct, 8, C.good, C.dim)
            put(m, 23, row, string.format("%3d%%", math.floor(pct*100)), C.good)
            row = row + 1
        end
    end

    return row
end

-- ── Magic ────────────────────────────────────────────────────
local function drawMagic(m, row, data)
    local mg = data.magic
    if not mg then return row end

    local hasBot = mg.botania and mg.botania.available
    local hasAst = mg.astral  and mg.astral.available
    if not hasBot and not hasAst then return row end

    put(m, 1, row, "[ MAGIC ]", C.sectionTitle)
    row = row + 1

    -- Botania mana
    if hasBot then
        local bot = mg.botania
        put(m, 1, row, "  Mana  ", C.mana or colors.blue)
        drawBar(m, 10, row, bot.totalPct, 10, C.mana or colors.blue, C.dim)
        put(m, 21, row, string.format("%5.1f%%", bot.totalPct*100), C.mana or colors.blue)
        row = row + 1
        for _, pool in ipairs(bot.pools) do
            put(m, 1, row,
                string.format("    %-6s %s/%s",
                    pool.side:sub(1,6),
                    Utils.fmtNum(pool.mana),
                    Utils.fmtNum(pool.maxMana)),
                C.dim)
            row = row + 1
        end
    end

    -- Astral Sorcery starlight
    if hasAst then
        local ast = mg.astral
        local slFg = C.starlight or colors.lightBlue
        put(m, 1, row, "  \x2a Star  ", slFg)
        drawBar(m, 10, row, ast.totalPct, 10, slFg, C.dim)
        put(m, 21, row, string.format("%5.1f%%", ast.totalPct*100), slFg)
        row = row + 1
        for _, altar in ipairs(ast.altars) do
            put(m, 1, row,
                string.format("    %-6s %s/%s",
                    altar.side:sub(1,6),
                    Utils.fmtNum(altar.light),
                    Utils.fmtNum(altar.maxLight)),
                C.dim)
            row = row + 1
        end
    end

    return row
end

-- ── Crafting queue ───────────────────────────────────────────
local function drawCrafting(m, row, data)
    local cr = data.crafting
    if not cr then return row end

    put(m, 1, row, "[ CRAFTING ]", C.sectionTitle)
    row = row + 1

    if not cr.available then
        put(m, 1, row, "  No storage bridge", C.dim)
        return row + 1
    end

    -- Live autocrafting jobs
    if cr.totalJobs > 0 then
        put(m, 1, row, string.format("  %d job%s active:",
            cr.totalJobs, cr.totalJobs == 1 and "" or "s"), C.good)
        row = row + 1
        for i = 1, math.min(4, #cr.liveJobs) do
            local job = cr.liveJobs[i]
            local pct = job.progress and (job.progress / 100) or nil
            local lbl = string.format("  \187 %-12s x%s",
                job.name:sub(1,12), Utils.fmtNum(job.amount))
            put(m, 1, row, lbl, C.value)
            if pct then
                drawBar(m, 30, row, pct, 6, C.good, C.dim)
            end
            row = row + 1
        end
        if #cr.liveJobs > 4 then
            put(m, 1, row, string.format("  ... +%d more", #cr.liveJobs - 4), C.dim)
            row = row + 1
        end
    else
        put(m, 1, row, "  No active jobs", C.dim)
        row = row + 1
    end

    -- Keep-stocked needs
    if #cr.needed > 0 then
        put(m, 1, row, "  Needs crafting:", C.warn)
        row = row + 1
        for i = 1, math.min(5, #cr.needed) do
            local n = cr.needed[i]
            put(m, 1, row,
                string.format("  \149 %-12s have %s, need %s",
                    n.name:sub(1,12),
                    Utils.fmtNum(n.have),
                    Utils.fmtNum(n.target)),
                n.have == 0 and C.bad or C.warn)
            row = row + 1
        end
    end

    return row
end

-- ── Alerts ───────────────────────────────────────────────────
local function drawAlerts(m, row, alerts)
    if row > mh(m) then return end

    if #alerts == 0 then
        put(m, 1, row, "  \2 All systems nominal", C.good)
        return
    end

    put(m, 1, row, "[ ALERTS ]", C.bad)
    row = row + 1

    local maxRows = mh(m) - row + 1
    for i = 1, math.min(#alerts, maxRows) do
        local a = alerts[i]
        local fg = a.level == "crit" and C.bad or C.warn
        put(m, 1, row, ("  \149 " .. a.msg):sub(1, mw(m)), fg)
        row = row + 1
    end
end

-- ── Main render ──────────────────────────────────────────────
function Display.render(m, data, alerts)
    m.setBackgroundColor(C.bg)
    m.clear()

    if Alerts.hasCritical() and Config.alerts.flashOnAlert then
        -- Flash monitor border by briefly inverting; harmless if unsupported
        pcall(function() m.setBackgroundColor(colors.red) end)
        sleep(0.05)
        pcall(function() m.setBackgroundColor(C.bg) end)
    end

    local row = 1
    row = drawHeader(m, row)
    divider(m, row) ; row = row + 1
    row = drawEnergy(m, row, data)
    divider(m, row) ; row = row + 1
    row = drawStorage(m, row, data)
    divider(m, row) ; row = row + 1
    row = drawMachines(m, row, data)

    -- Only draw magic section if something is detected
    local mg = data.magic
    if mg and (mg.botania.available or mg.astral.available) then
        divider(m, row) ; row = row + 1
        row = drawMagic(m, row, data)
    end

    divider(m, row) ; row = row + 1
    row = drawCrafting(m, row, data)
    divider(m, row) ; row = row + 1
    drawAlerts(m, row, alerts)
end

function Display.renderError(m, err)
    m.setBackgroundColor(C.bg)
    m.clear()
    fill(m, 1, colors.red)
    put(m, 1, 1, " ! ERROR", colors.white, colors.red)
    local row = 2
    for line in tostring(err):gmatch("[^\n]+") do
        put(m, 1, row, line:sub(1, mw(m)), colors.red)
        row = row + 1
        if row > mh(m) then break end
    end
end

return Display
