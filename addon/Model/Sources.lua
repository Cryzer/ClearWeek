-- Rejestr kategorii. Każde źródło oddaje te same wiersze, więc trasa nie zna ich pochodzenia.
local _, A = ...
local Sources = {list = {}}
A.Sources = Sources

function Sources:Register(name, source)
    self.list[#self.list + 1] = {name = name, source = source}
end

function Sources:Rows()
    local rows = {}
    for _, entry in ipairs(self.list) do
        for _, row in ipairs(entry.source.Rows()) do rows[#rows + 1] = row end
    end
    return rows
end
