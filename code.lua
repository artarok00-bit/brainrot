-- Скрипт для Steal a Brainrot: Меню скорости
local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")

-- Переменные
local speedEnabled = false
local currentSpeed = 16
local minimized = false

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.Text = "⚡ SPEED"
titleText.TextColor3 = Color3.fromRGB(200, 200, 220)
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

-- Кнопка свернуть
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(0.82, 0, 0.03, 0)
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
minBtn.TextSize = 18
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minBtn

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0.90, 0, 0.03, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Контент
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Поле скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
speedLabel.Text = "СКОРОСТЬ"
speedLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = content

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.4, 0, 0, 28)
speedBox.Position = UDim2.new(0.05, 0, 0.2, 0)
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(220, 220, 240)
speedBox.TextSize = 14
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedBox.BorderSizePixel = 0
speedBox.Parent = content

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 4)
speedCorner.Parent = speedBox

-- Кнопка включения
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.4, 0, 0, 28)
toggleBtn.Position = UDim2.new(0.55, 0, 0.2, 0)
toggleBtn.Text = "ВЫКЛ"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 13
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = toggleBtn

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
statusLabel.Text = "⏹ Остановлен"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = content

-- ===== ФУНКЦИИ =====

local function applySpeed()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if speedEnabled then
        humanoid.WalkSpeed = currentSpeed
    else
        humanoid.WalkSpeed = 16
    end
end

-- Обновление скорости при изменении персонажа
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    applySpeed()
end)

-- ===== КНОПКИ =====

-- Обновление скорости из поля
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        currentSpeed = val
        if speedEnabled then
            applySpeed()
        end
        statusLabel.Text = "⚡ Скорость: " .. currentSpeed
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    else
        speedBox.Text = tostring(currentSpeed)
    end
end)

-- Включение/выключение
toggleBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        toggleBtn.Text = "ВКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        statusLabel.Text = "✅ Скорость: " .. currentSpeed
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    else
        toggleBtn.Text = "ВЫКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "⏹ Остановлен"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    end
    
    applySpeed()
end)

-- Управление окном
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    minBtn.Text = minimized and "+" or "–"
    mainFrame.Size = minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 130)
end)

closeBtn.MouseButton1Click:Connect(function()
    -- Отключаем скорость при закрытии
    if speedEnabled then
        speedEnabled = false
        applySpeed()
    end
    screenGui:Destroy()
end)

print("✅ Speed Menu загружен для Steal a Brainrot")
