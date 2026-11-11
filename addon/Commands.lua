-- Komenda /clearweek: pokazuje albo chowa Obchód, jak klik w ikonę. Innych komend nie ma (właściciel
-- 2026-11-10): reszta jest w menu ikony (UI/Menu.lua). Gdy addon stoi po błędzie albo przez
-- nowszy zapis, widoku nie ma, więc /clearweek podaje stan potrzebny do zgłoszenia błędu.
local _, A = ...
local L = A.L

local commands = {}

local function status()
    local version, build = GetBuildInfo()
    A:Print(L.DIAG_VERSION:format(A:Version(), tostring(version), tostring(build), A:Status()))
    if A.lastError then A:Print(L.DIAG_ERROR:format(A.lastError)) end
end

local GO_MESSAGES = {quest = L.GO_QUEST, offer = L.GO_OFFER, waypoint = L.GO_WAYPOINT, none = L.GO_NONE}

-- Klik w wiersz Obchodu. Komunikat pada tylko przy niepowodzeniu, bo strzałkę widać od razu.
function commands.GuideRow(row, stop, quiet)
    local how = A.Guide.Go(row)
    if how == "combat" then A:Print(L.GO_COMBAT); return end
    if quiet and how ~= "none" then return end
    local name = (how == "quest" or not row.who) and row.title or row.who
    A:Print(GO_MESSAGES[how]:format(name, stop.name))
end

SLASH_CLEARWEEK1 = "/clearweek"
SlashCmdList.CLEARWEEK = function()
    if A.failed or A.future then status(); return end
    A:Run(function() A.View:Toggle() end)
end

A.Commands = commands
