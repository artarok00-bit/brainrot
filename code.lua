-- [[ НАВИГАТОР ]]
-- Кнопки: Старт, Стоп, + (добавить точку), Сбросить точки
-- Количество точек, ползунок скорости до 500

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Points = {}
local IsFlying = false
local CurrentPoint = 1
local Speed = 50
local Minimized = false
local BodyVelocity = nil
local BodyGyro = nil
local FlyConnection = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NavigatorGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 330)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "🧭 НАВИГАТОР"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(0.82, 0, 0.04, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
MinBtn.TextSize = 20
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0.90, 0, 0.04, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseBtn.TextSize = 16
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Кнопка "+" (добавить точку)
local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0.85, 0, 0, 40)
AddBtn.Position = UDim2.new(0.075, 0, 0.03, 0)
AddBtn.Text = "➕ ДОБАВИТЬ ТОЧКУ"
AddBtn.TextColor3 = Color3.new(1, 1, 1)
AddBtn.TextSize = 15
AddBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
AddBtn.BorderSizePixel = 0
AddBtn.Parent = Content

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0, 6)
AddCorner.Parent = AddBtn

-- Кнопка "Сбросить точки"
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.42, 0, 0, 32)
ClearBtn.Position = UDim2.new(0.075, 0, 0.2, 0)
ClearBtn.Text = "🗑 СБРОСИТЬ"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.TextSize = 13
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearBtn.BorderSizePixel = 0
ClearBtn.Parent = Content

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

-- Количество точек
local PointsLabel = Instance.new("TextLabel")
PointsLabel.Size = UDim2.new(0.42, 0, 0, 32)
PointsLabel.Position = UDim2.new(0.51, 0, 0.2, 0)
PointsLabel.Text = "📍 0"
PointsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
PointsLabel.TextSize = 18
PointsLabel.TextXAlignment = Enum.TextXAlignment.Center
PointsLabel.BackgroundTransparency = 1
PointsLabel.Parent = Content

-- Ползунок скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.075, 0, 0.35, 0)
SpeedLabel.Text = "🚀 СКОРОСТЬ"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = Content

local SpeedSlider = Instance.new("ScrollingFrame")
SpeedSlider.Size = UDim2.new(0.55, 0, 0, 22)
SpeedSlider.Position = UDim2.new(0.075, 0, 0.43, 0)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.ScrollBarThickness = 10
SpeedSlider.CanvasSize = UDim2.new(0, 0, 0, 0)
SpeedSlider.Parent = Content

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 11)
SpeedCorner.Parent = SpeedSlider

local SpeedValue = Instance.new("TextLabel")
SpeedValue.Size = UDim2.new(0.2, 0, 0, 22)
SpeedValue.Position = UDim2.new(0.75, 0, 0.43, 0)
SpeedValue.Text = "50"
SpeedValue.TextColor3 = Color3.fromRGB(220, 220, 240)
SpeedValue.TextSize = 16
SpeedValue.TextXAlignment = Enum.TextXAlignment.Right
SpeedValue.BackgroundTransparency = 1
SpeedValue.Parent = Content

-- Ползунок
local function UpdateSpeed()
    local percent = SpeedSlider.CanvasPosition.Y / 100
    Speed = math.floor(percent * 500)
    if Speed < 1 then Speed = 1 end
    SpeedValue.Text = tostring(Speed)
end

SpeedSlider:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSpeed)
SpeedSlider.MouseButton1Down:Connect(UpdateSpeed)

-- ===== КНОПКИ СТАРТ И СТОП (БОЛЬШИЕ, ВИДНЫЕ) =====

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.42, 0, 0, 45)
StartBtn.Position = UDim2.new(0.075, 0, 0.58, 0)
StartBtn.Text = "🚀 СТАРТ"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.TextSize = 18
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
StartBtn.BorderSizePixel = 0
StartBtn.Parent = Content

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.42, 0, 0, 45)
StopBtn.Position = UDim2.new(0.51, 0, 0.58, 0)
StopBtn.Text = "⏹ СТОП"
StopBtn.TextColor3 = Color3.new(1, 1, 1)
StopBtn.TextSize = 18
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StopBtn.BorderSizePixel = 0
StopBtn.Parent = Content

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopBtn

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
StatusLabel.Text = "🟢 Готов"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

-- ===== ФУНКЦИИ =====

local function UpdatePointsLabel()
    PointsLabel.Text = "📍 " .. #Points
end

local function AddPoint()
    if #Points >= 500 then
        StatusLabel.Text = "❌ Максимум 500 точек!"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    local Character = Player.Character
    if not Character then
        StatusLabel.Text = "❌ Персонаж не найден"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then
        StatusLabel.Text = "❌ RootPart не найден"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    local pos = RootPart.Position
    table.insert(Points, pos)
    UpdatePointsLabel()
    StatusLabel.Text = "✅ Точка " .. #Points .. " добавлена"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
end

local function ClearPoints()
    if IsFlying then StopFlight() end
    Points = {}
    CurrentPoint = 1
    UpdatePointsLabel()
    StatusLabel.Text = "🗑 Точки очищены"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
end

-- ===== ПОЛЁТ =====

local function StartFlight()
    if #Points == 0 then
        StatusLabel.Text = "❌ Нет точек!"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    if IsFlying then return end
    IsFlying = true
    CurrentPoint = 1
    
    local Character = Player.Character
    if not Character then
        IsFlying = false
        StatusLabel.Text = "❌ Персонаж не найден"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not RootPart or not Humanoid then
        IsFlying = false
        StatusLabel.Text = "❌ Ошибка персонажа"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    
    StatusLabel.Text = "✈️ Летим к точке 1/" .. #Points
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    StartBtn.Text = "⏳ ЛЕТИТ..."
    StartBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
    
    Humanoid.PlatformStand = true
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    BodyVelocity.Parent = RootPart
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.CFrame = RootPart.CFrame
    BodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    BodyGyro.Parent = RootPart
    
    if FlyConnection then
        FlyConnection:Disconnect()
    end
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not IsFlying then return end
        if not Character or not RootPart then
            StopFlight()
            return
        end
        
        local CurrentPos = RootPart.Position
        local TargetPos = Points[CurrentPoint]
        local Distance = (TargetPos - CurrentPos).Magnitude
        
        if Distance < 3 then
            CurrentPoint = CurrentPoint + 1
            if CurrentPoint > #Points then
                StatusLabel.Text = "✅ Маршрут пройден!"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
                StopFlight()
                return
            end
            StatusLabel.Text = "✈️ Точка " .. CurrentPoint .. "/" .. #Points
            return
        end
        
        local Direction = (TargetPos - CurrentPos).Unit
        
        if BodyVelocity then
            BodyVelocity.Velocity = Direction * Speed
        end
        if BodyGyro then
            BodyGyro.CFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + Direction)
        end
    end)
end

local function StopFlight()
    IsFlying = false
    
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    
    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        end
    end
    
    StartBtn.Text = "🚀 СТАРТ"
    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    if StatusLabel.Text ~= "✅ Маршрут пройден!" then
        StatusLabel.Text = "⏹ Остановлен"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
    end
end

-- ===== КНОПКИ =====

AddBtn.MouseButton1Click:Connect(AddPoint)
ClearBtn.MouseButton1Click:Connect(ClearPoints)
StartBtn.MouseButton1Click:Connect(function()
    if IsFlying then StopFlight() else StartFlight() end
end)
StopBtn.MouseButton1Click:Connect(StopFlight)

-- Горячие клавиши
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.F then
        StartBtn.MouseButton1Click:Connect()
    end
    if Input.KeyCode == Enum.KeyCode.G then
        StopBtn.MouseButton1Click:Connect()
    end
    if Input.KeyCode == Enum.KeyCode.N then
        AddBtn.MouseButton1Click:Connect()
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if IsFlying then StopFlight() end
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 280, 0, 35) or UDim2.new(0, 280, 0, 330)
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFlight()
    ScreenGui:Destroy()
end)

print("✅ Навигатор загружен!")
