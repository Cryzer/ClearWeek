# Changelog

## 0.14.1

- Trailing Xal'atath jest na liście także na postaciach Hordy. Warunek „tylko Alliance” pochodził z Wowhead, ale to jedyny quest na Fading Voidwhisper, a Plumber, Polypode Suivi i PermoksAccountManager pokazują go obu frakcjom. Na postaci Hordy niezmierzone.
- Progi poziomu z Wowhead dla pozycji, które ich nie miały: Favor of the Court, Fortify the Runestones i Abundant Offerings od 80, Weekly Relic od 83. Postać poniżej 80 nie ma już żadnej pozycji.

## 0.14.0

Porządki przed wydaniem (decyzje właściciela 2026-11-10):

- Zostaje sama komenda `/cw` (pokaż albo schowaj). `/cw diag`, `/cw list` i `/cw go` usunięte. Gdy addon stoi po błędzie albo przez nowszy zapis, `/cw` podaje wersję, build gry, stan i ostatni błąd.
- Klik w ikonę (albo `/cw`) przy liście opróżnionej ukryciem pokazuje na chwilę „All hidden (N)” z podpowiedzią, jak przywrócić pozycje, zamiast nic nie robić.
- Miejsce ustawione przeciąganiem zapisuje rozmiar ekranu i po zmianie rozdzielczości przelicza się proporcjonalnie. Starsze zapisy zostają w pikselach do następnego przeciągnięcia.
- Z zapisu postaci znika nieużywana pamięć oddanych zadań dziennych z 0.11.
- Skrót klawiszowy skreślony z planu.
- Usunięty martwy kod: licznik polowań Prey (detektor `count` z postępem X/Y), pola `status` i `build` w tabeli pozycji, licznik `A.errors`.
- `A:Read` nie tworzy już tabeli przy każdym odczycie API.
- Ikona i kategoria „Quests” na liście addonów gry oraz `.pkgmeta` do budowania paczki (pliki z `addon/` trafiają do folderu `ClearWeek`).

## 0.13.0

Domyślne miejsce przy trackerze zadań (decyzja właściciela 2026-11-10):

- Bez zapisanego miejsca Obchód staje obok trackera zadań, po stronie środka ekranu, i idzie za nim po przeniesieniu w trybie edycji. Odstępy są takie, żeby przy trackerze w dotychczasowym miejscu właściciela nic się nie zmieniło.
- Tracker na lewej połowie ekranu odbija Obchód: linia trasy i ikona są przy lewej krawędzi, tekst idzie w prawo, pinezki i podpowiedzi są po prawej.
- Miejsce ustawione przeciąganiem nadal ma pierwszeństwo, a o odbiciu decyduje wtedy połowa ekranu, na której stoi Obchód (zmienia się już w trakcie przeciągania). „Reset position” wraca do miejsca przy trackerze.
- Tracker jest tylko czytany (krawędzie `ObjectiveTrackerFrame`), bez zmian i bez kotwiczenia. Gdy krawędzi nie da się odczytać, zostaje ostatnie znane miejsce, a bez niego dotychczasowy stały układ.

## 0.12.1

- Po skończonym tygodniu klik w ikonę (albo `/cw`) pokazuje na chwilę „Week clear” z czasem do resetu, zamiast nic nie robić. Kolejny klik w trakcie chowa.

## 0.12.0

Tylko zadania tygodniowe (decyzja właściciela 2026-11-10):

- Usunięte zadania dzienne: rotacja Vaults of Atal'Utek (Hawkeye Socho, Er'inye, Warleader Abdumati) i WANTED od Shul'ka Li'tya.
- Usunięty odczyt ofert NPC z mapy (`C_QuestLine`): gra nie podaje tam tych zadań (pomiar właściciela 2026-11-10, mapy 2509 i 2512).
- Usunięta pamięć oddanych zadań (`Store/Turned.lua`). Addon znów nie zapisuje postępu, tylko ukrycia, miejsce i skalę.

## 0.11.1

- Hawkeye Socho: Patrolling the Temple, Relentless Strikes i Decisive Incursions są jedną pozycją (Wowhead, zakładka Starts NPC, zrzut właściciela 2026-11-10). Oddanie jednego zamyka ją do resetu tygodnia, także gdy następnego dnia NPC ma w rotacji inne.
- Er'inye: Bounty of the Cursed, Essence of Malice i From Whence it Came są jedną pozycją na tej samej zasadzie (jej zakładka Starts, zrzut właściciela 2026-11-10).
- Warleader Abdumati: Shoulder to Shoulder i What's Out There? są jedną pozycją (jego zakładka Starts, zrzut właściciela 2026-11-10). ID obu tylko z Plumbera, bez pomiaru w grze.

## 0.11.0

Zadania z dziennej rotacji NPC: WANTED i Vaults of Atal'Utek (decyzja właściciela 2026-11-10, zastępuje 0.10.1):

- „Do wzięcia” tylko wtedy, gdy gra dziś oferuje zadanie u NPC (oferty z mapy, `C_QuestLine.GetAvailableQuestLines`). Wiersz ma dzisiejszy tytuł, a klik prowadzi do tej oferty.
- Po oddaniu pozycja jest zrobiona do resetu tygodnia, także gdy gra zgasi flagę. Addon zapamiętuje oddanie osobno dla postaci (`ClearWeekCharDB.turned`).
- Vaults of Atal'Utek: osiem zadań rotacji jako osobne pozycje (96639–96644, 98419, 98420), bo nie wiadomo, które jest od którego NPC. Widać tylko oferowane dziś i te w dzienniku.
- Bez oferty, bez dziennika i bez zaliczenia pozycji nie ma na liście.

## 0.10.1

- Zadania dzienne z rotacji są na liście tylko wtedy, gdy są w dzienniku, jak w Plumberze. Wcześniej po zrobieniu wracały jako „do wzięcia”, choć NPC nic nie oferował (pomiar właściciela 2026-11-10).
- Vaults of Atal'Utek: jedna pozycja z ośmioma zadaniami rotacji (96639–96644, 98419, 98420) zamiast stałych Patrolling the Temple i Essence of Malice. Tytuł z gry.
- WANTED: tylko w dzienniku.

## 0.10.0

Ukrywanie pozycji i menu zamiast komend (decyzje właściciela 2026-11-10):

- Prawy przycisk na wierszu: „Hide this week” albo „Hide always”. Ukryta pozycja znika z Obchodu, nie jest następnym krokiem i nie liczy się do „Week clear”. Zapis osobno dla postaci (`ClearWeekCharDB`), ukrycie tygodniowe gaśnie przy resecie.
- Prawy przycisk na ikonie Obchodu: lista ukrytych pozycji (kliknięcie przywraca, „Show all” wszystkie), „Unlock position”, „Scale” 80–140% i „Reset position”.
- `/cw move` i `/cw scale` usunięte: miejsce i skala są tylko w menu ikony.
- Lista opróżniona ukryciem znika bez „Week clear”.
- Podpowiedzi wspominają o prawym przycisku, a `/cw list` podaje osobno liczbę pozycji ukrytych przez gracza.

## 0.9.0

Początek etapu 6 (decyzja właściciela 2026-11-09):

- Podpowiedź po najechaniu na wiersz: co zrobi klik i w jakiej strefie stoi NPC, gdy to wiadomo. Przycisk też ma podpowiedź. Własna ramka, bez GameTooltip.
- „reset in …” ma cieplejszy kolor w ostatniej dobie przed resetem.
- Miejsce i skala: `/cw move` odblokowuje przeciąganie przyciskiem, `/cw move reset` przywraca domyślne miejsce, `/cw scale 0.8–1.4` zmienia rozmiar. Zapis w `ClearWeekDB.view`, wspólny dla konta.

## 0.8.29

Przegląd przed wydaniem (2026-11-09):

- Błąd Lua chowa Obchód i przycisk do `/reload`. Wcześniej widok zostawał na ekranie z nieaktualną listą, a kliknięcia i timery dalej działały.
- Po `/reload` albo logowaniu w walce Obchód czeka na jej koniec.
- Ograniczenie wykryte przy logowaniu chowa też przycisk pokazany wcześniej przez `/cw`.
- Zabity world boss liczy się w `/cw list` do zrobionych w grupie swojej strefy, a nie do ukrytych.
- `tools/deploy.py` przed kopiowaniem uruchamia `tools/verify.py`, czyli zgodność wersji i testy. Wersja w `docs/DESIGN.md` wyrównana z TOC.

## 0.8.28

- Wydajność: zmiana buffów przelicza trasę tylko wtedy, gdy buff Trovehunter's Bounty pojawi się albo zniknie, a nie przy każdym procu. Bez sprawdzania torby i bez odświeżania po zmianie toreb, bo 86371 oznacza użycie mapy.

## 0.8.27

- Trovehunter's Bounty: zrobione według flagi 86371 (pomiar po otwarciu skarbu), a nie 92887, która się nie ustawia. Mapa w torbie albo buff po jej użyciu trzymają pozycję na liście. Obchód odświeża się po zmianie toreb.

## 0.8.26

- Trovehunter's Bounty jest „w trakcie” (kolor jak quest w dzienniku), gdy postać ma buff po użyciu mapy (1293799). Obchód odświeża się po zmianie buffów gracza.

## 0.8.25

- W Silvermoon City grupa Delves jest widoczna razem z miastem i Prey.

## 0.8.24

- Nowa grupa Delves na dole listy: Trovehunter's Bounty, dopóki postać w tym tygodniu nie użyła mapy (flaga 92887). Sama zdobyta mapa (86371) nie wystarcza. Bez NPC, pinezki i prowadzenia.

## 0.8.23

- Purging the Vaults na drugim miejscu w Zul'jarra's Forces, zaraz po Turn Back the Surge.

## 0.8.22

- Purging the Vaults ma dwóch NPC: do wzięcia w Vaults pokazuje i prowadzi do Warleadera Abdumatiego, gdzie indziej do Talon Commander Zeli (Coiled Isle 58.6, 45.8). Po pobraniu NPC to Abdumati, bo tylko on przyjmuje quest.

## 0.8.21

- Zul'jarra's Forces: najpierw Turn Back the Surge (Coiled Isle), potem questy z Vaults of Atal'Utek.

## 0.8.20

- World boss przypisany do grupy po ID questu. Cragpine trafiał do Silvermoon Court, bo jego zadanie widać też na mapie Eversong.

## 0.8.19

- Nowa pozycja World Boss przy reputacji strefy bossa tygodnia: Lu'ashal (Silvermoon Court), Cragpine (Amani Tribe), Thorm'belan (Hara'ti), Predaxas (The Singularity). Imię z zadania mapy, klik ustawia strzałkę na quest. Gdy bossa nie widać, pozycja jest ukryta.
- Abundance stoi przy reputacji strefy, w której trwa. Bez znacznika zostaje przy Amani Tribe.

## 0.8.18

- Zul'jarra's Forces na dole listy.

## 0.8.17

- Prey jest w Silvermoon „tu”: pod Silvermoon City, także po zwinięciu, jak druga frakcja w Voidstorm.

## 0.8.16

- A Nightmarish Task: poza Astalor's Sanctum pinezka stoi przy Orb of Translocation (55.81, 65.17), a w sanktuarium przy Astalorze (56.72, 65.45). Po teleporcie pinezka sama się przestawia, jeśli nadal jest aktywna. Pinezki gracza i strzałki na quest addon nie rusza.

## 0.8.15

- A Nightmarish Task prowadzi pinezką z nazwą przy Astalorze Bloodsworn (Silvermoon 56.6, 65.4, dane z Wowhead, do potwierdzenia w grze).

## 0.8.14

- Wariant A kolorów: „w trakcie” stonowany szaroniebieski zamiast nasyconego niebieskiego, bo to najczęstszy stan. Nazwy innych stref przygaszone złote zamiast białych, więc złoty znaczy miejsce, a biały quest do wzięcia.

## 0.8.13

- Wszystkie questy pod złotym nagłówkiem mają pełne kolory także poza strefą. Wcześniej tylko pierwszy był jasny, a reszta przygaszona, jak w innych strefach.

## 0.8.12

- Kolor znaczy stan: złoty tylko bieżąca strefa, biały do wzięcia, niebieski w trakcie, zielony do oddania. Inne strefy w przygaszonych odcieniach tych samych kolorów. Licznik wydarzenia w jaśniejszym niebieskim zamiast turkusu, „Week clear” na zielono.

## 0.8.11

- Lost Legends liczy się jako zrobione także po powtórce Echoes Rekindled (92713), którą Kassameh daje po odnowieniu reliktów. Wcześniej pozycja zostawała na liście.

## 0.8.10

- W Voidstorm Obchód pokazuje obie frakcje naraz: bieżącą na górze i drugą zaraz pod nią, także po zwinięciu. Grupa może mieć dodatkowe mapy (`also`), na których też jest „tu”.

## 0.8.9

- Nowa grupa Slayer's Duellum (Slayer's Rise, mapa 2444) z tygodniowym Preparing for Battle (89354) od Deminosa Darktrance. Dane z Wowhead, do potwierdzenia w grze.

## 0.8.8

- Usunięte Stormarion Assault i Stand Your Ground razem z obsługą questów światowych (`kind = "task"`).

## 0.8.7

- Addon po angielsku: napisy Obchodu, `/cw` i opis w liście addonów. Testy odrzucają polskie znaki poza komentarzami.
- Stormarion Assault bez fazy i bez koloru wydarzenia, znów „? Stormarion Assault”.
- Curse Surge poza Coiled Isle: sam czas do następnego startu („Curse Surge · in X min”), a przez pierwsze 3 minuty „Curse Surge · live”. Bez miejsca i pinezki; szczegóły tylko na wyspie.

## 0.8.6

- Schowany Obchód (ikona albo `/cw`) nie pracuje w tle: nie przelicza trasy ani nie odlicza Curse Surge. Trasa powstaje od nowa przy pokazaniu.

## 0.8.5

- Tekst Obchodu wraca na miejsce. W lewo przesunięta tylko linia trasy z kropkami (6 px), a przycisk o 6 px w lewo.

## 0.8.4

- Przycisk przeniesiony na prawo od kropki bieżącej grupy, na wysokość nagłówka trackera. Obchód (linia trasy, kropki i tekst) przesunięty o 6 px w lewo.

## 0.8.3

- Przycisk ma własną ikonę (wariant B): Obchód w miniaturze na ciemnym krążku, 24 px, na linii trasy tuż nad kropką bieżącej grupy. Teksturę `addon/Media/Toggle.tga` rysuje `tools/icon.py`.
- Testy odrzucają pojedynczy ukośnik przed wielką literą w kodzie Lua, bo psuje ścieżki tekstur.

## 0.8.2

- Dyskretny przycisk przy lewym górnym rogu trackera: przygaszona złota kropka nad linią trasy, pełna po najechaniu. Klik działa jak `/cw`. Znika w walce, w instancji i przy ograniczeniach, razem z Obchodem.

## 0.8.1

- Pinezki przy wierszach są przygaszone (45%) i rozjaśniają się po najechaniu myszą.

## 0.8.0

- Usunięty Zwiadowca: addon nie odczytuje już pełnej listy zaliczonych questów przy logowaniu ani po oddaniu questa, nie ma `/cw scout` ani zapisu `ClearWeekScoutDB`. Zadania dodajemy ręcznie, po pomiarze w grze (decyzja właściciela 2026-11-08).

## 0.7.27

Po przeglądzie kodu:
- Oferty, wydarzenia i fazy są czytane tylko dla wierszy, które je pokażą. Harmonogram gry jest pytany tylko przy Turn Back the Surge w trakcie, bo każde zapytanie może wysłać prośbę do serwera, a odpowiedź odświeża widok.
- Kliknięcie w wiersz idzie przez granicę błędu (`A:Run`), jak zdarzenia gry.
- Wspólny moduł `Model/Maps.lua` zamiast dwóch kopii wspinania po mapach nadrzędnych i zbierania znaczników.
- `UI/Route.lua` rozdzielone: linie tekstu w `UI/Lines.lua`, rysowanie i stan w `UI/Route.lua`.
- Zwiadowca nie koduje migawki od nowa, gdy liczba zaliczonych questów się nie zmieniła.
- `tools/deploy.py` najpierw uruchamia testy i nic nie kopiuje, gdy któryś pada.

## 0.7.26

- Trailing Xal'atath prowadzi pinezką z nazwą przy Vereesie (Silvermoon 49.1, 64.6). Pin oferty gra odrzucała.

## 0.7.25

- Bonus roll prowadzi pinezką z nazwą „Nebulous Voidcore” przy Orinie (Silvermoon 40.0, 64.8), a nie pinem oferty podpisanym jedną z form zapłaty.

## 0.7.24

- Silvermoon City: Orin Straylight · Nebulous Voidcore (bonus roll). Do wzięcia, dopóki zdobyte Voidcore'y (waluta 3418) nie osiągną sezonowego limitu, który rośnie co tydzień. Klik prowadzi pinem oferty Orina (98012, 98015, 98016), jeśli gra go zna.

## 0.7.23

- Trailing Xal'atath bez „?”: Vereesa daje quest co tydzień, więc niezrobiony jest do wzięcia. Usunięto pole `uncertain`.

## 0.7.22

- Stormarion Assault i Stand Your Ground pokazują fazę ze znacznika na mapie Voidstorm (widocznego też z daleka) zamiast „?”: „zbieranie rdzeni”, „budowa obrony” albo „trwa”, w kolorze akcentu.
- Questy światowe bez „Quest światowy ·” przed tytułem.

## 0.7.21

- Poza Coiled Isle harmonogram zapamiętany przez grę nie pomija już bieżącego Curse Surge: brak znacznika znaczy „skończone” tylko na wyspie, gdzie znaczniki są widoczne. Gdzie indziej wiersz pokazuje bieżące okno „do X min”.

## 0.7.20

- Curse Surge poza Coiled Isle: gra nie podaje tam harmonogramu, więc addon zapamiętuje start na wyspie i wylicza z rytmu (co 30 min, stała kolejność miejsc). Wiersz pokazuje „do X min” dla bieżącego okna, a gdy zostaje mniej niż 5 min, następne „za X min”.
- Wiersz Curse Surge bez wcięcia, w kolorze akcentu: pełnym, gdy trwa, przygaszonym w pozostałych stanach.

## 0.7.19

- Wiersz Curse Surge pojawia się, gdy harmonogram dotrze z serwera (EVENT_SCHEDULER_UPDATE), także po `/reload` poza Coiled Isle.

## 0.7.18

- Wiersz Curse Surge wygląda jak cel questu: wcięty, mniejszy, jaśniejszy gdy trwa i przygaszony gdy nadchodzi, sama nazwa miejsca, np. „The Malformed Leviathan · trwa”.

## 0.7.17

- Curse Surge: trwające wydarzenie rozpoznajemy po numerze znacznika na mapie (8887–8891), który różni się od numeru w harmonogramie (8936–8940). Wcześniej trwający Curse Surge był pomijany.
- Przez 5 min po starcie z harmonogramu, zanim pojawi się znacznik, wiersz pokazuje „zaraz” zamiast przeskakiwać na następny.

## 0.7.16

- Curse Surge: gdy Turn Back the Surge jest w trakcie, pod nim jest osobny wiersz z miejscem Curse Surge i dopiskiem „trwa” (znacznik na mapie) albo „za X min” (najbliższy start z harmonogramu gry). Klik stawia pin na znaczniku albo pinezkę w miejscu następnego. Czas odświeża się co minutę.

## 0.7.15

- Essence of Malice pokazuje NPC: Er'inye.

## 0.7.14

- Patrolling the Temple pokazuje NPC: Hawkeye Socho.

## 0.7.13

- „Tu jestem” przed „co dalej”: w strefie z niezrobionymi zadaniami (także w trakcie) jej grupa jest na górze ze wszystkimi wierszami, a rekomendacja z innego miejsca schodzi do linii „potem: …”. Quest do oddania gdzie indziej nadal wygrywa.

## 0.7.12

- Zul'jarra's Forces: Patrolling the Temple (96639) i Essence of Malice (96644).

## 0.7.11

- Research Console: Exploring the Void (94790) w The Singularity, dopóki postać nie ma osiągnięcia 62385 Staring Into The Void.
- Stormarion Assault i Stand Your Ground prowadzą do znacznika na mapie (AreaPOI 8422, 8419, 8421), także między szturmami.
- `A:Read` oddaje wszystkie wyniki funkcji, nie tylko 7.

## 0.7.10

- Abundance pokazuje bieżące wydarzenie ze strefą, np. „Harandar Abundance: Herbalism Grotto”, i prowadzi do jego znacznika na mapie.

## 0.7.9

- Znacznik mapy ma pierwszeństwo przed zgadywanym pinem oferty. Gra przyjmowała niewidoczny pin oferty 89268 i Lost Legends nie prowadził.

## 0.7.8

- Lost Legends prowadzi znacznikiem mapy „Legends of the Haranir” (AreaPOI 8423, zapasowo 8463).

## 0.7.7

- WANTED od Shul'ka Li'tya w grupie Hara'ti: pula siedmiu rotujących questów, tytuł bieżącego z dziennika.

## 0.7.6

- Amani Tribe wskakuje na górę w Zul'Aman (mapa 2437).

## 0.7.5

- Rozwinięty Obchód pokazuje wszystkie dostępne wiersze każdej grupy pod jej nazwą, bez samej liczby.

## 0.7.4

- A Nightmarish Task w osobnej grupie Prey, jak w Plumberze.

## 0.7.3

- Grupy zamiast stref: Silvermoon City, Zul'jarra's Forces, Silvermoon Court, Amani Tribe, Hara'ti, The Singularity. Grupa bieżącej strefy nadal idzie na górę (bez Amani Tribe, mapa nieznana).

## 0.7.2

- Void Assaults w przystanku Silvermoon, bo Ranger Captain Lilatha daje quest w mieście, a nie w Quel'Thalas.

## 0.7.1

- Obchód chowa się tylko w instancjach z walką (dungeon, raid, arena, PvP, scenariusz, także delve). Housing to też instancja, a znikał.

## 0.7.0

- Etap 5: Obchód znika od razu w walce, w instancji i przy ograniczeniach addonów (bez czatu), a potem wraca. Przystanek bieżącej strefy jest na górze. Po resecie tygodnia widok sam się odświeża i otwiera. Po ostatnim zadaniu „Tydzień czysty” przez 6 s, potem nic.

## 0.6.14

- Quest w trakcie znowu się podświetla i po kliknięciu zaznacza quest w trackerze. Ikony pinezki dalej nie ma.

## 0.6.13

- Quest w trakcie nie ma ikony pinezki, a kliknięcie go niczego nie robi. Wcześniej podświetlał quest w trackerze.

## 0.6.12

- Zamiast słowa „Weź” klikalne wiersze mają ikonę pinezki z mapy świata. Najechanie rozjaśnia wiersz i zmienia ikonę na złotą.

## 0.6.11

- Prawdziwy tytuł oferty Vaeli (np. „Going Postal”) z zadań mapy housingu, w Obchodzie, w `/cw list` i na pinezce. W housingu pin oferty używa od razu tego ID.

## 0.6.10

- Pinezka przez WaypointUI ma sam tytuł questu, bez NPC i współrzędnych, tak jak pin oferty.

## 0.6.9

- Podsumowanie Obchodu pokazuje tylko czas do resetu, także w spoczynku. Bez liczby zadań i miejsc.

## 0.6.8

- Pin oferty z puli tylko tam, gdzie go zmierzono (`offerMaps`). Vaeli: w housingu pin oferty, wszędzie indziej pinezka w Silvermoon.

## 0.6.7

- Poza mapą pozycji (np. w housingu, mapa 2352) prowadzenie najpierw próbuje pinu oferty, bo pinezka do Silvermoon nie pokazywała drogi. Na mapie pozycji zostaje pinezka.

## 0.6.6

- Prey (polowania u Astalora) zniknął z listy. Tygodniowy obowiązek to A Nightmarish Task.

## 0.6.5

- Ramka Obchodu poszerza się w lewo pod najdłuższy wiersz. Przycinanie przy animacji ucinało początek „Archmage Aethas Sunreaver”.

## 0.6.4

- Animacje 0,42 s: Obchód pojawia się i znika płynnie, a przy rozwijaniu i zwijaniu zmienia wysokość i rozjaśnia albo wygasza dodatkowe wiersze.

## 0.6.3

- Tło Obchodu wygasa miękko na wszystkich brzegach zamiast urywać się prostą krawędzią.

## 0.6.2

- Z włączonym WaypointUI pinezka ma nazwę „NPC · quest” zamiast „Map Pin”. Używamy publicznego `WaypointUIAPI.Navigation.NewUserNavigation`. Bez WaypointUI zostaje natywna pinezka.

## 0.6.1

- Kropki trasy są okrągłe. Maska na kolorowej teksturze dawała w grze kwadraty.
- Pozycja z własnymi współrzędnymi nie zgaduje pinów oferty z puli. Pin 95413 Vaeli prowadził do dzielnicy mieszkalnej przez Stormwind.

## 0.6.0

- Etap 4: widok Obchodu. Po logowaniu pełna trasa przez 12 s, potem miejsce, następny krok i podsumowanie. Najechanie rozwija trasę, kliknięcie wiersza prowadzi, `/cw` chowa i pokazuje widok.
- Usunięty stary panel przy trackerze (`addon/UI/Panel.lua`, `Tab.lua`).

## 0.5.1

- Quest w trakcie nie jest już następnym krokiem, chyba że jest do oddania. Komunikat `/cw go` podaje nazwę questu.

## 0.5.0

- Etap 3: `/cw go` ustawia strzałkę na następny krok: quest z dziennika, pin oferty, pinezka ze współrzędnych.

## 0.4.0

- Etap 2: tabela questów, stany pozycji, trasa według miejsc, `/cw list`.

## 0.3.3

- Zwiadowca nie odczytuje już stanu gry przy wylogowaniu.

## 0.3.2

- Zwiadowca mierzy migawkę 2 s po oddaniu questa, bo pomiar przy wylogowaniu nie obejmował ostatnich zmian.

## 0.3.1

- Zwiadowca pomija ukryte wpisy dziennika i usuwa je z zapisu.

## 0.3.0

- Etap 1: Zwiadowca. Migawka ukończonych questów, różnica po resecie, tygodniowe z dziennika, `/cw scout`.

## 0.2.0

- Etap 0: nowy szkielet, `/cw diag`. Addon nie używa już przycisku ani panelu przy trackerze.

## 0.1.0

- Etap 1: przycisk przy trackerze i pusta ramka przesłaniająca.
