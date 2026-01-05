-- [[ RIVALS OFFICIAL LOADER ]] --
-- TG: t.me/losthq

-- ВНИМАНИЕ: Проверь, что твой ник точно incognitocoded
local raw_url = "https://raw.githubusercontent.com/incognitocoded/RIVALS/main/Main.lua"

local success, result = pcall(function()
    return game:HttpGet(raw_url)
end)

if success then
    loadstring(result)()
else
    -- Если не работает, выведет ошибку в консоль (F9)
    warn("RIVALS Loader Error: " .. tostring(result))
end
