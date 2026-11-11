-- Oferty z zadań mapy. Tak gra pokazuje np. tygodniówkę Vaeli w housingu (mapa 2352),
-- także gdy gracz jest gdzie indziej (pomiar 2026-11-07: 95416 Going Postal z Silvermoon).
local _, A = ...
local S = A.Safe
local Offers = {}
A.Offers = Offers

-- Zwraca ID, tytuł i mapę questu z puli pozycji, który gra oferuje na jednej z jej map.
function Offers.Find(item)
    if not (item.offerMaps and item.ids) then return nil end
    local wanted = {}
    for _, id in ipairs(item.ids) do wanted[id] = true end
    for _, map in ipairs(item.offerMaps) do
        local tasks = S.Table(A:Read(C_TaskQuest, "GetQuestsOnMap", map)) or {}
        for _, task in ipairs(tasks) do
            local id = S.ID(S.Field(task, "questID"))
            if id and wanted[id] then
                return id, S.Text(A:Read(C_TaskQuest, "GetQuestInfoByQuestID", id)), map
            end
        end
    end
end

-- Kwadrat odległości znacznika od miejsca wydarzenia strefy tej mapy (eventSites), w procentach
-- mapy; do porównań wystarczy. nil, gdy mapa nie ma punktu albo pozycji nie da się odczytać.
local function siteDistance(item, map, info)
    local site = item.eventSites and item.eventSites[map]
    local position = site and S.Field(info, "position")
    local x, y = S.Number(position and S.Field(position, "x")), S.Number(position and S.Field(position, "y"))
    if not (x and y) then return nil end
    return (x * 100 - site[1]) ^ 2 + (y * 100 - site[2]) ^ 2
end

-- Wydarzenie mapy, np. bieżące Abundance. Szukamy znacznika, którego nazwa zaczyna się od
-- eventPrefix, na mapach eventMaps. Tytuł dostaje nazwę strefy z przodu, jak w Plumberze.
-- Mapa sąsiedniej strefy też zwraca znacznik (właściciel 2026-11-11: Abundance w Zul'Aman
-- było przy Silvermoon Court), więc wygrywa mapa, na której stoi najbliżej miejsca wydarzenia
-- swojej strefy. Sąsiad widzi go przy krawędzi, daleko od swojego. Bez odległości pierwsza mapa.
function Offers.Event(item)
    if not (item.eventMaps and item.eventPrefix) then return nil end
    local bestPOI, bestName, bestMap, bestDistance
    for _, map in ipairs(item.eventMaps) do
        for _, poi in ipairs(A.Maps.POIs(map)) do
            local info = A:Read(C_AreaPoiInfo, "GetAreaPOIInfo", map, poi)
            local name = S.Text(S.Field(info, "name"))
            if name and name:sub(1, #item.eventPrefix) == item.eventPrefix then
                local distance = siteDistance(item, map, info)
                if not bestPOI or (distance and (not bestDistance or distance < bestDistance)) then
                    bestPOI, bestName, bestMap, bestDistance = poi, name, map, distance
                end
            end
        end
    end
    if not bestPOI then return nil end
    local zone = A.Maps.Name(bestMap)
    return bestPOI, zone and (zone .. " " .. bestName) or bestName, bestMap
end
