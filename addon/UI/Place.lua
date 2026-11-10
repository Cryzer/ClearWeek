-- Miejsce i skala Obchodu. Zapis w ClearWeekDB.view (konto): x, y w pikselach ekranu od prawego
-- górnego rogu, w i h to rozmiar ekranu z chwili zapisu (po zmianie rozdzielczości miejsce
-- przelicza się proporcjonalnie) i scale. Bez zapisu Obchód staje obok trackera zadań, po stronie środka ekranu,
-- a gdy trackera nie da się odczytać, obowiązuje układ z Theme. Przesuwa się ikoną po odblokowaniu w menu.
local _, A = ...
local S = A.Safe
local T = A.Theme
local Place = {unlocked = false}
A.Place = Place

Place.MIN_SCALE, Place.MAX_SCALE = 0.8, 1.4
-- Tyle pikseli od lewej i dolnej krawędzi ekranu zostaje, żeby dało się złapać przycisk.
local KEEP = 60

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

-- Zapis mógł zostać zepsuty ręcznie, więc liczy się tylko skończona liczba.
local function number(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return nil end
    return value
end

local function saved()
    local view = A.db and A.db.view
    return type(view) == "table" and view or {}
end

local function store(key, value)
    if not A.db then return end
    if type(A.db.view) ~= "table" then A.db.view = {} end
    A.db.view[key] = value
end

-- Skala, przy której jednostka ramki to jeden piksel ekranu, niezależnie od skali UI.
local function pixelScale()
    local _, height = A:Read(_G, "GetPhysicalScreenSize")
    local parent = S.Number(A:Read(UIParent, "GetEffectiveScale", UIParent))
    height = S.Number(height)
    if not (height and height > 0 and parent and parent > 0) then return 1 end
    return 768 / height / parent
end

local function screen()
    local width, height = A:Read(_G, "GetPhysicalScreenSize")
    width, height = S.Number(width), S.Number(height)
    if width and height and width > KEEP and height > KEEP then return width, height end
end

local function onScreen(x, y)
    local width, height = screen()
    if not width then return x, y end
    return clamp(x, KEEP - width, 0), clamp(y, KEEP - height, 0)
end

-- Tracker zadań ---------------------------------------------------------------
-- Tylko odczyt krawędzi ramki ObjectiveTrackerFrame (Blizzard_ObjectiveTracker.xml:3). Niczego
-- w niej nie zmieniamy i nie kotwiczymy się do niej: miejsce dalej liczymy względem UIParent.
-- Schowana ramka może nie mieć krawędzi, więc zostaje ostatni udany odczyt z tej sesji.
local lastRect

local function edge(frame, method)
    return number(S.Number(A:Read(frame, method, frame)))
end

-- Krawędzie w pikselach od prawego górnego rogu ekranu. mirrored: tracker na lewej połowie.
local function trackerRect()
    local frame = _G.ObjectiveTrackerFrame
    local width, height = screen()
    if type(frame) ~= "table" or not width then return lastRect end
    local scale = edge(frame, "GetEffectiveScale")
    local left, right, top = edge(frame, "GetLeft"), edge(frame, "GetRight"), edge(frame, "GetTop")
    if not (scale and scale > 0 and left and right and top and right > left) then return lastRect end
    -- Współrzędne ramek razy skala dają ekran o wysokości 768, jak w pixelScale.
    local k = scale * height / 768
    lastRect = {left = left * k - width, right = right * k - width, top = top * k - height,
        mirrored = (left + right) * k / 2 < width / 2}
    return lastRect
end

-- Domyślne miejsce: obok trackera po stronie środka ekranu, a bez trackera układ z Theme.
local function default(rect)
    if not rect then return T.right, T.top end
    local x = rect.mirrored and rect.right + T.trackerGap or rect.left - T.trackerGap
    return x, rect.top - T.trackerDrop
end

-- Róg Obchodu przy linii trasy w pikselach od prawego górnego rogu ekranu, skala i strona.
-- mirrored: linia trasy jest przy lewej krawędzi, a tekst idzie w prawo. Przy miejscu domyślnym
-- decyduje strona trackera, a przy ustawionym przez gracza połowa ekranu, na której stoi róg
-- (właściciel 2026-11-10).
function Place.Get()
    local view = saved()
    local rect = trackerRect()
    local defaultX, defaultY = default(rect)
    local manual = number(view.x) ~= nil
    local x, y = number(view.x) or defaultX, number(view.y) or defaultY
    -- Zapis z innej rozdzielczości: to samo miejsce w proporcji do ekranu. Stary zapis nie ma
    -- rozmiaru, więc zostaje w pikselach.
    local width, height = screen()
    local oldWidth, oldHeight = number(view.w), number(view.h)
    if manual and width and oldWidth and oldHeight and oldWidth > 0 and oldHeight > 0 then
        x, y = x * width / oldWidth, y * height / oldHeight
    end
    x, y = onScreen(x, y)
    local mirrored = rect and rect.mirrored or false
    if manual then mirrored = width ~= nil and x < -width / 2 end
    return x, y, clamp(number(view.scale) or 1, Place.MIN_SCALE, Place.MAX_SCALE), mirrored
end

-- Odstępy SetPoint są w jednostkach ramki, czyli w pikselach podzielonych przez skalę gracza.
function Place.Apply()
    local view = A.View
    local x, y, scale, mirrored = Place.Get()
    local base = pixelScale() * scale
    view.mirrored = mirrored
    if view.frame then
        view.frame:SetScale(base)
        view.frame:ClearAllPoints()
        view.frame:SetPoint(mirrored and "TOPLEFT" or "TOPRIGHT", UIParent, "TOPRIGHT", x / scale, y / scale)
    end
    local toggle = view.toggle
    if toggle then
        toggle:SetScale(base)
        toggle:ClearAllPoints()
        local aside = T.toggleRight - T.right
        toggle:SetPoint("CENTER", UIParent, "TOPRIGHT", x / scale + (mirrored and -aside or aside),
            y / scale + T.toggleTop - T.top)
        if Place.unlocked then toggle:RegisterForDrag("LeftButton") else toggle:RegisterForDrag() end
        toggle:SetAlpha(Place.RestAlpha())
    end
    -- Strona zmienia się też w trakcie przeciągania, więc widok przestawia się od razu.
    if view.frame and view.side ~= mirrored then view:OnSideChanged() end
end

-- Odblokowany przycisk jest pełny, żeby było widać, że da się go złapać.
function Place.RestAlpha()
    return Place.unlocked and 1 or T.toggleRest
end

function Place.SetScale(value)
    store("scale", clamp(value, Place.MIN_SCALE, Place.MAX_SCALE))
    Place.Apply()
    return select(3, Place.Get())
end

function Place.Reset()
    for _, key in ipairs({"x", "y", "w", "h"}) do store(key, nil) end
    Place.Apply()
end

-- Przeciąganie -----------------------------------------------------------------
-- Kursor czytamy sami zamiast StartMoving, bo przesuwają się dwie ramki naraz, a miejsce
-- ma zostać względem UIParent (projekt: bez kotwiczenia do czegokolwiek innego).
local drag

local function cursor()
    local x, y = A:Read(_G, "GetCursorPosition")
    return S.Number(x), S.Number(y)
end

local function follow()
    if not drag then return end
    local x, y = cursor()
    local effective = S.Number(A:Read(drag.toggle, "GetEffectiveScale", drag.toggle))
    if not (x and y and effective and effective > 0) then return end
    local _, _, scale = Place.Get()
    local newX, newY = onScreen(drag.x + (x - drag.cx) / effective * scale, drag.y + (y - drag.cy) / effective * scale)
    local width, height = screen()
    store("x", newX)
    store("y", newY)
    store("w", width)
    store("h", height)
    Place.Apply()
end

function Place.StopDrag()
    if not drag then return end
    local toggle = drag.toggle
    follow()
    drag = nil
    toggle:SetScript("OnUpdate", nil)
end

local function startDrag(toggle)
    if not Place.unlocked or InCombatLockdown() then return end
    local cx, cy = cursor()
    if not (cx and cy) then return end
    local x, y = Place.Get()
    drag = {toggle = toggle, cx = cx, cy = cy, x = x, y = y}
    A.Hint.Hide()
    toggle:SetScript("OnUpdate", function() A:Run(follow) end)
end

function Place.Attach(toggle)
    toggle:SetScript("OnDragStart", function(self) A:Run(startDrag, self) end)
    toggle:SetScript("OnDragStop", function() A:Run(Place.StopDrag) end)
end

-- Zwraca nowy stan: true, gdy przycisk da się przeciągać.
function Place.ToggleLock()
    Place.StopDrag()
    Place.unlocked = not Place.unlocked
    Place.Apply()
    return Place.unlocked
end
