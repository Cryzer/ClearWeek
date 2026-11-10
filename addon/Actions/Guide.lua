-- Prowadzenie do następnego kroku. Jedyne miejsce, które zmienia strzałkę gry.
local _, A = ...
local S = A.Safe
local Guide = {}
A.Guide = Guide

local function trackQuest(id)
    A:Read(C_SuperTrack, "SetSuperTrackedQuestID", id)
    return "quest"
end

-- Gra przyjmuje pin tylko wtedy, gdy ma go na mapie, więc sprawdzamy wynik zamiast mu wierzyć.
local function trackPin(typeName, ids)
    local kind = S.Field(S.Field(Enum, "SuperTrackingMapPinType"), typeName)
    if not kind then return false end
    for _, id in ipairs(ids) do
        A:Read(C_SuperTrack, "SetSuperTrackedMapPin", kind, id)
        local gotKind, gotID = A:Read(C_SuperTrack, "GetSuperTrackedMapPin")
        if S.Number(gotKind) == kind and S.ID(gotID) == id then return true end
    end
    return false
end

local function trackOffer(ids)
    return trackPin("QuestOffer", ids) and "offer" or nil
end

-- Pin z puli zgadujemy, gdy pozycja nie ma własnego punktu albo gracz stoi na mapie, gdzie
-- pin oferty jest zmierzony (offerMaps). Gdzie indziej pin potrafi prowadzić do innego NPC.
local function guessAllowed(target)
    if not target.map then return true end
    local here = S.ID(A:Read(C_Map, "GetBestMapForUnit", "player"))
    for _, map in ipairs(target.offerMaps or {}) do
        if map == here then return true end
    end
    return false
end

-- Natywna pinezka nie ma nazwy, więc WaypointUI pokazuje „Map Pin”. Jego publiczne API
-- stawia tę samą pinezkę gry z nazwą. Sam tytuł bez współrzędnych wygląda jak pin oferty,
-- który gra podpisuje nazwą questu. Bez WaypointUI albo przy błędzie zostaje natywna.
local function namedPoint(target, name)
    local api = S.Field(_G, "WaypointUIAPI")
    local navigation = api and S.Field(api, "Navigation")
    if not navigation then return end
    local result = A:Read(navigation, "NewUserNavigation", {name = name, mapID = target.map, x = target.x, y = target.y,
        stripCoordinates = true})
    if result then return "waypoint" end
end

-- Punkt docelowy. NPC za teleportem (Astalor): poza jego podstrefą prowadzimy do teleportu (via).
local function pointOf(target)
    local via = target.via
    if via and S.Text(A:Read(_G, "GetSubZoneText")) ~= via.unless then
        return {map = target.map, x = via.x, y = via.y}
    end
    return {map = target.map, x = target.x, y = target.y}
end

-- Pinezka nadpisuje tę postawioną przez gracza, dlatego jest ostatnią możliwością.
local function trackPoint(target, name)
    if not (target.map and target.x and target.y) then return end
    local spot = pointOf(target)
    if namedPoint(spot, name) then return "waypoint", spot end
    if not S.Value(A:Read(C_Map, "CanSetUserWaypointOnMap", spot.map)) then return end
    local point = A:Read(UiMapPoint, "CreateFromCoordinates", spot.map, spot.x / 100, spot.y / 100)
    if not point then return end
    A:Read(C_Map, "SetUserWaypoint", point)
    A:Read(C_SuperTrack, "SetSuperTrackedUserWaypoint", true)
    return "waypoint", spot
end

-- Ostatnia pinezka z teleportem. Przestawiamy ją po zmianie podstrefy tylko wtedy, gdy gra nadal
-- prowadzi do niej, a nie do pinezki gracza albo questu.
local followed

local function stillOurs(spot)
    if not S.Value(A:Read(C_SuperTrack, "IsSuperTrackingUserWaypoint")) then return false end
    local point = A:Read(C_Map, "GetUserWaypoint")
    local position = point and S.Field(point, "position")
    local x, y = S.Number(position and S.Field(position, "x")), S.Number(position and S.Field(position, "y"))
    return S.ID(point and S.Field(point, "uiMapID")) == spot.map and x and y
        and math.abs(x - spot.x / 100) < 0.0005 and math.abs(y - spot.y / 100) < 0.0005 or false
end

-- Zwraca sposób prowadzenia: quest, offer, waypoint, none albo combat.
function Guide.Go(row)
    if InCombatLockdown() then return "combat" end
    followed = nil
    -- Przedmiot w torbie (Trovehunter's Bounty) nie ma miejsca na mapie.
    if row.bag then return "none" end
    local target = row.target or {}
    if (row.state == "ready" or row.state == "active") and row.questID then return trackQuest(row.questID) end
    -- Zadanie mapy (world boss) prowadzimy jak gra po kliknięciu na mapie świata
    -- (WorldQuestDataProvider.lua: SetSuperTrackedQuestID).
    if row.state == "offer" and target.worldQuest then return trackQuest(target.worldQuest) end
    if row.state == "offer" then
        local how = target.offers and trackOffer(target.offers)
        if how then return how end
        -- Znacznik miejsca (AreaPOI) przed zgadywaniem: gra przyjmuje pin oferty 89268 Lost Legends,
        -- ale go nie rysuje (pomiar 2026-11-08), a znacznik „Legends of the Haranir” widać.
        if target.pois and trackPin("AreaPOI", target.pois) then return "offer" end
        how = target.guesses and guessAllowed(target) and trackOffer(target.guesses)
        if how then return how end
    end
    -- Niepewna pozycja ze znacznikiem: miejsce jest pewne.
    -- Wydarzenie (Curse Surge): znacznik, gdy trwa, inaczej pinezka w miejscu następnego.
    if (row.state == "unknown" or row.state == "event") and target.pois and trackPin("AreaPOI", target.pois) then return "offer" end
    local how, spot = trackPoint(target, row.title)
    followed = how and target.via and {row = row, spot = spot} or nil
    return how or "none"
end

-- Zmiana podstrefy (np. teleport do Astalor's Sanctum): pinezka idzie za graczem.
function Guide.Follow()
    if not followed or InCombatLockdown() then return end
    local want = pointOf(followed.row.target)
    local spot = followed.spot
    if want.x == spot.x and want.y == spot.y then return end
    if not stillOurs(spot) then
        followed = nil
        return
    end
    Guide.Go(followed.row)
end
