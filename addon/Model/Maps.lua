-- Mapy i znaczniki: wspólne odczyty dla trasy, ofert i harmonogramu.
local _, A = ...
local S = A.Safe
local Maps = {}
A.Maps = Maps

-- Miasto czy budynek ma własną mapę, więc strefę gracza szukamy w górę map nadrzędnych.
local MAX_DEPTH = 10

-- Mapa gracza i jej nadrzędne, od najbliższej.
function Maps.Chain()
    local chain = {}
    local map = S.ID(A:Read(C_Map, "GetBestMapForUnit", "player"))
    while map and #chain < MAX_DEPTH do
        chain[#chain + 1] = map
        map = S.ID(S.Field(A:Read(C_Map, "GetMapInfo", map), "parentMapID"))
    end
    return chain
end

function Maps.Name(map)
    return map and S.Text(S.Field(A:Read(C_Map, "GetMapInfo", map), "name")) or nil
end

-- Czy gracz jest na jednej z tych map albo na mapie podrzędnej.
function Maps.Within(maps)
    local wanted = {}
    for _, map in ipairs(maps) do wanted[map] = true end
    for _, map in ipairs(Maps.Chain()) do
        if wanted[map] then return true end
    end
    return false
end

-- Znaczniki mapy: najpierw wydarzenia, potem zwykłe.
function Maps.POIs(map)
    local ids = {}
    for _, method in ipairs({"GetEventsForMap", "GetAreaPOIForMap"}) do
        for _, id in ipairs(S.Table(A:Read(C_AreaPoiInfo, method, map)) or {}) do
            local poi = S.ID(id)
            if poi then ids[#ids + 1] = poi end
        end
    end
    return ids
end

-- Zbiór znaczników z kilku map.
function Maps.POISet(maps)
    local set = {}
    for _, map in ipairs(maps) do
        for _, poi in ipairs(Maps.POIs(map)) do set[poi] = true end
    end
    return set
end
