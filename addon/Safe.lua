-- Wartości z API mogą być sekretne, więc logika dostaje je tylko przez te funkcje.
local _, A = ...
local S = {}
A.Safe = S

function S.Value(value)
    if type(issecretvalue) ~= "function" then return nil end
    if issecretvalue(value) then return nil end
    return value
end

function S.Table(value)
    value = S.Value(value)
    if type(value) ~= "table" then return nil end
    if type(canaccesstable) ~= "function" or not canaccesstable(value) then return nil end
    return value
end

function S.Field(value, key)
    if not S.Table(value) then return nil end
    local ok, field = pcall(function() return value[key] end)
    if not ok then return nil end
    return S.Value(field)
end

function S.ID(value)
    value = S.Value(value)
    if type(value) ~= "number" or value <= 0 or value ~= math.floor(value) then return nil end
    return value
end

function S.Number(value)
    value = S.Value(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return nil end
    return value
end

function S.Text(value)
    value = S.Value(value)
    if type(value) ~= "string" then return nil end
    return value
end
