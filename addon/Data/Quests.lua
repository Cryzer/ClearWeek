-- JEDYNA tabela pozycji. Nowy quest to nowy wiersz, kod się nie zmienia.
-- Do pul trafiają wyłącznie ID tygodniowe: jedna stała flaga fabularna oznaczałaby
-- „zrobione” w każdym tygodniu. Źródła i pewność: projekt, sekcja 2.
local _, A = ...

local function span(from, to, step)
    local ids = {}
    for id = from, to, step or 1 do ids[#ids + 1] = id end
    return ids
end

A.Data = {
    -- Grupy jak w grze: miasto, potem reputacje (wybór właściciela 2026-11-08, wzór Plumber).
    -- Mapa służy tylko do wskazania grupy bieżącej strefy (UiMap 70783: Zul'Aman 2437).
    stops = {
        {key = "silvermoon", name = "Silvermoon City", map = 2393},
        -- Prey bez własnej mapy: Astalor stoi w Silvermoon, więc tam grupa też jest „tu” (właściciel 2026-11-08).
        {key = "prey", name = "Prey", also = {2393}},
        {key = "court", name = "Silvermoon Court", map = 2395},
        {key = "amani", name = "Amani Tribe", map = 2437},
        {key = "harati", name = "Hara'ti", map = 2413},
        -- also: mapy, na których grupa też jest „tu”. W Voidstorm obie frakcje naraz, bo każdą widać
        -- w innej części mapy (właściciel 2026-11-08).
        {key = "singularity", name = "The Singularity", map = 2405, also = {2444}},
        {key = "slayers", name = "Slayer's Duellum", map = 2444, also = {2405}},
        -- Na dole listy (właściciel 2026-11-08).
        {key = "zuljarra", name = "Zul'jarra's Forces", map = 2512},
        -- Delves bez własnej mapy: w Silvermoon razem z miastem i Prey (właściciel 2026-11-08).
        {key = "delves", name = "Delves", also = {2393}},
    },
    quests = {
        -- Silvermoon City
        {key = "unity", stop = "silvermoon", title = "Unity Against the Void", who = "Lady Liadrin",
            kind = "pool", offer = 93744, map = 2393, x = 49.0, y = 64.6, when = {level = 90},
            ids = {93766, 93767, 93769, 93889, 93890, 93891, 93892, 93909, 93910, 93911, 93912,
                93913, 94457, 95842, 95843, 96727, 98232},
            conf = "A", src = "K WM WK BR MH"},
        {key = "dungeon", stop = "silvermoon", title = "Weekly Dungeon", who = "Halduron Brightwing",
            kind = "pool", ids = span(93751, 93758), when = {level = 90},
            conf = "B", src = "K BR, WS 93751, G 93756"},
        {key = "bonus", stop = "silvermoon", title = "Bonus Event", who = "Archmage Aethas Sunreaver",
            kind = "pool", ids = {93593, 93595, 93598, 93599, 93600, 93605, 93614}, when = {level = 90},
            conf = "B", src = "K BR, WS 93598, WK 93593 93595, G 93598"},
        -- Vereesa daje quest co tydzień (właściciel 2026-11-08). Jeden quest dla obu frakcji: Wowhead
        -- podaje stronę Alliance, ale to jedyny quest na Fading Voidwhisper (przedmiot 279573, zakładka
        -- objective-of), a Plumber, Polypode Suivi i PermoksAccountManager pokazują 98172 bez warunku
        -- frakcji. Na postaci Hordy niezmierzone (2026-11-10).
        {key = "xalatath", stop = "silvermoon", title = "Trailing Xal'atath", who = "Vereesa Windrunner",
            kind = "flag", ids = {98172}, when = {level = 90},
            -- Pin oferty 98172 gra nie przyjmuje, więc pinezka z nazwą przy Vereesie (pomiar 2026-11-08).
            map = 2393, x = 49.09, y = 64.61,
            conf = "B", src = "K WM WK WS, MH pomiar ID"},
        {key = "nightmarish", stop = "prey", title = "A Nightmarish Task", who = "Astalor Bloodsworn",
            kind = "flag", ids = {94446}, when = {level = 90, renown = {2764, 4}},
            -- Astalor stoi w Astalor's Sanctum (podstrefa), do którego prowadzi Orb of Translocation.
            -- Poza sanktuarium pinezka przy orbie (via), w nim przy Astalorze (pomiar właściciela 2026-11-08).
            map = 2393, x = 56.72, y = 65.45, via = {x = 55.81, y = 65.17, unless = "Astalor's Sanctum"},
            conf = "A", src = "K WH WK BR, G, WH npc 246231"},
        -- Prey poza listą (właściciel, 2026-11-07): tygodniowy obowiązek to A Nightmarish Task,
        -- a polowania są dobrowolne.
        {key = "vaeli", stop = "silvermoon", title = "Vaeli's Weeklies", who = "Vaeli",
            -- Pin oferty Vaeli istnieje tylko w dzielnicy mieszkalnej (pomiar 2026-11-07), w Silvermoon pinezka.
            kind = "pool", ids = {95413, 95416, 95438, 95440}, map = 2393, x = 49.48, y = 65.78, offerMaps = {2352},
            when = {level = 90}, conf = "B", src = "K WH WK MH, G 95413 95416"},

        -- Przystanek to miejsce NPC, który daje quest, a nie strefa zadania: Lilatha stoi w Silvermoon
        -- (właściciel, 2026-11-08, pin oferty 348 yd w mieście).
        {key = "assaults", stop = "silvermoon", title = "Void Assaults", who = "Ranger Captain Lilatha",
            kind = "pool", ids = {94385, 94386}, when = {level = 80},
            conf = "A", src = "K WS BR MH, G 94386"},

        -- Bonus roll u Orina Straylighta: trzy dzienne questy-zakupy (98012 Veteran Mistcrest, 98015 Voidlight
        -- Marl, 98016 Gold; pomiar 2026-11-08, frequency 1). Limit to sezonowe maksimum waluty Nebulous
        -- Voidcore (3418), które rośnie co tydzień, więc stan czytamy z waluty (pomiar: 4 z 5).
        {key = "voidcore", stop = "silvermoon", title = "Nebulous Voidcore", who = "Orin Straylight",
            kind = "currency", currency = 3418, ids = {98012, 98015, 98016}, when = {level = 90},
            -- Pinezka z nazwą przy Orinie (pomiar 2026-11-08). Pin oferty nosi nazwę jednej z form zapłaty.
            map = 2393, x = 40.00, y = 64.80,
            conf = "A", src = "G 98012 98015 98016 3418, Method"},

        -- Silvermoon Court i Amani Tribe
        -- Progi poziomu z Wowhead („Requires level”, 2026-11-10): Favor, Runestones i Abundant
        -- Offerings 80, Lost Legends i relikty 83.
        {key = "favor", stop = "court", title = "Favor of the Court", who = "Lord Saltheril",
            kind = "flag", ids = {89289}, when = {level = 80}, conf = "A", src = "K L WH WK PL BR"},
        {key = "runestones", stop = "court", title = "Fortify the Runestones", who = "Faction Representative",
            kind = "pool", ids = span(90573, 90576), when = {level = 80, questDone = 89289},
            conf = "A", src = "K L WH WK PL BR"},
        {key = "abundance", stop = "amani", title = "Abundant Offerings", who = "Chel the Chip",
            -- Bieżące Abundance ze znacznika wydarzenia (np. „Abundance: Herbalism Grotto”, AreaPOI 8418 i dalsze).
            -- Grupa ze strefy znacznika (zoneStop), Amani Tribe, gdy znacznika nie widać (właściciel 2026-11-08).
            kind = "flag", ids = {89507}, eventPrefix = "Abundance", eventMaps = {2395, 2437, 2413, 2405}, zoneStop = true, when = {level = 80}, conf = "A", src = "K L WH PL BR",
            -- Miejsca Abundance w strefach do wyboru mapy (Model/Offers.lua). Punkty z wiki (projekt, sekcja 2);
            -- Eversong zgodny z grą (pomiar 2026-11-11: 8528 na 2395 w 56.83 65.80, na 2437 w 17.49 37.98).
            eventSites = {[2395] = {56.78, 65.79}, [2437] = {31.62, 26.14}, [2413] = {66.14, 61.69}, [2405] = {38.82, 53.31}}},

        -- Hara'ti
        -- Znacznik mapy „Legends of the Haranir”: AreaPOI 8423 (quest 89268) i 8463 (powtórka, 92713), tabela AreaPOI 70783.
        -- Po odnowieniu reliktów Kassameh daje tygodniowe Echoes Rekindled (92713) zamiast 89268
        -- (WH 92713, właściciel 2026-11-08: po zrobieniu pozycja zostawała na liście).
        {key = "legends", stop = "harati", title = "Lost Legends", who = "Zur'ashar Kassameh",
            kind = "flag", ids = {89268, 92713}, pois = {8423, 8463}, when = {level = 83},
            conf = "A", src = "K WH WK PL BR"},
        {key = "relic", stop = "harati", title = "Weekly Relic", who = "Zur'ashar Relics",
            kind = "pool", ids = span(88993, 88999), when = {level = 83, questDone = 89268},
            conf = "A", src = "K L WK"},

        -- The Singularity
        -- Tygodniowy quest konsoli badań, dopóki nie ma osiągnięcia 62385 Staring Into The Void (wiki).
        {key = "research", stop = "singularity", title = "Research Console: Exploring the Void",
            who = "Void Researcher Anomander", kind = "flag", ids = {94790},
            when = {level = 80, noAchievement = 62385},
            conf = "A", src = "K WK, WK 62385"},

        -- Slayer's Duellum
        -- Tygodniowy quest PvP w Slayer's Rise (Wowhead: Weekly PvP, Side Both, od patcha 12.0.1).
        -- Deminos Darktrance, NPC 245976, mapa 2444 w 38.8, 81.4 (Wowhead, do potwierdzenia w grze).
        {key = "battle", stop = "slayers", title = "Preparing for Battle", who = "Deminos Darktrance",
            kind = "flag", ids = {89354}, when = {level = 90},
            map = 2444, x = 38.8, y = 81.4,
            conf = "B", src = "WH 89354, WH npc 245976"},

        -- Zul'jarra's Forces
        -- Najpierw Coiled Isle, potem Purging the Vaults (bierze się go też u Zeli; właściciel 2026-11-08,
        -- strefy z WH). Zadań dziennych (rotacja Vaults, WANTED) nie ma na liście: decyzja
        -- właściciela 2026-11-10, tylko tygodniowe.
        {key = "surge", stop = "zuljarra", title = "Turn Back the Surge", who = "Talon Commander Zela",
            kind = "flag", ids = {96995}, when = {level = 90},
            -- Miejsca Curse Surge: poi to numer w harmonogramie, live to numer znacznika na mapie
            -- w tym samym miejscu (tabela AreaPOI; pomiar 2026-11-08: trwał 8891, nie 8940).
            -- Punkty z C_Map.GetMapPosFromWorldPos na mapie 2512. Startują co 30 min, kolejno.
            schedule = {
                {poi = 8936, live = 8887, title = "Curse Surge: The Looming Mutagenitor", map = 2512, x = 26.60, y = 64.87},
                {poi = 8937, live = 8890, title = "Curse Surge: Siege at the Whispering Marsh", map = 2512, x = 67.51, y = 77.89},
                {poi = 8938, live = 8888, title = "Curse Surge: The Broodmother's Nest", map = 2512, x = 45.83, y = 29.32},
                {poi = 8939, live = 8889, title = "Curse Surge: Mlurkkr Massacre", map = 2512, x = 70.77, y = 32.20},
                {poi = 8940, live = 8891, title = "Curse Surge: The Malformed Leviathan", map = 2512, x = 47.32, y = 61.98},
            },
            scheduleMaps = {2512, 2509},
            -- Rytm z harmonogramu (pomiar 2026-11-08): start co 30 min. Poza wyspą gra nie podaje
            -- harmonogramu, więc stąd wyliczamy czas do następnego, bez miejsca (właściciel 2026-11-08).
            period = 1800, eventTitle = "Curse Surge",
            conf = "A", src = "K L WH WK PL, G"},
        {key = "vaults", stop = "zuljarra", title = "Purging the Vaults", who = "Warleader Abdumati",
            kind = "flag", ids = {95520}, when = {level = 90},
            -- Dwóch NPC: bierze się u Zeli albo u Abdumatiego, oddaje u Abdumatiego (WH 95520, NPC 267635
            -- i 262798). Do wzięcia: ten na mapie gracza, inaczej pierwszy (właściciel 2026-11-08).
            givers = {
                {who = "Talon Commander Zela", map = 2512, x = 58.6, y = 45.8},
                {who = "Warleader Abdumati", map = 2509, x = 47.2, y = 60.8, ends = true},
            },
            conf = "A", src = "K L WH WK PL, G"},
        -- World boss tygodnia przy reputacji jego strefy (właściciel 2026-11-08): Lu'ashal Eversong,
        -- Cragpine Zul'Aman, Thorm'belan Harandar, Predaxas Voidstorm (WH, typ World Boss). Grupa po ID
        -- (stopOf), bo zadanie widać też na sąsiednich mapach (Cragpine na mapie Eversong, zrzut
        -- właściciela 2026-11-08). Imię daje zadanie mapy. Gdy go nie widać, pozycja jest ukryta.
        {key = "worldboss", title = "World Boss", kind = "pool", ids = {92560, 92123, 92034, 92636},
            stopOf = {[92560] = "court", [92123] = "amani", [92034] = "harati", [92636] = "singularity"},
            offerMaps = {2395, 2437, 2413, 2405}, zoneStop = true, whoFromOffer = true, worldQuest = true,
            when = {level = 90}, conf = "B", src = "K PL, WH 92560 92123 92034 92636"},

        -- Delves: Trovehunter's Bounty (przedmiot 252415, sezon 2: 274374), raz w tygodniu. Pomiar
        -- właściciela 2026-11-08: z buffem 1293799 86371 true, 92887 false; po otwarciu skarbu 86371 true,
        -- 92887 i 87287 false, buffu brak. Z nieużytą mapą w torbie Plumber (tylko 86371) nie odhaczał
        -- pozycji, więc 86371 to użycie mapy. Buff (aura) daje „w trakcie”.
        -- Bez NPC i bez prowadzenia (bag).
        {key = "bounty", stop = "delves", title = "Trovehunter's Bounty", kind = "flag", ids = {86371},
            aura = 1293799, bag = true, when = {level = 90}, conf = "C", src = "WH 252415 265714 274374, komentarze"},
    },
}
