-- Kategoria „quests”: wiersze z tabeli i ich stany (projekt, sekcja 5).
local _, A = ...
local S = A.Safe
local QuestSource = {}
A.QuestSource = QuestSource

-- Kolejność jest celowa: „zrobione” przed dziennikiem, bo pule flagują się razem,
-- a brak pewności nigdy nie staje się ofertą, żeby nie wysyłać do NPC bez powodu.
local function stateOf(item, condition, info)
    if condition == false then return "hidden" end
    if info.done then return "done" end
    if info.ready then return "ready" end
    if info.active then return "active" end
    if condition == nil or info.unreadable then return "unknown" end
    return "offer"
end

-- Tytuł z dziennika, potem z oferty na mapie, na końcu nazwa z tabeli.
local function titleOf(item, info, offerTitle)
    local id = info.questID
    local title = id and S.Text(A:Read(C_QuestLog, "GetTitleForQuestID", id))
    if title and title ~= "" then return title end
    if offerTitle and offerTitle ~= "" then return offerTitle end
    return item.title
end

-- Dane dla prowadzenia. ID questu jest zarazem ID jego pinu oferty na mapie.
-- Pin z puli to zgadywanie, bo ten sam quest bywa w kilku miejscach (Vaeli: Silvermoon
-- i dzielnica mieszkalna). Kiedy go użyć, decyduje Guide.
local OFFER_KINDS = {flag = true, pool = true}

local function targetOf(item, offerID, eventPOI)
    local guesses = offerID and {offerID} or (not item.offer and OFFER_KINDS[item.kind] and item.ids) or nil
    return {offers = item.offer and {item.offer}, guesses = guesses,
        worldQuest = item.worldQuest and offerID or nil,
        offerMaps = item.offerMaps, pois = eventPOI and {eventPOI} or item.pois,
        map = item.map, x = item.x, y = item.y, via = item.via}
end

-- Oferty i wydarzenia czytamy tylko dla wierszy, które je pokażą. Harmonogram gry przy
-- każdym zapytaniu może pytać serwer, a odpowiedź (EVENT_SCHEDULER_UPDATE) odświeża widok.
local OPEN = {offer = true, active = true, ready = true, unknown = true}

-- NPC questu z kilkoma NPC (givers): po pobraniu ten, który przyjmuje quest, a do wzięcia ten na mapie
-- gracza (najbliższa mapa w górę), inaczej pierwszy.
local function giverOf(item, state)
    if not item.givers then return nil end
    if state == "active" or state == "ready" then
        for _, giver in ipairs(item.givers) do
            if giver.ends then return giver end
        end
    end
    for _, map in ipairs(A.Maps.Chain()) do
        for _, giver in ipairs(item.givers) do
            if giver.map == map then return giver end
        end
    end
    return item.givers[1]
end

-- Grupa reputacji strefy, na której mapie jest wydarzenie albo zadanie (Abundance, world boss).
local function stopOn(map)
    for _, stop in ipairs(A.Data.stops) do
        if map and stop.map == map then return stop.key end
    end
end

function QuestSource.Evaluate(item)
    -- Ukryte przez gracza: bez odczytów z gry, bo wiersza i tak nie będzie.
    if A.Hidden.Is(item.key) then
        return {key = item.key, stop = item.stop, title = item.title, who = item.who, state = "hidden", byUser = true}
    end
    local info = A.Detectors.Read(item)
    local condition = A.Conditions.Check(item.when)
    local state = stateOf(item, condition, info)
    local open = OPEN[state]
    local offerID, offerTitle, offerMap, eventPOI, eventTitle, eventMap
    if open then
        offerID, offerTitle, offerMap = A.Offers.Find(item)
        eventPOI, eventTitle, eventMap = A.Offers.Event(item)
    end
    local giver = giverOf(item, state)
    local target = targetOf(item, offerID, eventPOI)
    -- Pinezka przy wybranym NPC. Pin oferty mógłby wskazać drugiego, więc bez zgadywania.
    if giver then target.map, target.x, target.y, target.guesses = giver.map, giver.x, giver.y, nil end
    -- Zrobiony world boss nie ma już zadania na mapie, więc grupę daje ID zaliczonego questu.
    local known = offerID or info.doneID
    local stop = item.stopOf and known and item.stopOf[known]
        or item.zoneStop and stopOn(eventMap or offerMap) or item.stop
    -- Bez grupy nie wiadomo, gdzie pokazać pozycję, więc jej nie ma (world boss poza zasięgiem).
    if not stop then state = "hidden" end
    return {
        -- Quest światowy nie ma NPC, więc who zostaje puste (właściciel 2026-11-08).
        -- World boss: imię z zadania mapy w miejscu NPC, tytuł z tabeli.
        key = item.key, stop = stop, bag = item.bag, who = giver and giver.who or item.whoFromOffer and offerTitle or item.who,
        title = titleOf(item, info, eventTitle or (not item.whoFromOffer and offerTitle) or nil),
        state = state,
        questID = info.questID or offerID or item.offer or (item.ids and item.ids[1]),
        target = target,
        -- Strefa do podpowiedzi: mapa punktu, inaczej mapa zadania albo wydarzenia. Tylko dla
        -- wierszy, które prowadzą do NPC.
        zone = open and A.Maps.Name(target.map or offerMap or eventMap) or nil,
        -- Wiersz wydarzenia jest tylko pod questem w trakcie (UI/Lines.lua).
        event = state == "active" and A.Schedule.Next(item) or nil,
    }
end

function QuestSource.Rows()
    local rows = {}
    A.Hidden.Expire()
    for _, item in ipairs(A.Data.quests) do rows[#rows + 1] = QuestSource.Evaluate(item) end
    return rows
end

A.Sources:Register("quests", QuestSource)
