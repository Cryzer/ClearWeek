-- Pozycje ukryte przez gracza, osobno dla postaci (ClearWeekCharDB): hidden na stałe, hiddenWeek
-- do resetu tygodnia. week to chwila resetu, po której hiddenWeek przestaje obowiązywać.
local _, A = ...
local S = A.Safe
local Hidden = {}
A.Hidden = Hidden

local function set(name)
    local char = A.char
    if not char then return nil end
    if type(char[name]) ~= "table" then char[name] = {} end
    return char[name]
end

local function now()
    return S.Number(A:Read(_G, "GetServerTime"))
end

-- Ukrycia tygodniowe gasną po resecie. Bez czytelnego czasu zostają, bo nic nie wiadomo.
function Hidden.Expire()
    local char = A.char
    if not char or type(char.hiddenWeek) ~= "table" or next(char.hiddenWeek) == nil then return end
    local week, time = S.Number(char.week), now()
    if week and not (time and time >= week) then return end
    if not (week or time) then return end
    char.hiddenWeek, char.week = {}, nil
end

-- Zwraca "always", "week" albo nil.
function Hidden.Is(key)
    local char = A.char
    if not char then return nil end
    if type(char.hidden) == "table" and char.hidden[key] then return "always" end
    if type(char.hiddenWeek) == "table" and char.hiddenWeek[key] then return "week" end
    return nil
end

local function changed()
    A.View:OnHiddenChanged()
end

-- Zwraca false, gdy nie da się ustalić resetu, bo ukrycie tygodniowe nigdy by nie zgasło.
function Hidden.Hide(key, mode)
    local always, week = set("hidden"), set("hiddenWeek")
    if not (always and week) then return false end
    if mode == "always" then
        always[key], week[key] = true, nil
    else
        local time = now()
        local left = S.Number(A:Read(C_DateAndTime, "GetSecondsUntilWeeklyReset"))
        if not (time and left) then return false end
        Hidden.Expire()
        week = set("hiddenWeek")
        week[key], always[key] = true, nil
        A.char.week = time + left
    end
    changed()
    return true
end

function Hidden.Show(key)
    local always, week = set("hidden"), set("hiddenWeek")
    if not (always and week) then return end
    always[key], week[key] = nil, nil
    changed()
end

function Hidden.ShowAll()
    if not A.char then return end
    A.char.hidden, A.char.hiddenWeek, A.char.week = {}, {}, nil
    changed()
end

-- Ukryte pozycje w kolejności tabeli: key, text (jak wiersz) i mode. Klucze spoza tabeli pomijamy.
function Hidden.List()
    Hidden.Expire()
    local list = {}
    for _, item in ipairs(A.Data.quests) do
        local mode = Hidden.Is(item.key)
        if mode then
            list[#list + 1] = {key = item.key, mode = mode,
                text = item.who and (item.who .. " · " .. item.title) or item.title}
        end
    end
    return list
end
