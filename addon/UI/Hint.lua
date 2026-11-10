-- Podpowiedź po najechaniu: jedna linia o tym, co zrobi klik. Własna ramka, bez GameTooltip,
-- żeby nie dotykać okien Blizzarda. Jest dzieckiem przycisku, więc ma jego skalę i znika razem
-- z nim w walce, w instancji i po błędzie.
local _, A = ...
local T = A.Theme
local Hint = {}
A.Hint = Hint

local function create(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("TOOLTIP")
    -- Przycisk w spoczynku jest przygaszony, a podpowiedź ma być czytelna.
    frame:SetIgnoreParentAlpha(true)
    frame:EnableMouse(false)
    local c = T.colors.shade
    local back = frame:CreateTexture(nil, "BACKGROUND")
    back:SetAllPoints()
    back:SetColorTexture(c[1], c[2], c[3], T.hintAlpha)
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER")
    label:SetFont(A.Row.Font(), T.hintSize, "")
    label:SetTextColor(unpack(T.colors.white))
    Hint.frame, Hint.label = frame, label
end

-- above: nad kotwicą (przycisk), inaczej obok wiersza od strony tekstu, poza tekstem trasy.
-- Przy trackerze po lewej (View.mirrored) wszystko jest odbite.
function Hint.Show(anchor, text, above)
    if not (text and A.View.toggle) then Hint.Hide(); return end
    if not Hint.frame then create(A.View.toggle) end
    Hint.owner, Hint.above = anchor, above
    Hint.label:SetText(text)
    local width = (A.Safe.Number(Hint.label:GetStringWidth()) or 0) + 2 * T.hintPad
    Hint.frame:SetSize(width, T.hintHeight)
    Hint.frame:ClearAllPoints()
    local mirrored = A.View.mirrored
    local near, far = mirrored and "LEFT" or "RIGHT", mirrored and "RIGHT" or "LEFT"
    if above then
        Hint.frame:SetPoint("BOTTOM" .. near, anchor, "TOP" .. near, 0, T.hintGap)
    else
        Hint.frame:SetPoint(near, anchor, far, mirrored and T.hintGap or -T.hintGap, 0)
    end
    Hint.frame:Show()
end

function Hint.Hide()
    Hint.owner = nil
    if Hint.frame then Hint.frame:Hide() end
end

-- Po przebudowie linii ten sam wiersz może pokazywać inną pozycję albo zniknąć.
function Hint.Refresh()
    local owner = Hint.owner
    if not owner or Hint.above then return end
    if owner:IsShown() then Hint.Show(owner, owner.line.hint) else Hint.Hide() end
end
