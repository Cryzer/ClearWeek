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

-- Wydarzenie mapy, np. bieżące Abundance. Szukamy znacznika, którego nazwa zaczyna się od
-- eventPrefix, na mapach eventMaps. Tytuł dostaje nazwę strefy z przodu, jak w Plumberze.
function Offers.Event(item)
    if not (item.eventMaps and item.eventPrefix) then return nil end
    for _, map in ipairs(item.eventMaps) do
        for _, poi in ipairs(A.Maps.POIs(map)) do
            local name = S.Text(S.Field(A:Read(C_AreaPoiInfo, "GetAreaPOIInfo", map, poi), "name"))
            if name and name:sub(1, #item.eventPrefix) == item.eventPrefix then
                local zone = A.Maps.Name(map)
                return poi, zone and (zone .. " " .. name) or name, map
            end
        end
    end
end
