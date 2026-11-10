-- Widok Obchodu: bieżące miejsce, następny krok i podsumowanie, po najechaniu cała trasa.
-- Czyta tylko wynik Route, nigdy API questów (projekt, sekcja 7).
local _, A = ...
local L = A.L
local T = A.Theme
local S = A.Safe
local View = {buttons = {}, open = false}
-- Linie z trasy buduje UI/Lines.lua. Tu zostaje rysowanie, animacje i stan widoku.
A.View = View
View.Lines = A.Lines.Build

local LOGIN_DELAY = 5
local LOGIN_OPEN = 12
local HOVER_OPEN = 0.15
local HOVER_CLOSE = 1
local REFRESH_DELAY = 0.5
local TICK = 60  -- odliczanie minut przy wydarzeniu
local RESET_MARGIN = 60

-- Ramki ---------------------------------------------------------------------
-- Skalę i miejsce ramek ustawia UI/Place.lua.

-- Tło ---------------------------------------------------------------------
-- Tekstura ma tylko liniowy gradient w jednym kierunku, więc miękkie brzegi składamy z pasków:
-- każdy pasek ma własną jasność, a w poziomie trzy odcinki (wygaszanie, pełny, wygaszanie).

local function smooth(t) return t * t * (3 - 2 * t) end

function View.ShadeRows()
    local rows, steps = {}, math.floor(T.fadeY / T.fadeStep)
    for i = 1, steps do
        rows[#rows + 1] = {edge = "top", offset = (i - 1) * T.fadeStep, height = T.fadeStep,
            alpha = T.shadeAlpha * smooth((i - 0.5) / steps)}
    end
    rows[#rows + 1] = {edge = "middle", offset = T.fadeY, alpha = T.shadeAlpha}
    for i = steps, 1, -1 do
        rows[#rows + 1] = {edge = "bottom", offset = (i - 1) * T.fadeStep, height = T.fadeStep,
            alpha = T.shadeAlpha * smooth((i - 0.5) / steps)}
    end
    return rows
end

-- Krawędź przy linii trasy i znak odstępu od niej: prawa, a przy trackerze po lewej lewa.
local function side()
    if View.mirrored then return "LEFT", "RIGHT", 1 end
    return "RIGHT", "LEFT", -1
end

-- Odcinki liczone od krawędzi przy linii trasy, więc tło nadąża za zmianą szerokości ramki.
function View.ShadeSegments()
    return {
        {fromRight = T.fadeRight + T.fadeSolid, from = 0, to = 1},
        {fromRight = T.fadeRight, width = T.fadeSolid, from = 1, to = 1},
        {fromRight = 0, width = T.fadeRight, from = 1, to = 0},
    }
end

local function shadeTexture(frame, row, segment)
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    if segment.width then texture:SetWidth(segment.width) end
    if row.height then texture:SetHeight(row.height) end
    texture:SetColorTexture(1, 1, 1, 1)
    return {texture = texture, row = row, segment = segment}
end

local function createShade(frame)
    View.shade = {}
    for _, row in ipairs(View.ShadeRows()) do
        for _, segment in ipairs(View.ShadeSegments()) do
            View.shade[#View.shade + 1] = shadeTexture(frame, row, segment)
        end
    end
end

-- Tło przypięte do krawędzi przy linii trasy. Po zmianie strony gradient też się odwraca.
local function placeShade()
    local near, far, sign = side()
    local c = T.colors.shade
    for _, piece in ipairs(View.shade) do
        local texture, row, segment = piece.texture, piece.row, piece.segment
        local edges = row.edge == "top" and {"TOP"} or row.edge == "bottom" and {"BOTTOM"} or {"TOP", "BOTTOM"}
        texture:ClearAllPoints()
        for _, edge in ipairs(edges) do
            local y = edge == "TOP" and -row.offset or row.offset
            texture:SetPoint(edge .. near, View.frame, edge .. near, sign * segment.fromRight, y)
            if not segment.width then texture:SetPoint(edge .. far, View.frame, edge .. far, 0, y) end
        end
        local from, to = segment.from, segment.to
        if View.mirrored then from, to = to, from end
        texture:SetGradient("HORIZONTAL", CreateColor(c[1], c[2], c[3], row.alpha * from),
            CreateColor(c[1], c[2], c[3], row.alpha * to))
    end
end

local function circle(frame, size, color, layer)
    local dot = frame:CreateTexture(nil, "ARTWORK", nil, layer)
    dot:SetSize(size, size)
    -- Maska na kolorowej teksturze dała w grze kwadraty, więc kółkiem jest sama tekstura maski.
    dot:SetTexture(T.circle)
    dot:SetVertexColor(color[1], color[2], color[3], 1)
    return dot
end

local function schedule(delay, fn)
    View.token = (View.token or 0) + 1
    local token = View.token
    C_Timer.After(delay, function()
        if token == View.token then A:Run(fn) end
    end)
end

local handlers = {}

-- Kliknięcie też idzie przez granicę błędu, jak każde zdarzenie gry.
function handlers.click(line, mouse, button)
    if not (line and line.row) then return end
    if mouse == "RightButton" then
        A:Run(A.Menu.Row, button, line.row)
    else
        A:Run(A.Commands.GuideRow, line.row, line.stop, true)
    end
end

function handlers.enter(button)
    View.hovering = true
    A:Run(A.Hint.Show, button, button.line.hint)
    if not View.open then schedule(HOVER_OPEN, function() View:SetOpen(true) end) end
end

function handlers.leave()
    View.hovering = false
    A.Hint.Hide()
    schedule(HOVER_CLOSE, function()
        if not View.hovering then View:SetOpen(false) end
    end)
end

-- Przycisk z ikoną Obchodu: lekko przygaszony, pełny po najechaniu. Klik działa jak /cw.
local function createToggle()
    local button = CreateFrame("Button", nil, UIParent)
    button:SetSize(T.toggleSize, T.toggleSize)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(T.toggleIcon)
    button.icon = icon
    -- Lewy przycisk jak /cw, prawy otwiera menu: ukryte pozycje, miejsce i skala.
    button:SetScript("OnClick", function(self, mouse)
        A:Run(function()
            if mouse == "RightButton" then A.Menu.Toggle(self) else View:Toggle() end
        end)
    end)
    button:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        A:Run(A.Hint.Show, self, A.Place.unlocked and L.HINT_MOVE or L.HINT_TOGGLE, true)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetAlpha(A.Place.RestAlpha())
        A.Hint.Hide()
    end)
    A.Place.Attach(button)
    -- Ramka bywa tworzona w trakcie pauzy, np. po logowaniu w instancji.
    button:SetShown(next(View.paused) == nil)
    View.toggle = button
end

local function create()
    createToggle()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(T.width)
    frame:EnableMouse(false)
    -- Przycięcie do ramki daje efekt rozwijania przy zmianie wysokości.
    frame:SetClipsChildren(true)
    createShade(frame)
    local rail = frame:CreateTexture(nil, "ARTWORK")
    rail:SetColorTexture(unpack(T.colors.rail))
    rail:SetWidth(1.5)
    View.rail = rail
    View.current = circle(frame, T.currentDot, T.colors.gold, 2)
    View.nodes = {}
    frame:Hide()
    View.frame = frame
end


local function node(i)
    local pair = View.nodes[i]
    if not pair then
        pair = {outer = circle(View.frame, T.stopDot, T.colors.hollow, 2),
            inner = circle(View.frame, T.stopHole, T.colors.hole, 3)}
        View.nodes[i] = pair
    end
    return pair
end

local function placeNode(texture, y)
    local near, _, sign = side()
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", View.frame, "TOP" .. near, sign * T.railInset, -y)
end

-- Pozycje linii od góry i wysokość ramki. Podsumowanie trzyma się dołu, więc jedzie razem z nim.
local function measure(lines)
    local ys, y = {}, T.padTop
    for i, line in ipairs(lines) do
        if line.kind == "place" and lines[i - 1].kind ~= "place" then y = y + T.placeGap end
        ys[i] = y
        y = y + T.heights[line.kind]
    end
    return ys, y + T.padBottom
end

-- Rozmieszcza linie i zwraca wysokość oraz elementy, które są tylko w pełnej trasie.
local function layout()
    local lines = View.lines or {}
    local ys, total = measure(lines)
    local extras, first, last, used, widest, kept = {}, nil, nil, 0, 0, false
    local near, _, sign = side()
    for i, line in ipairs(lines) do
        local button = View.buttons[i] or A.Row.Create(View.frame, handlers)
        View.buttons[i] = button
        local height = T.heights[line.kind]
        widest = math.max(widest,
            A.Row.Set(button, line, T.colors[line.color], T.sizes[line.kind], height, View.mirrored))
        button:SetAlpha(1)
        button:ClearAllPoints()
        if line.kind == "summary" then
            button:SetPoint("BOTTOM" .. near, View.frame, "BOTTOM" .. near, sign * T.textInset, T.padBottom)
        else
            button:SetPoint("TOP" .. near, View.frame, "TOP" .. near, sign * T.textInset, -ys[i])
        end
        -- keep: druga grupa bieżącej strefy zostaje po zwinięciu.
        local extra = line.extra or ((line.kind == "row" or line.kind == "place") and not line.keep)
        if extra then extras[#extras + 1] = button end
        local center = ys[i] + height / 2
        if line.node == "current" then
            placeNode(View.current, center)
        elseif line.node == "stop" then
            used = used + 1
            local pair = node(used)
            placeNode(pair.outer, center)
            placeNode(pair.inner, center)
            pair.outer:SetAlpha(1)
            pair.inner:SetAlpha(1)
            pair.outer:Show()
            pair.inner:Show()
            if extra then
                extras[#extras + 1] = pair.outer
                extras[#extras + 1] = pair.inner
            else
                kept = true
            end
        end
        if line.node then
            first = first or center
            last = center
        end
    end
    for i = #lines + 1, #View.buttons do View.buttons[i]:Hide() end
    for i = used + 1, #View.nodes do
        View.nodes[i].outer:Hide()
        View.nodes[i].inner:Hide()
    end
    View.rail:SetShown(used > 0)
    View.rail:SetAlpha(1)
    if used > 0 then
        View.rail:ClearAllPoints()
        View.rail:SetPoint("TOP", View.frame, "TOP" .. near, sign * T.railInset, -first)
        View.rail:SetHeight(last - first)
        -- Linia łączy też grupę, która zostaje po zwinięciu, więc wtedy nie gaśnie.
        if not kept then extras[#extras + 1] = View.rail end
    end
    -- Ramka przycina zawartość, więc musi być szersza od najdłuższego wiersza.
    View.frame:SetWidth(math.max(T.width, widest + T.textInset + T.leftRoom))
    View.extras = extras
    A.Hint.Refresh()
    return total, extras
end

-- Woła UI/Place.lua, gdy linia trasy przechodzi na drugą krawędź: tło i linie idą za nią.
function View:OnSideChanged()
    self.side = self.mirrored
    placeShade()
    if not self.lines then return end
    local height = layout()
    if not self.anim then self.frame:SetHeight(height) end
end

-- Animacja ------------------------------------------------------------------
-- Jedna naraz, przez OnUpdate własnej ramki. Nowa animacja najpierw kończy poprzednią.

local function ease(t)
    local u = 1 - t
    return 1 - u * u * u
end

local function apply(anim, t)
    local k = ease(t)
    if anim.height then
        View.frame:SetHeight(anim.height[1] + (anim.height[2] - anim.height[1]) * k)
    end
    if anim.alpha then
        View.frame:SetAlpha(anim.alpha[1] + (anim.alpha[2] - anim.alpha[1]) * k)
    end
    for _, fade in ipairs(anim.fades or {}) do
        fade[1]:SetAlpha(fade[2] + (fade[3] - fade[2]) * k)
    end
end

local function finish(anim)
    View.anim = nil
    View.frame:SetScript("OnUpdate", nil)
    apply(anim, 1)
    if anim.done then anim.done() end
end

local function stopAnimation()
    if View.anim then finish(View.anim) end
end

local function animate(anim)
    stopAnimation()
    anim.elapsed = 0
    View.anim = anim
    apply(anim, 0)
    View.frame:SetScript("OnUpdate", function(_, elapsed)
        A:Run(function()
            if View.anim ~= anim then return end
            anim.elapsed = anim.elapsed + elapsed
            local t = math.min(anim.elapsed / T.duration, 1)
            if t >= 1 then finish(anim) else apply(anim, t) end
        end)
    end)
end

local function fadesOf(objects, from, to)
    local fades = {}
    for _, object in ipairs(objects) do fades[#fades + 1] = {object, from, to} end
    return fades
end

-- Stan ----------------------------------------------------------------------
-- Powody pauzy: walka, instancja, ograniczenie. Każdy chowa widok od razu, bez animacji,
-- a zmiany czekają na koniec wszystkich pauz.
View.paused = {}

local function isPaused()
    return next(View.paused) ~= nil
end

local function hide()
    if not View.frame:IsShown() or View.hiding then return end
    View.hiding = true
    animate({alpha = {View.frame:GetAlpha(), 0}, done = function()
        View.hiding = false
        View.frame:Hide()
    end})
end

local function show(height)
    View.frame:SetHeight(height)
    if View.frame:IsShown() and not View.hiding then return end
    View.hiding = false
    View.frame:SetAlpha(0)
    View.frame:Show()
    animate({alpha = {0, 1}})
end

-- Krótka informacja zamiast listy: widać ją przez clearSeconds, potem znika.
local function notice(lines)
    View.clear = true
    View.clearToken = (View.clearToken or 0) + 1
    local token = View.clearToken
    View.lines = lines
    show(layout())
    C_Timer.After(T.clearSeconds, function()
        if token == View.clearToken then A:Run(hide) end
    end)
end

-- Ostatnie zadanie: krótka nagroda, potem nic do resetu (projekt, „Tydzień czysty”).
local function celebrate()
    notice({{text = L.VIEW_CLEAR, kind = "stop", color = "ready"}, A.Lines.Summary(true)})
end

-- Klik w ikonę przy liście pustej, choć tydzień nie jest skończony: mówimy dlaczego, żeby klik
-- nie wyglądał na zepsuty (właściciel 2026-11-10). Najczęściej gracz wszystko ukrył.
local function explain(route)
    local lines = {{text = L.VIEW_NOTHING, kind = "stop", color = "dim"}}
    if route.byUser > 0 then
        lines = {{text = L.VIEW_HIDDEN:format(route.byUser), kind = "stop", color = "dim"},
            {text = L.VIEW_RESTORE, kind = "child", color = "faint"}}
    end
    lines[#lines + 1] = A.Lines.Summary(true)
    notice(lines)
end

-- Gracz ukrył albo przywrócił pozycję (Store/Hidden.lua): przeliczamy od razu.
function View:OnHiddenChanged()
    self.quiet = true
    self:Refresh()
end

function View:Refresh()
    local quiet, asked = self.quiet, self.asked
    self.quiet, self.asked = nil, nil
    if not self.frame then create() end
    -- Miejsce liczymy przy każdym odświeżeniu, bo tracker mógł zostać przeniesiony w trybie edycji.
    A.Place.Apply()
    if isPaused() then
        self.dirty = true
        return
    end
    -- Schowany przez gracza: nic nie liczymy, trasa powstanie przy pokazaniu (właściciel 2026-11-08).
    if self.userHidden then
        hide()
        return
    end
    stopAnimation()
    self.route = A.Route.Build()
    local lines = View.Lines(self.route, self.open)
    if #lines == 0 then
        local finished = self.route.total > 0 and self.route.done == self.route.total
        -- Lista opróżniona ukryciem znika bez „Week clear”: nagroda jest za zrobienie.
        if quiet and not self.clear then
            hide()
        elseif finished and asked then
            -- Gracz kliknął ikonę przy pustej liście: „Week clear” jeszcze raz na chwilę,
            -- żeby klik nie wyglądał na zepsuty (właściciel 2026-11-10).
            celebrate()
        elseif asked then
            explain(self.route)
        elseif finished and self.frame:IsShown() and not self.clear then
            celebrate()
        elseif not self.clear then
            self.frame:Hide()
        end
        return
    end
    self.clear = false
    self.clearToken = (self.clearToken or 0) + 1
    self.lines = lines
    self:Tick()
    show(layout())
end

-- Wiersz wydarzenia odlicza minuty, a gra nie daje na to zdarzenia, więc odświeżamy sami.
function View:Tick()
    local counting = false
    for _, line in ipairs(self.lines or {}) do
        if line.event then counting = true end
    end
    if not counting or self.ticking then return end
    self.ticking = true
    C_Timer.After(TICK, function()
        self.ticking = false
        A:Run(function() self:RequestRefresh() end)
    end)
end

function View:SetOpen(open)
    self.open = open
    if not (self.route and self.frame) or self.clear then return end
    stopAnimation()
    local lines = View.Lines(self.route, open)
    if #lines == 0 or self.userHidden or not self.frame:IsShown() then
        self.lines = lines
        return
    end
    local from = self.frame:GetHeight()
    if open then
        self.lines = lines
        local height, extras = layout()
        animate({height = {from, height}, fades = fadesOf(extras, 0, 1)})
    else
        local _, height = measure(lines)
        animate({height = {from, height}, fades = fadesOf(self.extras or {}, 1, 0), done = function()
            self.lines = lines
            self.frame:SetHeight(layout())
        end})
    end
end

function View:RequestRefresh()
    if InCombatLockdown() or isPaused() then self.dirty = true; return end
    if self.userHidden then return end
    if self.pending or not self.started then return end
    self.pending = true
    C_Timer.After(REFRESH_DELAY, function()
        self.pending = false
        A:Run(function() self:Refresh() end)
    end)
end

-- Układ trybu edycji się zmienił: tracker mógł zmienić miejsce. Gra ustawia ramki w tym samym
-- zdarzeniu, więc czytamy chwilę później. Przed pierwszym pokazaniem nie ma czego przesuwać.
function View:OnLayoutChanged()
    C_Timer.After(REFRESH_DELAY, function()
        A:Run(function()
            if self.frame then self:Refresh() end
        end)
    end)
end

function View:SetPaused(reason, on)
    if on then
        self.paused[reason] = true
        stopAnimation()
        A.Place.StopDrag()
        A.Hint.Hide()
        if self.frame then self.frame:Hide() end
        if self.toggle then self.toggle:Hide() end
        return
    end
    local was = self.paused[reason]
    self.paused[reason] = nil
    -- Przycisk wraca od razu po ostatniej pauzie, nawet gdy Obchód jest schowany przez /cw.
    if self.toggle then self.toggle:SetShown(not isPaused()) end
    if isPaused() or not self.started or not (was or self.dirty) then return end
    self.dirty = false
    self:RequestRefresh()
end

-- Po błędzie Lua (Core.lua): wszystko znika do /reload, bez animacji i bez granicy błędu.
function View:Shutdown()
    self.anim = nil
    if self.frame then
        self.frame:SetScript("OnUpdate", nil)
        self.frame:Hide()
    end
    if self.toggle then self.toggle:Hide() end
end

function View:OnCombatStart() self:SetPaused("combat", true) end
function View:OnCombatEnd() self:SetPaused("combat", false) end

-- Tylko instancje z walką. Housing też jest instancją, a tam lista jest potrzebna.
local COMBAT_INSTANCES = {party = true, raid = true, arena = true, pvp = true, scenario = true}

function View:CheckInstance()
    local inside, kind = A:Read(_G, "IsInInstance")
    self:SetPaused("instance", S.Value(inside) == true and COMBAT_INSTANCES[S.Text(kind) or ""] == true)
end

-- Czat nie dotyczy widoku. Podczas zdarzenia gra zawsze zwraca false, więc sprawdzamy chwilę później.
local function restricted()
    local types = S.Table(S.Field(Enum, "AddOnRestrictionType")) or {}
    for name, kind in pairs(types) do
        if name ~= "Chat" and S.Value(A:Read(C_RestrictedActions, "IsAddOnRestrictionActive", kind)) == true then
            return true
        end
    end
    return false
end

function View:OnRestrictionChanged()
    C_Timer.After(0, function()
        A:Run(function() self:SetPaused("restriction", restricted()) end)
    end)
end

-- Reset: gra kasuje flagi sama, więc wystarczy przeliczyć i pokazać pełną trasę.
function View:ScheduleReset()
    local seconds = S.Number(A:Read(C_DateAndTime, "GetSecondsUntilWeeklyReset"))
    if not seconds then return end
    C_Timer.After(seconds + RESET_MARGIN, function()
        A:Run(function()
            self:OpenFor(LOGIN_OPEN)
            self:ScheduleReset()
        end)
    end)
end

function View:OpenFor(seconds)
    self.started = true
    self.open = true
    self:Refresh()
    schedule(seconds, function()
        if not self.hovering then self:SetOpen(false) end
    end)
end

function View:OnEnterWorld()
    C_Timer.After(LOGIN_DELAY, function()
        A:Run(function()
            self:SetPaused("restriction", restricted())
            -- Po /reload w walce PLAYER_REGEN_DISABLED nie przychodzi drugi raz.
            self:SetPaused("combat", InCombatLockdown() and true or false)
            self:OpenFor(LOGIN_OPEN)
            self:ScheduleReset()
        end)
    end)
end

-- Znikający widok liczy się już jako schowany.
function View:Toggle()
    self.started = true
    local visible = self.frame and self.frame:IsShown() and not self.hiding
    self.userHidden = visible and true or false
    self.asked = not visible
    self:Refresh()
end
