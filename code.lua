local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")

-- Данные
local noclipActive = false
local minimized = false
local noclipParts = {}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoclipMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
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
titleText.Text = "🧱 NOCLIP"
titleText.TextColor3 = Color3.fromRGB(200, 200, 220)
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.BackgroundTransparency = 1
titleText.Parent = titleBar

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

-- Кнопка включения
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
toggleBtn.Text = "ВЫКЛ"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 15
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = content

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
statusLabel.Text = "⏹ Выключен"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = content

-- ===== ФУНКЦИЯ НОКЛИПА =====

local function enableNoclip()
    noclipActive = true
    local char = player.Character
    if not char then return end
    
    -- Отключаем коллизию у всех частей персонажа
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            table.insert(noclipParts, part)
        end
    end
end

local function disableNoclip()
    noclipActive = false
    local char = player.Character
    if not char then
        noclipParts = {}
        return
    end
    
    -- Включаем коллизию обратно
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    noclipParts = {}
end

-- Следим за появлением новых частей (одежда, аксессуары)
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    if noclipActive then
        enableNoclip()
    end
end)

-- ===== КНОПКИ =====

toggleBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    
    if noclipActive then
        toggleBtn.Text = "ВКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        statusLabel.Text = "✅ Noclip ВКЛЮЧЁН"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        enableNoclip()
    else
        toggleBtn.Text = "ВЫКЛ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "⏹ Noclip ВЫКЛЮЧЁН"
        statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        disableNoclip()
    end
end)

-- Управление окном
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    minBtn.Text = minimized and "+" or "–"
    mainFrame.Size = minimized and UDim2.new(0, 200, 0, 30) or UDim2.new(0, 200, 0, 100)
end)

closeBtn.MouseButton1Click:Connect(function()
    if noclipActive then
        disableNoclip()
    end
    screenGui:Destroy()
end)

-- Горячая клавиша: N (включить/выключить)
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        toggleBtn.MouseButton1Click:Connect()
    end
end)

print("✅ Noclip меню загружено! Нажми N для включения/выключения.")
