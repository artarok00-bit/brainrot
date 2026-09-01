-- [[ Платформа-невидимка с подъёмом ]]
-- Создаёт платформу под игроком, поднимает на высоту, двигается за ним

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Platform = nil
local IsActive = false
local TargetHeight = 10
local MoveSpeed = 50
local Minimized = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlatformGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "🪄 ПЛАТФОРМА"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(0.82, 0, 0.03, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
MinBtn.TextSize = 18
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.90, 0, 0.03, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseBtn.TextSize = 14
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Кнопка вкл/выкл
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 32)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.05, 0)
ToggleBtn.Text = "ВКЛ"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 14
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- Высота
local HeightLabel = Instance.new("TextLabel")
HeightLabel.Size = UDim2.new(0.4, 0, 0, 18)
HeightLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
HeightLabel.Text = "ВЫСОТА"
HeightLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
HeightLabel.TextSize = 11
HeightLabel.TextXAlignment = Enum.TextXAlignment.Left
HeightLabel.BackgroundTransparency = 1
HeightLabel.Parent = Content

local HeightInput = Instance.new("TextBox")
HeightInput.Size = UDim2.new(0.35, 0, 0, 26)
HeightInput.Position = UDim2.new(0.05, 0, 0.37, 0)
HeightInput.Text = "10"
HeightInput.TextColor3 = Color3.fromRGB(220, 220, 240)
HeightInput.TextSize = 14
HeightInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
HeightInput.BorderSizePixel = 0
HeightInput.Parent = Content

local HeightCorner = Instance.new("UICorner")
HeightCorner.CornerRadius = UDim.new(0, 4)
HeightCorner.Parent = HeightInput

-- Скорость
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0.55, 0, 0.28, 0)
SpeedLabel.Text = "СКОРОСТЬ"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = Content

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.35, 0, 0, 26)
SpeedInput.Position = UDim2.new(0.55, 0, 0.37, 0)
SpeedInput.Text = "50"
SpeedInput.TextColor3 = Color3.fromRGB(220, 220, 240)
SpeedInput.TextSize = 14
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedInput.BorderSizePixel = 0
SpeedInput.Parent = Content

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 4)
SpeedCorner.Parent = SpeedInput

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
StatusLabel.Text = "🟢 Включена"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

-- ===== СОЗДАНИЕ ПЛАТФОРМЫ =====

local function CreatePlatform()
    if Platform then
        Platform:Destroy()
        Platform = nil
    end
    
    local Character = Player.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    -- Невидимая платформа
    Platform = Instance.new("Part")
    Platform.Name = "PlayerPlatform"
    Platform.Size = Vector3.new(6, 0.5, 6)
    Platform.CFrame = RootPart.CFrame - Vector3.new(0, TargetHeight, 0)
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.Transparency = 1
    Platform.Material = Enum.Material.Plastic
    Platform.Parent = workspace
    
    -- Делаем невидимой для других (опционально)
    Platform.LocalTransparencyModifier = 1
end

-- ===== ОБНОВЛЕНИЕ ПОЗИЦИИ ПЛАТФОРМЫ =====

local function UpdatePlatform()
    if not IsActive or not Platform then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    -- Высота над платформой
    local TargetPos = RootPart.Position - Vector3.new(0, TargetHeight, 0)
    
    -- Плавное движение к игроку
    local CurrentPos = Platform.Position
    local NewPos = CurrentPos:Lerp(TargetPos, MoveSpeed / 100)
    
    Platform.CFrame = CFrame.new(NewPos)
end

-- ===== ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ =====

local function Enable()
    if IsActive then return end
    IsActive = true
    
    ToggleBtn.Text = "ВЫКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StatusLabel.Text = "🟢 Включена"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    
    CreatePlatform()
    
    -- Запускаем обновление позиции
    RunService.Heartbeat:Connect(function()
        if IsActive then
            UpdatePlatform()
        end
    end)
    
    -- Поднимаем персонажа
    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = true
            Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        end
    end
end

local function Disable()
    if not IsActive then return end
    IsActive = false
    
    ToggleBtn.Text = "ВКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    StatusLabel.Text = "🔴 Выключена"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    
    if Platform then
        Platform:Destroy()
        Platform = nil
    end
    
    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = false
        end
    end
end

-- ===== ОБНОВЛЕНИЕ ПАРАМЕТРОВ =====

HeightInput.FocusLost:Connect(function()
    local val = tonumber(HeightInput.Text)
    if val and val > 0 then
        TargetHeight = val
        if IsActive then
            CreatePlatform()
        end
    else
        HeightInput.Text = tostring(TargetHeight)
    end
end)

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then
        MoveSpeed = math.min(val, 100)
        SpeedInput.Text = tostring(MoveSpeed)
    else
        SpeedInput.Text = tostring(MoveSpeed)
    end
end)

-- ===== КНОПКИ =====

ToggleBtn.MouseButton1Click:Connect(function()
    if IsActive then
        Disable()
    else
        Enable()
    end
end)

-- Пересоздание платформы при смене персонажа
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if IsActive then
        CreatePlatform()
    end
end)

-- Управление окном
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 260, 0, 30) or UDim2.new(0, 260, 0, 180)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Disable()
    ScreenGui:Destroy()
end)

print("✅ Платформа-невидимка загружена!")
