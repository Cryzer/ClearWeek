-- Wydarzenia z harmonogramem, np. Curse Surge. Harmonogram (C_EventScheduler) podaje tylko okno
-- czasowe, a gracze potrafią skończyć wydarzenie wcześniej. Dlatego „trwa” znaczy: znacznik jest
-- na mapie. Gdy go nie ma, liczymy czas do najbliższego startu (obserwacja właściciela 2026-11-08).
-- Znacznik na mapie ma własny numer (spot.live), inny niż wydarzenie w harmonogramie (spot.poi).
-- Poza regionem wydarzenia gra nie podaje ani harmonogramu, ani znaczników (pomiar w Silvermoon),
-- więc wtedy wyliczamy z rytmu (item.period) od startu zapamiętanego w A.db.
-- Poza wyspą sam czas, bez miejsca i pinezki: szczegóły tylko potwierdzone na wyspie
-- (właściciel 2026-11-08).
local _, A = ...
local S = A.Safe
local Schedule = {}
A.Schedule = Schedule

-- Znacznik pojawia się chwilę po starcie z harmonogramu (pomiar 2026-11-08). Przez ten czas
-- wydarzenie jest „starting”, a nie zakończone.
local STARTING = 300
-- Poza wyspą znacznika nie widać, więc „live” tylko przez pierwsze 3 minuty (właściciel 2026-11-08).
local BLIND_LIVE = 180

local function eventRow(spot, how, seconds)
    return {key = "event" .. spot.poi, who = spot.title, title = spot.title, state = "event",
        place = spot.title:match(": (.+)$") or spot.title,
        live = how == "live", starting = how == "starting", seconds = seconds,
        target = {pois = {spot.live}, map = spot.map, x = spot.x, y = spot.y}}
end

local function remember(item, start)
    if not A.db then return end
    A.db.schedule = A.db.schedule or {}
    A.db.schedule[item.key] = {start = start}
end

-- Sam czas, bez miejsca: ostatni start (last) i sekundy do następnego (wait), z harmonogramu
-- albo z rytmu od zapamiętanego startu.
local function blindRow(item, now, last, wait)
    local period = item.period
    if not (last or wait) then
        local saved = A.db and A.db.schedule and A.db.schedule[item.key]
        local start = saved and S.Number(saved.start)
        if not (start and period) then return nil end
        last = start + math.floor((now - start) / period) * period
    end
    if not last and period then last = now + wait - period end
    if not wait and period then wait = last + period - now end
    if not wait then return nil end
    local title = item.eventTitle or item.title
    return {key = "event" .. item.key, who = title, title = title, state = "event", place = title,
        live = last ~= nil and now - last < BLIND_LIVE, seconds = wait, blind = true}
end

-- Zwraca wiersz wydarzenia: trwające, właśnie startujące albo najbliższe. Nil, gdy nic nie wiadomo.
function Schedule.Next(item)
    if not item.schedule then return nil end
    local spots = {}
    for _, spot in ipairs(item.schedule) do spots[spot.poi] = spot end
    local shown = A.Maps.POISet(item.scheduleMaps or {})
    for _, spot in ipairs(item.schedule) do
        if shown[spot.live] then return eventRow(spot, "live") end
    end
    local now = S.Number(A:Read(_G, "GetServerTime"))
    if not now then return nil end
    -- Znaczniki wyspy widać tylko na niej. Poza nią brak znacznika nic nie mówi.
    local blind = not A.Maps.Within(item.scheduleMaps or {})
    local best, wait, last, known
    for _, event in ipairs(S.Table(A:Read(C_EventScheduler, "GetScheduledEvents")) or {}) do
        local poi = S.ID(S.Field(event, "areaPoiID")) or 0
        local spot = spots[poi]
        local start = S.Number(S.Field(event, "startTime"))
        if spot and start then
            if not known then
                known = true
                remember(item, start)
            end
            if start <= now then
                if not last or start > last then last = start end
                if not blind and now - start < STARTING then return eventRow(spot, "starting") end
            elseif not wait or start - now < wait then
                best, wait = spot, start - now
            end
        end
    end
    if blind or not known then return blindRow(item, now, last, wait) end
    return best and eventRow(best, "next", wait)
end
