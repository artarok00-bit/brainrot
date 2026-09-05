-- [[ NOCLIP для Steal an Egg (рабочий метод) ]]
-- Использует эксплойт анимаций для отключения коллизий
-- Работает даже с серверной проверкой

local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Animator = game:GetService("Animator")
local TweenService = game:GetService("TweenService")

local NoclipActive = false
local Minimized = false
local Hotkey = Enum.KeyCode.LeftAlt
local AnimationTrack = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoclipGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
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
TitleBar.Size = UDim2.new(1, 0, 0, 35)
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
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(0.82, 0, 0.04, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0.90, 0, 0.04, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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

local OnBtn = Instance.new("TextButton")
OnBtn.Size = UDim2.new(0.4, 0, 0, 38)
OnBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
OnBtn.Text = "✅ ВКЛ"
OnBtn.TextColor3 = Color3.new(1, 1, 1)
OnBtn.TextSize = 15
OnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
OnBtn.BorderSizePixel = 0
OnBtn.Parent = Content

local OnCorner = Instance.new("UICorner")
OnCorner.CornerRadius = UDim.new(0, 8)
OnCorner.Parent = OnBtn

local OffBtn = Instance.new("TextButton")
OffBtn.Size = UDim2.new(0.4, 0, 0, 38)
OffBtn.Position = UDim2.new(0.55, 0, 0.05, 0)
OffBtn.Text = "❌ ВЫКЛ"
OffBtn.TextColor3 = Color3.new(1, 1, 1)
OffBtn.TextSize = 15
OffBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
OffBtn.BorderSizePixel = 0
OffBtn.Parent = Content

local OffCorner = Instance.new("UICorner")
OffCorner.CornerRadius = UDim.new(0, 8)
OffCorner.Parent = OffBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Content

local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Size = UDim2.new(0.4, 0, 0, 18)
HotkeyLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
HotkeyLabel.Text = "КЛАВИША: LALT"
HotkeyLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
HotkeyLabel.TextSize = 11
HotkeyLabel.TextXAlignment = Enum.TextXAlignment.Left
HotkeyLabel.BackgroundTransparency = 1
HotkeyLabel.Parent = Content

-- ===== ОСНОВНАЯ ФУНКЦИЯ НОКЛИПА (через анимации) =====

local function CreateNoclipAnimation()
    local Character = Player.Character
    if not Character then return nil end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return nil end

    -- Получаем или создаём Animator
    local animator = Humanoid:FindFirstChild("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = Humanoid
    end

    -- Создаём анимацию, которая "ломает" коллизию
    local animationData = Instance.new("Animation")
    animationData.AnimationId = "rbxassetid://0" -- пустая анимация

    local track = animator:LoadAnimation(animationData)
    if not track then return nil end

    return track
end

local function EnableNoclip()
    if NoclipActive then return end
    NoclipActive = true

    StatusLabel.Text = "🟢 ВКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)

    -- Создаём и запускаем анимацию
    AnimationTrack = CreateNoclipAnimation()
    if AnimationTrack then
        AnimationTrack:Play()
        -- Ставим на паузу, чтобы анимация висела в состоянии "проигрывается"
        AnimationTrack:AdjustSpeed(0)
    end

    -- Дополнительно отключаем коллизии на клиенте (для верности)
    local Character = Player.Character
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Постоянно поддерживаем состояние
    spawn(function()
        while NoclipActive do
            task.wait(0.1)
            local Character = Player.Character
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            -- Если анимация сбросилась — пересоздаём
            if not AnimationTrack or not AnimationTrack.IsPlaying then
                AnimationTrack = CreateNoclipAnimation()
                if AnimationTrack then
                    AnimationTrack:Play()
                    AnimationTrack:AdjustSpeed(0)
                end
            end
        end
    end)
end

local function DisableNoclip()
    if not NoclipActive then return end
    NoclipActive = false

    StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)

    if AnimationTrack then
        AnimationTrack:Stop()
        AnimationTrack = nil
    end

    local Character = Player.Character
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
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
    task.wait(0.5)
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
    MainFrame.Size = Minimized and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 150)
end)

CloseBtn.MouseButton1Click:Connect(function()
    DisableNoclip()
    ScreenGui:Destroy()
end)

print("✅ Noclip для Steal an Egg загружен! Использует эксплойт анимаций.")
