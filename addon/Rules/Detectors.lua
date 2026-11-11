-- Odczyt postępu ze stanu gry. Addon niczego nie odhacza i nie zapisuje postępu.
local _, A = ...
local S = A.Safe
local Detectors = {}
A.Detectors = Detectors

local function ask(method, id)
    return S.Value(A:Read(C_QuestLog, method, id))
end

-- Dziennik czytamy zawsze, bo quest w logu to najpewniejsza informacja dla gracza.
local function readLog(info, id)
    local onQuest = ask("IsOnQuest", id)
    if onQuest == nil then info.unreadable = true end
    if not onQuest then return end
    local ready = ask("ReadyForTurnIn", id)
    if ready and not info.ready then info.ready, info.questID = true, id end
    if not info.questID then info.questID = id end
    info.active = true
end

local function readIDs(info, ids)
    for _, id in ipairs(ids) do
        local flagged = ask("IsQuestFlaggedCompleted", id)
        if flagged == nil then info.unreadable = true end
        if flagged then info.done, info.doneID = true, info.doneID or id end
        readLog(info, id)
    end
end

local kinds = {}

local function hasAura(id)
    return S.Table(A:Read(C_UnitAuras, "GetPlayerAuraBySpellID", id)) ~= nil
end

-- Buff po użyciu przedmiotu (Trovehunter's Bounty): flaga jest już ustawiona, ale skarb czeka
-- w następnym delve, więc w trakcie.
function kinds.flag(item, info)
    readIDs(info, item.ids)
    if item.aura and hasAura(item.aura) then info.done, info.active = nil, true end
end

-- Buffy pozycji. Tabela się nie zmienia, więc liczymy je raz, przy pierwszym UNIT_AURA.
local auraIDs

-- Które z buffów pozycji gracz ma teraz, jako tekst do porównania (Events.lua, UNIT_AURA).
function Detectors.Auras()
    if not auraIDs then
        auraIDs = {}
        for _, item in ipairs(A.Data.quests) do
            if item.aura then auraIDs[#auraIDs + 1] = item.aura end
        end
    end
    local present = {}
    for _, id in ipairs(auraIDs) do
        if hasAura(id) then present[#present + 1] = id end
    end
    return table.concat(present, ",")
end

function kinds.pool(item, info)
    readIDs(info, item.ids)
    if item.offer then readIDs(info, {item.offer}) end
end

-- Waluta z limitem sezonowym, który rośnie co tydzień (Nebulous Voidcore). Zrobione, gdy limit
-- jest pełny. Questy-zakupy są dzienne, więc ich flagi nie mówią nic o tygodniu.
function kinds.currency(item, info)
    for _, id in ipairs(item.ids or {}) do readLog(info, id) end
    local currency = S.Table(A:Read(C_CurrencyInfo, "GetCurrencyInfo", item.currency))
    local max = currency and S.Number(S.Field(currency, "maxQuantity"))
    local field = currency and S.Value(S.Field(currency, "useTotalEarnedForMaxQty")) and "totalEarned" or "quantity"
    local have = currency and S.Number(S.Field(currency, field))
    if not (max and have) or max <= 0 then info.unreadable = true; return end
    if have >= max then info.done = true end
end

function Detectors.Read(item)
    local info = {}
    kinds[item.kind](item, info)
    return info
end
