-- Menu pod prawym przyciskiem: na wierszu ukrywanie pozycji, na ikonie przywracanie ukrytych,
-- miejsce i skala. Standardowe menu kontekstowe gry (Blizzard_Menu/MenuUtil.lua:151), więc bez
-- własnej ramki i bez komend.
local _, A = ...
local L = A.L
local Menu = {}
A.Menu = Menu

local SCALES = {0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4}

-- Wywołania z menu też idą przez granicę błędu.
local function run(fn, ...)
    local arguments = {...}
    return function() A:Run(fn, unpack(arguments)) end
end

local function open(owner, build)
    A.Hint.Hide()
    A:Read(MenuUtil, "CreateContextMenu", owner, function(_, root) A:Run(build, root) end)
end

-- Wiersz wydarzenia (Curse Surge) nie jest pozycją tabeli, znika razem ze swoim questem.
function Menu.CanHide(row)
    return row ~= nil and row.state ~= "event"
end

function Menu.Row(owner, row)
    if not Menu.CanHide(row) then return end
    open(owner, function(root)
        root:CreateButton(L.MENU_HIDE_WEEK, run(A.Hidden.Hide, row.key, "week"))
        root:CreateButton(L.MENU_HIDE_ALWAYS, run(A.Hidden.Hide, row.key, "always"))
    end)
end

local function addHidden(root, list, mode, title)
    local any = false
    for _, entry in ipairs(list) do
        if entry.mode == mode then
            if not any then root:CreateTitle(title) end
            any = true
            root:CreateButton(entry.text, run(A.Hidden.Show, entry.key))
        end
    end
end

function Menu.Toggle(owner)
    open(owner, function(root)
        local list = A.Hidden.List()
        if #list > 0 then
            addHidden(root, list, "week", L.MENU_HIDDEN_WEEK)
            addHidden(root, list, "always", L.MENU_HIDDEN_ALWAYS)
            root:CreateButton(L.MENU_SHOW_ALL, run(A.Hidden.ShowAll))
            root:CreateDivider()
        end
        root:CreateCheckbox(L.MENU_UNLOCK, function() return A.Place.unlocked end, run(A.Place.ToggleLock))
        local scale = root:CreateButton(L.MENU_SCALE)
        for _, value in ipairs(SCALES) do
            scale:CreateRadio(L.MENU_PERCENT:format(math.floor(value * 100 + 0.5)), function()
                return math.abs(select(3, A.Place.Get()) - value) < 0.01
            end, run(A.Place.SetScale, value))
        end
        root:CreateButton(L.MENU_RESET, run(A.Place.Reset))
    end)
end
