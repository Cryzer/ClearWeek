-- Jedyne miejsce rejestrujące zdarzenia gry.
local _, A = ...
local frame = CreateFrame("Frame")
local handlers = {}

function handlers.ADDON_LOADED(name)
    if name ~= A.name then return end
    frame:UnregisterEvent("ADDON_LOADED")
    A:Initialize()
end
-- Każde wejście (także do instancji) sprawdza, czy widok ma zniknąć. Start tylko raz.
local entered = false
function handlers.PLAYER_ENTERING_WORLD()
    A.View:CheckInstance()
    if entered then
        A.View:RequestRefresh()
        return
    end
    entered = true
    A.View:OnEnterWorld()
end
function handlers.PLAYER_REGEN_DISABLED() A.View:OnCombatStart() end
function handlers.PLAYER_REGEN_ENABLED() A.View:OnCombatEnd() end
function handlers.ADDON_RESTRICTION_STATE_CHANGED() A.View:OnRestrictionChanged() end
function handlers.ZONE_CHANGED_NEW_AREA() A.View:RequestRefresh() end
-- Podstrefa bez zmiany strefy, np. teleport do Astalor's Sanctum: pinezka idzie za graczem.
function handlers.ZONE_CHANGED() A.Guide.Follow() end
function handlers.ZONE_CHANGED_INDOORS() A.Guide.Follow() end
-- Znacznik wydarzenia (Curse Surge) pojawia się i znika bez zmiany questów.
function handlers.AREA_POIS_UPDATED() A.View:RequestRefresh() end
-- Harmonogram przychodzi z serwera po pierwszym zapytaniu, więc pierwsze odczytanie bywa puste.
function handlers.EVENT_SCHEDULER_UPDATE() A.View:RequestRefresh() end
-- Gracz zapisał albo zmienił układ trybu edycji (EditModeManagerDocumentation.lua): Obchód stoi
-- obok trackera, więc idzie za nim.
function handlers.EDIT_MODE_LAYOUTS_UPDATED() A.View:OnLayoutChanged() end
function handlers.QUEST_ACCEPTED() A.View:RequestRefresh() end
function handlers.QUEST_TURNED_IN() A.View:RequestRefresh() end
function handlers.QUEST_REMOVED() A.View:RequestRefresh() end
function handlers.QUEST_LOG_UPDATE() A.View:RequestRefresh() end

for event in pairs(handlers) do frame:RegisterEvent(event) end
-- Buff Trovehunter's Bounty. UNIT_AURA gracza przychodzi przy każdym procu, więc trasę liczymy
-- tylko, gdy zmieni się, które buffy pozycji gracz ma. Pierwszy odczyt to punkt odniesienia.
-- Buff pojawia się albo znika tylko przy dodaniu, usunięciu albo pełnej aktualizacji, więc samo
-- odświeżenie buffów pomijamy, jak Blizzard (EvokerEbonMightBar, gałąź live). Nieczytelne dane
-- (sekretne przy ograniczeniu buffów) sprawdzamy jak dotąd.
local function auraSetChanged(info)
    if not A.Safe.Table(info) then return true end
    if A.Safe.Field(info, "isFullUpdate") == true then return true end
    local added = A.Safe.Table(A.Safe.Field(info, "addedAuras"))
    local removed = A.Safe.Table(A.Safe.Field(info, "removedAuraInstanceIDs"))
    return (added ~= nil and #added > 0) or (removed ~= nil and #removed > 0)
end

local auras
function handlers.UNIT_AURA(_, info)
    -- W pauzie (walka, instancja, ograniczenie) Obchód stoi, a po niej przelicza wszystko.
    if A.View:IsPaused() or not auraSetChanged(info) then return end
    local now = A.Detectors.Auras()
    local changed = auras ~= nil and now ~= auras
    auras = now
    if changed then A.View:RequestRefresh() end
end
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:SetScript("OnEvent", function(_, event, ...)
    if A.failed or A.future then return end
    A:Run(handlers[event], ...)
end)
