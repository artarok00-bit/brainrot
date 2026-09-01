-- [[ Steal a Brainrot - Ноклип (Безопасный обход античита) ]]
-- Работает через мягкое проталкивание сквозь стены

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local NoclipEnabled = false
local BodyVelocity = nil
local LoopConnection = nil
local Minimized = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoclipGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 130)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "🧱 NO CLIP"
TitleText.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 25, 0, 25)
MinButton.Position = UDim2.new(0.82, 0, 0.03, 0)
MinButton.Text = "–"
MinButton.TextColor3 = Color3.fromRGB(200, 200, 220)
MinButton.TextSize = 18
MinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinButton.BorderSizePixel = 0
MinButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(0.90, 0, 0.03, 0)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseButton.TextSize = 14
CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleButton.Text = "ВЫКЛ"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
StatusLabel.Text = "⏹ Выключен"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

-- ===== ФУНКЦИЯ БЕЗОПАСНОГО НОКЛИПА =====

local function EnableNoclip()
    NoclipEnabled = true
    ToggleButton.Text = "ВКЛ"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    StatusLabel.Text = "✅ Noclip ВКЛЮЧЁН"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    
    -- Отключаем все коллизии на время
    for _, Part in pairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") then
            Part.CanCollide = false
        end
    end
    
    -- Основной цикл, обходящий античит через постоянное принудительное движение
    if LoopConnection then LoopConnection:Disconnect() end
    LoopConnection = RunService.Stepped:Connect(function()
        if NoclipEnabled and Character and RootPart then
            -- Принудительно перемещаем RootPart немного вперёд, чтобы "продавить" стены
            local MoveDirection = RootPart.CFrame.LookVector * 0.5
            RootPart.CFrame = RootPart.CFrame + MoveDirection
        end
    end)
end

local function DisableNoclip()
    NoclipEnabled = false
    ToggleButton.Text = "ВЫКЛ"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StatusLabel.Text = "⏹ Noclip ВЫКЛЮЧЁН"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    
    if LoopConnection then
        LoopConnection:Disconnect()
        LoopConnection = nil
    end
    
    -- Включаем коллизии обратно
    if Character then
        for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = true
            end
        end
    end
end

-- Следим за сменой персонажа
Player.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    if NoclipEnabled then
        -- Перезапускаем ноклип, чтобы применить его к новому персонажу
        DisableNoclip()
        EnableNoclip()
    end
end)

-- ===== КНОПКИ =====

ToggleButton.MouseButton1Click:Connect(function()
    if NoclipEnabled then
        DisableNoclip()
    else
        EnableNoclip()
    end
end)

MinButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinButton.Text = Minimized and "+" or "–"
    MainFrame.Size = Minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 130)
end)

CloseButton.MouseButton1Click:Connect(function()
    if NoclipEnabled then
        DisableNoclip()
    end
    ScreenGui:Destroy()
end)

-- Горячая клавиша: N
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.N then
        ToggleButton.MouseButton1Click:Connect()
    end
end)

print("✅ Noclip (безопасный) загружен! Нажми N для включения/выключения.")
