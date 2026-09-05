-- [[ NOCLIP для Steal an Egg (комбинированный метод) ]]
-- Использует 3 техники одновременно для обхода античита

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local NoclipActive = false
local Minimized = false
local Hotkey = Enum.KeyCode.LeftAlt
local Connection = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoclipGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
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
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "🧱 NOCLIP"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(0.82, 0, 0.03, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.90, 0, 0.03, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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

local OnBtn = Instance.new("TextButton")
OnBtn.Size = UDim2.new(0.4, 0, 0, 32)
OnBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
OnBtn.Text = "✅ ВКЛ"
OnBtn.TextColor3 = Color3.new(1, 1, 1)
OnBtn.TextSize = 14
OnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
OnBtn.BorderSizePixel = 0
OnBtn.Parent = Content

local OnCorner = Instance.new("UICorner")
OnCorner.CornerRadius = UDim.new(0, 6)
OnCorner.Parent = OnBtn

local OffBtn = Instance.new("TextButton")
OffBtn.Size = UDim2.new(0.4, 0, 0, 32)
OffBtn.Position = UDim2.new(0.55, 0, 0.1, 0)
OffBtn.Text = "❌ ВЫКЛ"
OffBtn.TextColor3 = Color3.new(1, 1, 1)
OffBtn.TextSize = 14
OffBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
OffBtn.BorderSizePixel = 0
OffBtn.Parent = Content

local OffCorner = Instance.new("UICorner")
OffCorner.CornerRadius = UDim.new(0, 6)
OffCorner.Parent = OffBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Size = UDim2.new(0.9, 0, 0, 16)
HotkeyLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
HotkeyLabel.Text = "LAlt - переключить"
HotkeyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
HotkeyLabel.TextSize = 10
HotkeyLabel.TextXAlignment = Enum.TextXAlignment.Center
HotkeyLabel.BackgroundTransparency = 1
HotkeyLabel.Parent = Content

-- ===== ОСНОВНАЯ ЛОГИКА =====

local function DisableCollisions()
    local Character = Player.Character
    if not Character then return end
    
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function EnableCollisions()
    local Character = Player.Character
    if not Character then return end
    
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local function NoclipLoop()
    if not NoclipActive then return end
    
    local Character = Player.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    
    -- 1. Отключаем коллизии (постоянно)
    DisableCollisions()
    
    -- 2. Микро-смещение в направлении камеры (по горизонтали)
    local LookDirection = Camera.CFrame.LookVector
    local HorizontalLook = Vector3.new(LookDirection.X, 0, LookDirection.Z).Unit
    
    -- Если персонаж не двигается, добавляем небольшое смещение вперёд
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid and Humanoid.MoveDirection.Magnitude < 0.1 then
        -- Двигаемся вперёд на 0.05 студии за кадр (очень маленький шаг)
        local NewPos = RootPart.Position + HorizontalLook * 0.05
        RootPart.CFrame = CFrame.new(NewPos)
    end
    
    -- 3. Сбрасываем скорость, чтобы античит не видел рывков
    RootPart.Velocity = Vector3.new(0, 0, 0)
    RootPart.RotVelocity = Vector3.new(0, 0, 0)
end

local function EnableNoclip()
    if NoclipActive then return end
    NoclipActive = true
    
    StatusLabel.Text = "🟢 ВКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    
    -- Отключаем коллизии сразу
    DisableCollisions()
    
    -- Запускаем цикл
    if Connection then
        Connection:Disconnect()
    end
    
    Connection = RunService.RenderStepped:Connect(NoclipLoop)
end

local function DisableNoclip()
    if not NoclipActive then return end
    NoclipActive = false
    
    StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    EnableCollisions()
end

local function ToggleNoclip()
    if NoclipActive then
        DisableNoclip()
    else
        EnableNoclip()
    end
end

-- Сброс при смене персонажа
Player.CharacterAdded:Connect(function()
    task.wait(0.1)
    if NoclipActive then
        DisableNoclip()
        EnableNoclip()
    end
end)

-- ===== КНОПКИ =====

OnBtn.MouseButton1Click:Connect(EnableNoclip)
OffBtn.MouseButton1Click:Connect(DisableNoclip)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Hotkey then
        ToggleNoclip()
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 200, 0, 30) or UDim2.new(0, 200, 0, 120)
end)

CloseBtn.MouseButton1Click:Connect(function()
    DisableNoclip()
    ScreenGui:Destroy()
end)

print("✅ Noclip (комбинированный) загружен! Нажми LAlt для переключения.")
