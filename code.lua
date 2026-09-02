-- [[ НАВИГАТОР ПО ТОЧКАМ ]]
-- Добавляй до 500 точек, лети по ним с регулируемой скоростью

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Points = {}
local IsFlying = false
local IsActive = false
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
MainFrame.Size = UDim2.new(0, 280, 0, 250)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -125)
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
TitleText.Text = "🧭 НАВИГАТОР"
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

-- Поле ввода координат
local CoordLabel = Instance.new("TextLabel")
CoordLabel.Size = UDim2.new(0.9, 0, 0, 18)
CoordLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
CoordLabel.Text = "X, Y, Z"
CoordLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
CoordLabel.TextSize = 11
CoordLabel.TextXAlignment = Enum.TextXAlignment.Left
CoordLabel.BackgroundTransparency = 1
CoordLabel.Parent = Content

local CoordInput = Instance.new("TextBox")
CoordInput.Size = UDim2.new(0.6, 0, 0, 28)
CoordInput.Position = UDim2.new(0.05, 0, 0.1, 0)
CoordInput.Text = "0, 0, 0"
CoordInput.TextColor3 = Color3.fromRGB(220, 220, 240)
CoordInput.TextSize = 14
CoordInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CoordInput.BorderSizePixel = 0
CoordInput.Parent = Content

local CoordCorner = Instance.new("UICorner")
CoordCorner.CornerRadius = UDim.new(0, 4)
CoordCorner.Parent = CoordInput

-- Кнопка добавить точку
local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0.25, 0, 0, 28)
AddBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
AddBtn.Text = "➕"
AddBtn.TextColor3 = Color3.new(1, 1, 1)
AddBtn.TextSize = 18
AddBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
AddBtn.BorderSizePixel = 0
AddBtn.Parent = Content

local AddCorner = Instance.new("UICorner")
AddCorner.CornerRadius = UDim.new(0, 4)
AddCorner.Parent = AddBtn

-- Кнопка "Моя позиция"
local MyPosBtn = Instance.new("TextButton")
MyPosBtn.Size = UDim2.new(0.42, 0, 0, 28)
MyPosBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
MyPosBtn.Text = "📍 МОЯ ПОЗИЦИЯ"
MyPosBtn.TextColor3 = Color3.new(1, 1, 1)
MyPosBtn.TextSize = 12
MyPosBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
MyPosBtn.BorderSizePixel = 0
MyPosBtn.Parent = Content

local MyPosCorner = Instance.new("UICorner")
MyPosCorner.CornerRadius = UDim.new(0, 4)
MyPosCorner.Parent = MyPosBtn

-- Кнопка очистить
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.42, 0, 0, 28)
ClearBtn.Position = UDim2.new(0.53, 0, 0.22, 0)
ClearBtn.Text = "🗑 ОЧИСТИТЬ"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.TextSize = 12
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearBtn.BorderSizePixel = 0
ClearBtn.Parent = Content

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 4)
ClearCorner.Parent = ClearBtn

-- Количество точек
local PointsLabel = Instance.new("TextLabel")
PointsLabel.Size = UDim2.new(0.9, 0, 0, 18)
PointsLabel.Position = UDim2.new(0.05, 0, 0.34, 0)
PointsLabel.Text = "ТОЧЕК: 0"
PointsLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
PointsLabel.TextSize = 12
PointsLabel.TextXAlignment = Enum.TextXAlignment.Center
PointsLabel.BackgroundTransparency = 1
PointsLabel.Parent = Content

-- Скорость
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.42, 0)
SpeedLabel.Text = "🚀 СКОРОСТЬ"
SpeedLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = Content

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.35, 0, 0, 28)
SpeedInput.Position = UDim2.new(0.05, 0, 0.48, 0)
SpeedInput.Text = "50"
SpeedInput.TextColor3 = Color3.fromRGB(220, 220, 240)
SpeedInput.TextSize = 14
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedInput.BorderSizePixel = 0
SpeedInput.Parent = Content

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 4)
SpeedCorner.Parent = SpeedInput

-- Кнопки Старт/Стоп
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.42, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
StartBtn.Text = "🚀 СТАРТ"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.TextSize = 14
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
StartBtn.BorderSizePixel = 0
StartBtn.Parent = Content

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 6)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.42, 0, 0, 35)
StopBtn.Position = UDim2.new(0.53, 0, 0.6, 0)
StopBtn.Text = "⏹ СТОП"
StopBtn.TextColor3 = Color3.new(1, 1, 1)
StopBtn.TextSize = 14
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
StopBtn.BorderSizePixel = 0
StopBtn.Parent = Content

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 6)
StopCorner.Parent = StopBtn

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
StatusLabel.Text = "🟢 Готов"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

-- ===== ФУНКЦИИ =====

local function UpdatePointsLabel()
    PointsLabel.Text = "ТОЧЕК: " .. #Points
end

local function AddPoint(position)
    if #Points >= 500 then
        StatusLabel.Text = "❌ Максимум 500 точек!"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end
    table.insert(Points, position)
    UpdatePointsLabel()
    StatusLabel.Text = "✅ Точка " .. #Points .. " добавлена"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
end

local function ClearPoints()
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
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not RootPart or not Humanoid then return end
    
    StatusLabel.Text = "✈️ Летим к точке 1/" .. #Points
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    StartBtn.Text = "⏳ ЛЕТИТ..."
    StartBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
    
    -- Отключаем гравитацию
    Humanoid.PlatformStand = true
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    
    -- Создаём BodyVelocity
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    BodyVelocity.Parent = RootPart
    
    -- BodyGyro для стабилизации
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
        local CurrentSpeed = tonumber(SpeedInput.Text) or 50
        
        if BodyVelocity then
            BodyVelocity.Velocity = Direction * CurrentSpeed
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
    StatusLabel.Text = "⏹ Остановлен"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
end

-- ===== КНОПКИ =====

-- Добавить точку из поля
AddBtn.MouseButton1Click:Connect(function()
    local coords = {}
    for num in string.gmatch(CoordInput.Text, "[-%d.]+") do
        table.insert(coords, tonumber(num))
    end
    if #coords >= 3 then
        AddPoint(Vector3.new(coords[1], coords[2], coords[3]))
    else
        StatusLabel.Text = "❌ Введи X, Y, Z через запятую"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    end
end)

-- Моя позиция
MyPosBtn.MouseButton1Click:Connect(function()
    local Character = Player.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            local pos = RootPart.Position
            CoordInput.Text = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            AddPoint(pos)
        end
    end
end)

-- Очистить
ClearBtn.MouseButton1Click:Connect(function()
    if IsFlying then StopFlight() end
    ClearPoints()
end)

-- Скорость
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then
        Speed = val
        SpeedInput.Text = tostring(Speed)
    else
        SpeedInput.Text = tostring(Speed)
    end
end)

-- Старт
StartBtn.MouseButton1Click:Connect(function()
    if IsFlying then
        StopFlight()
    else
        StartFlight()
    end
end)

-- Стоп
StopBtn.MouseButton1Click:Connect(function()
    StopFlight()
end)

-- Горячая клавиша: F
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.F then
        StartBtn.MouseButton1Click:Connect()
    end
end)

-- Горячая клавиша: G (остановка)
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.G then
        StopBtn.MouseButton1Click:Connect()
    end
end)

-- Перезапуск при смене персонажа
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if IsFlying then
        StopFlight()
    end
end)

-- Управление окном
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 250)
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFlight()
    ScreenGui:Destroy()
end)

print("✅ Навигатор загружен! (до 500 точек, полёт с регулируемой скоростью)")
