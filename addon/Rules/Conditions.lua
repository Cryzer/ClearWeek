-- Warunki pozycji: true, false albo nil, gdy gra nie dała czytelnej odpowiedzi.
local _, A = ...
local S = A.Safe
local Conditions = {}
A.Conditions = Conditions

local function atLeast(value, needed)
    if value == nil then return nil end
    return value >= needed
end

local checks = {}

function checks.level(needed)
    return atLeast(S.Number(A:Read(_G, "UnitLevel", "player")), needed)
end

function checks.faction(needed)
    local faction = S.Text(A:Read(_G, "UnitFactionGroup", "player"))
    if faction == nil then return nil end
    return faction == needed
end

function checks.renown(needed)
    return atLeast(S.Number(A:Read(C_MajorFactions, "GetCurrentRenownLevel", needed[1])), needed[2])
end

function checks.questDone(id)
    return S.Value(A:Read(C_QuestLog, "IsQuestFlaggedCompleted", id))
end

-- Pozycja znika po osiągnięciu, np. Research Console po „Staring Into The Void”. Bierzemy
-- wasEarnedByMe (13. wynik, AchievementDisplayFrame.lua:75), bo postęp może być per postać [X].
function checks.noAchievement(id)
    local values = {A:Read(_G, "GetAchievementInfo", id)}
    local mine = S.Value(values[13])
    if mine == nil then return nil end
    return not mine
end

-- Niespełniony warunek wygrywa z nieczytelnym: pozycja i tak nie dotyczy tej postaci.
function Conditions.Check(when)
    local result = true
    for name, needed in pairs(when or {}) do
        local passed = checks[name](needed)
        if passed == false then return false end
        if passed == nil then result = nil end
    end
    return result
end
