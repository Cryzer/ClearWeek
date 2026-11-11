-- Granica błędu, bezpieczne odczyty i komunikaty. Reszta addonu działa przez te funkcje.
local name, A = ...
A.name = name

-- Pierwszy błąd zatrzymuje addon do /reload: lepiej nic nie pokazać niż pokazać nieprawdę.
-- Po błędzie nic już nie biegnie, także timery i kliknięcia, a widok znika.
function A:Run(fn, ...)
    if self.failed then return false end
    local ok, result = pcall(fn, ...)
    if not ok then
        self.lastError = self.Safe.Text(result) or "?"
        self.failed = true
        self:Print(self.L.PAUSED)
        if self.View then pcall(self.View.Shutdown, self.View) end
    end
    return ok, result
end

-- Wyniki pcall bez pierwszego (ok). Przez argumenty, bez tabeli: odświeżenie listy to setki
-- odczytów.
local function results(ok, ...)
    if ok then return ... end
end

-- Wszystkie wyniki, także dalsze (GetAchievementInfo ma ich 13). Po błędzie nil.
function A:Read(namespace, method, ...)
    local fn = namespace and namespace[method]
    if type(fn) ~= "function" then return nil end
    return results(pcall(fn, ...))
end

function A:Print(text)
    print("ClearWeek: " .. text)
end

function A:Version()
    return self.Safe.Text(self:Read(C_AddOns, "GetAddOnMetadata", self.name, "Version")) or "?"
end

function A:Initialize()
    -- Konto: wygląd i harmonogram. Postać: ukryte pozycje (Store/Hidden.lua).
    local db = self.Store.Migrate(ClearWeekDB, 1)
    local char = self.Store.Migrate(ClearWeekCharDB, 1)
    -- Zapis z nowszej wersji zostaje nietknięty, a addon nie działa.
    if not (db and char) then self.future = true; return end
    ClearWeekDB, ClearWeekCharDB = db, char
    -- Pamięć oddanych zadań dziennych z 0.11, nieużywana od 0.12.0.
    char.turned = nil
    self.db, self.char = db, char
end

-- Stan, który /clearweek podaje, gdy addon stoi.
function A:Status()
    if self.failed then return self.L.STATUS_FAILED end
    if self.future then return self.L.STATUS_FUTURE end
    return "ok"
end
