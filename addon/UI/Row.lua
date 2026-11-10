-- Jeden wiersz Obchodu: tekst wyrównany do linii trasy (domyślnie do prawej). Mysz łapią tylko wiersze, świat obok zostaje klikalny.
local _, A = ...
local Row = {}
A.Row = Row

-- Ikony przycisku „Map Pin” z mapy świata (WaypointLocationDataProvider.xml:9, SharedMapPoiTemplates.xml:38).
local PIN = "Waypoint-MapPin-Untracked"
local PIN_HOVER = "Waypoint-MapPin-Tracked"
local ICON_GAP = 4
-- Pinezka przygaszona, pełna po najechaniu: przy kilkunastu wierszach pełne były zbyt gęste
-- (właściciel 2026-11-08).
local ICON_REST = 0.45

local function fontPath()
    local path = A.Safe.Text(A:Read(GameFontNormal, "GetFont", GameFontNormal))
    return path or "Fonts\\FRIZQT__.TTF"
end
Row.Font = fontPath

-- Podświetlenie: kolor bliżej bieli i złota pinezka, żeby było widać, że wiersz da się kliknąć.
local function highlight(button, on)
    if not button.clickable then return end
    local c = button.color
    local k = on and 0.5 or 0
    button.label:SetTextColor(c[1] + (1 - c[1]) * k, c[2] + (1 - c[2]) * k, c[3] + (1 - c[3]) * k)
    if button.pin then
        button.icon:SetAtlas(on and PIN_HOVER or PIN)
        button.icon:SetAlpha(on and 1 or ICON_REST)
    end
end

function Row.Create(parent, handlers)
    local button = CreateFrame("Button", nil, parent)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local label = button:CreateFontString(nil, "OVERLAY")
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    button.label = label
    local icon = button:CreateTexture(nil, "OVERLAY")
    button.icon = icon
    button:SetScript("OnClick", function(self, mouse) handlers.click(self.line, mouse, self) end)
    button:SetScript("OnEnter", function(self)
        highlight(self, true)
        handlers.enter(self)
    end)
    button:SetScript("OnLeave", function(self)
        highlight(self, false)
        handlers.leave()
    end)
    return button
end

-- Zwraca szerokość wiersza razem z ikoną. mirrored: tekst od lewej, pinezka po prawej (UI/Place.lua).
function Row.Set(button, line, color, size, height, mirrored)
    local near, far = mirrored and "LEFT" or "RIGHT", mirrored and "RIGHT" or "LEFT"
    button.label:ClearAllPoints()
    button.label:SetPoint(near)
    button.label:SetJustifyH(near)
    button.icon:ClearAllPoints()
    button.icon:SetPoint(near, button.label, far, mirrored and ICON_GAP or -ICON_GAP, 0)
    button.line = line
    button.color = color
    button.clickable = line.row ~= nil
    button.pin = line.pin and true or false
    button.label:SetFont(fontPath(), size, "")
    button.label:SetTextColor(color[1], color[2], color[3])
    button.label:SetText(line.text)
    local width = (A.Safe.Number(button.label:GetStringWidth()) or 0) + 4
    if button.pin then
        local iconSize = size + 2
        button.icon:SetSize(iconSize, iconSize)
        button.icon:SetAtlas(PIN)
        button.icon:SetAlpha(ICON_REST)
        button.icon:Show()
        width = width + iconSize + ICON_GAP
    else
        button.icon:Hide()
    end
    button:SetSize(width, height)
    button:Show()
    return width
end
