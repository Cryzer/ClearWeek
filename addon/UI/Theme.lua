-- Wygląd Obchodu. Wymiary w pikselach ekranu, jak na makiecie 1:1 z 2560×1440.
local _, A = ...

A.Theme = {
    colors = {
        gold = {1, 0.82, 0},
        -- Kolor znaczy stan (właściciel 2026-11-08, wariant A): złoty to miejsce (bieżące jasne, inne
        -- przygaszone), biały do wzięcia, zielony do oddania, a „w trakcie” stonowany szaroniebieski,
        -- bo to najczęstszy stan i przy NPC nie ma nic do zrobienia. Przygaszone odcienie dla innych stref.
        place = {0.79, 0.68, 0.36},
        active = {0.66, 0.74, 0.84},
        activeDim = {0.49, 0.55, 0.63},
        ready = {0.37, 0.89, 0.42},
        readyDim = {0.29, 0.65, 0.33},
        -- Wydarzenie pod questem w trakcie: odcień jego szaroniebieskiego, jaśniejszy, gdy trwa.
        eventLive = {0.74, 0.83, 0.96},
        eventSoon = {0.53, 0.59, 0.68},
        white = {0.94, 0.94, 0.94},
        dim = {0.63, 0.63, 0.63},
        faint = {0.47, 0.47, 0.47},
        -- Reset w ostatniej dobie: ciepły, ale nie złoty, bo złoty znaczy miejsce.
        warn = {1, 0.56, 0.26},
        shade = {0.04, 0.04, 0.06},
        rail = {1, 1, 1, 0.43},
        hollow = {0.86, 0.86, 0.86},
        hole = {0.04, 0.04, 0.05},
    },
    sizes = {stop = 19, next = 15, here = 15, row = 14, later = 14, child = 13, place = 15, summary = 14},
    heights = {stop = 26, next = 24, here = 24, row = 22, later = 22, child = 20, place = 30, summary = 22},
    placeGap = 8,
    -- Prawa krawędź ramki leży tuż za linią trasy, a linia przy lewej krawędzi trackera właściciela.
    -- right i top obowiązują tylko, gdy trackera nie da się odczytać (UI/Place.lua).
    right = -272, top = -290,
    -- Obok trackera: odstęp od jego krawędzi i zejście poniżej jego góry. Dają układ właściciela
    -- przy trackerze w domyślnym miejscu (róg 262 px od prawej i 258 px od góry).
    trackerGap = 10, trackerDrop = 32,
    -- Szerokość najmniejsza. Dłuższy tekst poszerza ramkę w lewo, zostawiając leftRoom na wygaszenie tła.
    width = 360, leftRoom = 80, padTop = 14, padBottom = 16,
    -- Linia trasy 6 px w lewo, żeby zrobić miejsce na przycisk; tekst bez zmian (właściciel 2026-11-08).
    textInset = 32, railInset = 22,
    currentDot = 12, stopDot = 8, stopHole = 5,
    shadeAlpha = 0.84,
    -- Miękkie brzegi tła: lewa część wygasa przez całą resztę szerokości, prawa, górna i dolna krótko.
    fadeSolid = 130, fadeRight = 14, fadeY = 18, fadeStep = 2,
    -- Przycisk jak /cw przy lewym górnym rogu trackera właściciela (pomiar 2026-11-08: róg 262 px od
    -- prawej i 258 px od góry). Stoi między kropką bieżącej grupy a nagłówkiem „Quests” trackera
    -- (zrzut właściciela 2026-11-08).
    -- Ikona: Obchód w miniaturze (tools/icon.py, wariant B wybrany przez właściciela).
    toggleIcon = "Interface\\AddOns\\ClearWeek\\Media\\Toggle",
    toggleRight = -271, toggleTop = -309, toggleSize = 24, toggleRest = 0.7,
    -- Podpowiedź po najechaniu: mniejsza od wierszy, na tle jak mgła Obchodu.
    hintSize = 13, hintHeight = 22, hintPad = 8, hintGap = 10, hintAlpha = 0.92,
    clearSeconds = 6,  -- „Tydzień czysty” przed zniknięciem
    duration = 0.42,  -- pojawianie, rozwijanie i zwijanie
    circle = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
}
