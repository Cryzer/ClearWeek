-- Schemat zapisów. Na razie jest tylko wersja 1, więc migracja to założenie albo odmowa.
local _, A = ...
local Store = {}
A.Store = Store

-- Zwraca nil dla zapisu z nowszej wersji: taki zapis zostaje nietknięty.
function Store.Migrate(raw, schema)
    if type(raw) ~= "table" then return {schema = schema} end
    if type(raw.schema) ~= "number" then raw.schema = schema end
    if raw.schema > schema then return nil end
    raw.schema = schema
    return raw
end
