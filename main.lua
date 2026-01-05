local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

-- [[ ЧИСТАЯ АНИМАЦИЯ LOSTHUB ]] --
local function PlayCleanIntro()
    local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    -- Мягкое размытие
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    TweenService:Create(blur, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {Size = 20}):Play()
    
    -- Текст LostHub
    local text = Instance.new("TextLabel", screenGui)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "LostHub"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.Unknown -- Современный тонкий шрифт
    text.TextSize = 1
    text.TextTransparency = 1

    -- Анимация появления (как в твоем первом запросе на флай)
    text.TextTransparency = 0
    TweenService:Create(text, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {TextSize = 80}):Play()
    
    task.wait(2)
    
    -- Плавный выход
    TweenService:Create(blur, TweenInfo.new(1, Enum.EasingStyle.Quint), {Size = 0}):Play()
    TweenService:Create(text, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 1, TextSize = 110}):Play()
    
    task.wait(1)
    blur:Destroy()
    screenGui:Destroy()
end

PlayCleanIntro()

-- [[ ЛОГИКА И НАСТРОЙКИ ]] --
local Config = {
    Aimbot = false,
    WallCheck = false,
    TargetPart = "Head",
    FOV = 150,
    ShowFOV = false,
    Chams = false
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.8

local function IsVisible(part)
    if not Config.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {lp.Character, camera}
    local ray = workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 1000, params)
    return ray and ray.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestTarget()
    local closestDist = Config.FOV
    local target = nil
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild(Config.TargetPart) then
            local part = player.Character[Config.TargetPart]
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            
            if onScreen and IsVisible(part) then
                local dist = (Vector2.new(mouseLocation.X, mouseLocation.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    target = part
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local mouseLocation = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.FOV
    FOVCircle.Position = mouseLocation

    if Config.Aimbot then
        local target = GetClosestTarget()
        if target then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
    end
end)

local function ApplyChams(player)
    local function Update()
        if player.Character then
            local highlight = player.Character:FindFirstChild("LostHighlight") or Instance.new("Highlight", player.Character)
            highlight.Name = "LostHighlight"
            highlight.Enabled = Config.Chams
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
    player.CharacterAdded:Connect(Update)
    Update()
end

for _, p in pairs(Players:GetPlayers()) do if p ~= lp then ApplyChams(p) end end
Players.PlayerAdded:Connect(ApplyChams)

-- [[ ИНТЕРФЕЙС ]] --
local Window = Fluent:CreateWindow({
    Title = "LOST",
    SubTitle = "Rivals Precision",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

Tabs.Combat:AddToggle("Aim", {Title = "Активировать Аимбот", Default = false}):OnChanged(function()
    Config.Aimbot = Fluent.Options.Aim.Value
end)

Tabs.Combat:AddToggle("WCheck", {Title = "Wall Check", Default = false}):OnChanged(function()
    Config.WallCheck = Fluent.Options.WCheck.Value
end)

Tabs.Combat:AddDropdown("Part", {
    Title = "Цель",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(v) Config.TargetPart = v end
})

Tabs.Combat:AddSlider("FOV", {
    Title = "FOV Radius",
    Default = 150, Min = 10, Max = 800, Rounding = 1,
    Callback = function(v) Config.FOV = v end
})

Tabs.Combat:AddToggle("SFOV", {Title = "Показывать круг", Default = false}):OnChanged(function()
    Config.ShowFOV = Fluent.Options.SFOV.Value
end)

Tabs.Visuals:AddToggle("Chams", {Title = "Силуэты (ВХ)", Default = false}):OnChanged(function()
    Config.Chams = Fluent.Options.Chams.Value
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("LostHighlight") then
            p.Character.LostHighlight.Enabled = Config.Chams
        end
    end
end)

Window:SelectTab(1)
