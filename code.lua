-- [[ АНТИ-РАГДОЛ ]]
-- Блокирует состояние ragdoll, моментально возвращая контроль над персонажем

local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local IsActive = false
local Minimized = false
local CheckConnection = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiRagdollGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
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
TitleText.Text = "💪 АНТИ-РАГДОЛ"
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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleBtn.Text = "ВКЛ"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 15
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
StatusLabel.Text = "🔴 Выключен"
StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

-- ===== ФУНКЦИЯ АНТИ-РАГДОЛА =====

local function AntiRagdoll()
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    -- Проверяем состояние ragdoll
    if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
        -- Принудительно возвращаем в нормальное состояние
        Humanoid.PlatformStand = true
        task.wait(0.05)
        Humanoid.PlatformStand = false
        
        -- Сбрасываем физику
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part ~= Character:FindFirstChild("HumanoidRootPart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- Возвращаем корневую часть
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            RootPart.Velocity = Vector3.new(0, 0, 0)
            RootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        -- Переключаем состояние в Running
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- ===== ВКЛЮЧЕНИЕ =====

local function Enable()
    if IsActive then return end
    IsActive = true
    
    ToggleBtn.Text = "ВЫКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StatusLabel.Text = "🟢 Включен"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    
    -- Запускаем проверку
    if CheckConnection then
        CheckConnection:Disconnect()
    end
    
    CheckConnection = RunService.Heartbeat:Connect(function()
        if IsActive then
            AntiRagdoll()
        end
    end)
end

-- ===== ВЫКЛЮЧЕНИЕ =====

local function Disable()
    if not IsActive then return end
    IsActive = false
    
    ToggleBtn.Text = "ВКЛ"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    StatusLabel.Text = "🔴 Выключен"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    
    if CheckConnection then
        CheckConnection:Disconnect()
        CheckConnection = nil
    end
end

-- ===== КНОПКИ =====

ToggleBtn.MouseButton1Click:Connect(function()
    if IsActive then
        Disable()
    else
        Enable()
    end
end)

-- Горячая клавиша: R
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.R then
        ToggleBtn.MouseButton1Click:Connect()
    end
end)

-- Управление окном
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 120)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Disable()
    ScreenGui:Destroy()
end)

print("✅ Анти-рагдол загружен! Нажми R для включения/выключения.")
