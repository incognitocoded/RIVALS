-- [[ RIVALS OFFICIAL LOADER ]] --
-- TG: t.me/losthq

local raw_url = "https://raw.githubusercontent.com/incognitocoded/RIVALS/main/Main.lua"

local success, result = pcall(function()
    return game:HttpGet(raw_url)
end)

if success then
    -- Запуск зашифрованного Main.lua
    loadstring(result)()
else
    -- Ошибка выводится в консоль (F9)
    warn("RIVALS Loader Error: " --[] .. tostring(result))
end
