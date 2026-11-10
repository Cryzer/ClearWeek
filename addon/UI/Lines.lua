-- Linie Obchodu: tekst, kolor i kolejność wierszy z trasy. Bez ramek i bez API questów,
-- czyta tylko wynik Route (projekt, sekcja 7). Rysuje je UI/Route.lua.
local _, A = ...
local L = A.L
local Lines = {}
A.Lines = Lines

-- Do wzięcia bez słowa: klikalność pokazuje ikona pinezki.
local VERBS = {ready = L.VIEW_TURN_IN, unknown = L.VIEW_UNKNOWN}
local ROW_COLORS = {offer = "dim", ready = "readyDim", active = "activeDim", unknown = "faint"}

local function label(row)
    local verb = VERBS[row.state]
    return (row.who and (row.who .. " · ") or "") .. (verb and (verb .. " ") or "") .. row.title
end

local function colorOf(row, colors)
    return colors[row.state] or "dim"
end

-- Pinezka znaczy „poprowadzę do NPC”. Quest w trakcie klik tylko zaznacza w trackerze, więc bez niej.
local function showPin(row)
    return row.state ~= "active" and not row.bag
end

local function remaining(stop)
    local n = 0
    for _, row in ipairs(stop.rows) do
        if row.state ~= "done" then n = n + 1 end
    end
    return n
end

local function firstUnfinished(route)
    for _, stop in ipairs(route.stops) do
        for _, row in ipairs(stop.rows) do
            if row.state ~= "done" then return row, stop end
        end
    end
end

local function resetText(seconds)
    local days, hours = math.floor(seconds / 86400), math.floor(seconds % 86400 / 3600)
    if days > 0 then return L.VIEW_RESET_DAYS:format(days, hours) end
    return L.VIEW_RESET_HOURS:format(hours)
end

-- Podsumowanie to tylko czas do resetu (właściciel: liczby zadań i miejsc są zbędne).
-- W ostatniej dobie cieplejszy kolor, bo zaległe zadania zaraz przepadną. calm: „Week clear”,
-- gdzie nic nie zostało, więc bez ostrzeżenia.
local URGENT = 86400

function Lines.Summary(calm)
    local seconds = A.Safe.Number(A:Read(C_DateAndTime, "GetSecondsUntilWeeklyReset"))
    if not seconds then return nil end
    return {text = resetText(seconds), kind = "summary", color = (not calm and seconds < URGENT) and "warn" or "dim"}
end

-- Podpowiedź po najechaniu: co zrobi klik (Actions/Guide.lua) i gdzie stoi NPC, gdy to wiadomo.
local function clickHint(row)
    if row.bag then return L.HINT_BAG end
    if row.state == "ready" then return L.HINT_TURN_IN end
    if row.state == "active" then return L.HINT_TRACK end
    local text = L.HINT_GO:format(row.who or row.title)
    return row.zone and (text .. " · " .. row.zone) or text
end

-- Prawy przycisk ukrywa pozycję (UI/Menu.lua). Wiersza wydarzenia nie da się ukryć osobno.
local function hintOf(row)
    local text = clickHint(row)
    return A.Menu.CanHide(row) and (text .. L.HINT_HIDE) or text
end

local HERE_COLORS = {offer = "white", ready = "ready", active = "active", unknown = "faint"}

local function rowLine(kind, row, stop, colors)
    return {text = label(row), kind = kind, row = row, stop = stop,
        color = colorOf(row, colors), pin = showPin(row), hint = hintOf(row)}
end

-- Osobny wiersz wydarzenia pod questem w trakcie (Curse Surge pod Turn Back the Surge).
-- Klik w quest dalej zaznacza go w trackerze, a ten wiersz stawia pin (decyzja właściciela 2026-11-08).
-- Mniejszy, bez nazwy wydarzenia przed miejscem, w odcieniu szaroniebieskiego questu w trakcie
-- (właściciel 2026-11-08: bez wcięcia, kolor inny niż quest do wzięcia).
local function eventText(event)
    if event.live then return L.VIEW_EVENT_LIVE:format(event.place) end
    if event.starting then return L.VIEW_EVENT_STARTING:format(event.place) end
    return L.VIEW_EVENT_SOON:format(event.place, math.max(1, math.ceil(event.seconds / 60)))
end

local function addRow(lines, kind, row, stop, colors)
    lines[#lines + 1] = rowLine(kind, row, stop, colors)
    local event = row.state == "active" and row.event
    if event then
        -- Poza wyspą miejsce nie jest potwierdzone, więc wiersz bez pinezki i bez kliknięcia.
        lines[#lines + 1] = {text = eventText(event), kind = "child", row = not event.blind and event or nil,
            stop = stop, color = event.live and "eventLive" or "eventSoon", pin = not event.blind, event = true,
            hint = not event.blind and hintOf(event) or nil, extra = kind == "row"}
    end
end

-- Pełna trasa: każda pozostała grupa z nazwą i wszystkimi wierszami. skip: grupy już pokazane.
local function addPlaces(lines, route, skip)
    for _, place in ipairs(route.stops) do
        if not skip[place] and remaining(place) > 0 then
            lines[#lines + 1] = {text = place.name, kind = "place", node = "stop", color = "place"}
            for _, other in ipairs(place.rows) do
                if other.state ~= "done" then addRow(lines, "row", other, place, ROW_COLORS) end
            end
        end
    end
end

-- „Tu jestem” przed „co dalej”: grupa strefy gracza z całą resztą, w tym questy w trakcie.
-- Rekomendacja z innego miejsca schodzi do linii „potem” (decyzja właściciela 2026-11-08).
-- Inne grupy tej samej strefy (Voidstorm: druga frakcja) idą zaraz pod nią i zostają po zwinięciu.
local function hereLines(route, near, open)
    local here, shown = near[1], {}
    local lines = {{text = here.name, kind = "stop", node = "current", color = "gold"}}
    for i, stop in ipairs(near) do
        shown[stop] = true
        if i > 1 then
            lines[#lines + 1] = {text = stop.name, kind = "place", node = "stop", color = "place", keep = true}
        end
        for _, row in ipairs(stop.rows) do
            if row.state ~= "done" then addRow(lines, "here", row, stop, HERE_COLORS) end
        end
    end
    if open then
        addPlaces(lines, route, shown)
    elseif route.next and not shown[route.nextStop] then
        lines[#lines + 1] = {text = L.VIEW_LATER:format(route.nextStop.name, route.next.who or route.next.title), kind = "later",
            row = route.next, stop = route.nextStop, color = "dim", pin = showPin(route.next), hint = hintOf(route.next)}
    end
    lines[#lines + 1] = Lines.Summary()
    return lines
end

-- Linie widoku z trasy. Pusta lista znaczy, że nie ma czego pokazać.
function Lines.Build(route, open)
    local near, isNear = {}, {}
    for _, stop in ipairs(route.near or {}) do
        if remaining(stop) > 0 then
            near[#near + 1] = stop
            isNear[stop] = true
        end
    end
    local readyElsewhere = route.next and route.next.state == "ready" and not isNear[route.nextStop]
    if #near > 0 and not readyElsewhere then return hereLines(route, near, open) end
    local row, stop = route.next, route.nextStop
    if not row then row, stop = firstUnfinished(route) end
    if not row then return {} end
    local lines = {
        {text = stop.name, kind = "stop", node = "current", color = "gold"},
        {text = label(row), kind = "next", row = row, stop = stop, color = HERE_COLORS[row.state] or "white",
            pin = showPin(row), hint = hintOf(row)},
    }
    if open then
        for _, other in ipairs(stop.rows) do
            if other ~= row and other.state ~= "done" then addRow(lines, "row", other, stop, HERE_COLORS) end
        end
        addPlaces(lines, route, {[stop] = true})
    end
    lines[#lines + 1] = Lines.Summary()
    return lines
end
