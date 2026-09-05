-- [[ НОКЛИП + БЕССМЕРТИЕ (с удалением монстров) ]]
-- Два режима в одном меню: проход сквозь стены + полная неуязвимость

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Состояния
local NoclipActive = false
local GodActive = false
local Minimized = false

-- Ноклип переменные
local NoclipConnection = nil
local StepSize = 0.15
local FrameCounter = 0

-- Горячие клавиши
local NoclipKey = Enum.KeyCode.N
local GodKey = Enum.KeyCode.G

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.4
Shadow.BorderSizePixel = 0
Shadow.Parent = MainFrame
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 16)
ShadowCorner.Parent = Shadow

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
})
TitleGradient.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.Text = "🛡️🧱 ULTIMATE"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.GothamSemibold
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.82, 0, 0.08, 0)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 22
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.90, 0, 0.08, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- === Секция Ноклипа ===
local NoclipSection = Instance.new("Frame")
NoclipSection.Size = UDim2.new(1, 0, 0, 75)
NoclipSection.Position = UDim2.new(0, 0, 0, 5)
NoclipSection.BackgroundTransparency = 1
NoclipSection.Parent = Content

local NoclipLabel = Instance.new("TextLabel")
NoclipLabel.Size = UDim2.new(0.5, 0, 0, 20)
NoclipLabel.Position = UDim2.new(0.05, 0, 0, 0)
NoclipLabel.Text = "🧱 НОКЛИП"
NoclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipLabel.TextSize = 14
NoclipLabel.TextXAlignment = Enum.TextXAlignment.Left
NoclipLabel.BackgroundTransparency = 1
NoclipLabel.Font = Enum.Font.GothamSemibold
NoclipLabel.Parent = NoclipSection

local NoclipStatus = Instance.new("TextLabel")
NoclipStatus.Size = UDim2.new(0.3, 0, 0, 18)
NoclipStatus.Position = UDim2.new(0.65, 0, 0.02, 0)
NoclipStatus.Text = "🔴 ВЫКЛ"
NoclipStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
NoclipStatus.TextSize = 13
NoclipStatus.TextXAlignment = Enum.TextXAlignment.Right
NoclipStatus.BackgroundTransparency = 1
NoclipStatus.Font = Enum.Font.Gotham
NoclipStatus.Parent = NoclipSection

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.85, 0, 0, 30)
NoclipBtn.Position = UDim2.new(0.075, 0, 0.25, 0)
NoclipBtn.Text = "ВКЛЮЧИТЬ"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.TextSize = 14
NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
NoclipBtn.BorderSizePixel = 0
NoclipBtn.Font = Enum.Font.GothamSemibold
NoclipBtn.Parent = NoclipSection
local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 8)
NoclipCorner.Parent = NoclipBtn

local NoclipHotkey = Instance.new("TextLabel")
NoclipHotkey.Size = UDim2.new(0.4, 0, 0, 16)
NoclipHotkey.Position = UDim2.new(0.075, 0, 0.7, 0)
NoclipHotkey.Text = "⌨️ N"
NoclipHotkey.TextColor3 = Color3.fromRGB(160, 160, 180)
NoclipHotkey.TextSize = 11
NoclipHotkey.TextXAlignment = Enum.TextXAlignment.Left
NoclipHotkey.BackgroundTransparency = 1
NoclipHotkey.Font = Enum.Font.Gotham
NoclipHotkey.Parent = NoclipSection

-- === Секция Бессмертия ===
local GodSection = Instance.new("Frame")
GodSection.Size = UDim2.new(1, 0, 0, 75)
GodSection.Position = UDim2.new(0, 0, 0, 85)
GodSection.BackgroundTransparency = 1
GodSection.Parent = Content

local GodLabel = Instance.new("TextLabel")
GodLabel.Size = UDim2.new(0.5, 0, 0, 20)
GodLabel.Position = UDim2.new(0.05, 0, 0, 0)
GodLabel.Text = "🛡️ БЕССМЕРТИЕ"
GodLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GodLabel.TextSize = 14
GodLabel.TextXAlignment = Enum.TextXAlignment.Left
GodLabel.BackgroundTransparency = 1
GodLabel.Font = Enum.Font.GothamSemibold
GodLabel.Parent = GodSection

local GodStatus = Instance.new("TextLabel")
GodStatus.Size = UDim2.new(0.3, 0, 0, 18)
GodStatus.Position = UDim2.new(0.65, 0, 0.02, 0)
GodStatus.Text = "🔴 ВЫКЛ"
GodStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
GodStatus.TextSize = 13
GodStatus.TextXAlignment = Enum.TextXAlignment.Right
GodStatus.BackgroundTransparency = 1
GodStatus.Font = Enum.Font.Gotham
GodStatus.Parent = GodSection

local GodBtn = Instance.new("TextButton")
GodBtn.Size = UDim2.new(0.85, 0, 0, 30)
GodBtn.Position = UDim2.new(0.075, 0, 0.25, 0)
GodBtn.Text = "ВКЛЮЧИТЬ"
GodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GodBtn.TextSize = 14
GodBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
GodBtn.BorderSizePixel = 0
GodBtn.Font = Enum.Font.GothamSemibold
GodBtn.Parent = GodSection
local GodCorner = Instance.new("UICorner")
GodCorner.CornerRadius = UDim.new(0, 8)
GodCorner.Parent = GodBtn

local GodHotkey = Instance.new("TextLabel")
GodHotkey.Size = UDim2.new(0.4, 0, 0, 16)
GodHotkey.Position = UDim2.new(0.075, 0, 0.7, 0)
GodHotkey.Text = "⌨️ G"
GodHotkey.TextColor3 = Color3.fromRGB(160, 160, 180)
GodHotkey.TextSize = 11
GodHotkey.TextXAlignment = Enum.TextXAlignment.Left
GodHotkey.BackgroundTransparency = 1
GodHotkey.Font = Enum.Font.Gotham
GodHotkey.Parent = GodSection

-- === ФУНКЦИИ НОКЛИПА ===

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
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end

    if Humanoid.MoveDirection.Magnitude < 0.1 then return end

    local Camera = workspace.CurrentCamera
    if not Camera then return end

    DisableCollisions()

    local LookDirection = Camera.CFrame.LookVector
    local HorizontalLook = Vector3.new(LookDirection.X, 0, LookDirection.Z).Unit
    if HorizontalLook.Magnitude < 0.1 then
        HorizontalLook = Vector3.new(1, 0, 0)
    end

    FrameCounter = FrameCounter + 1
    if FrameCounter % 2 == 0 then
        local NewPos = RootPart.Position + HorizontalLook * StepSize
        RootPart.CFrame = CFrame.new(NewPos)
    end

    RootPart.Velocity = RootPart.Velocity * 0.9
    RootPart.RotVelocity = RootPart.RotVelocity * 0.9
end

local function EnableNoclip()
    if NoclipActive then return end
    NoclipActive = true
    NoclipBtn.Text = "ВЫКЛЮЧИТЬ"
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    NoclipStatus.Text = "🟢 ВКЛ"
    NoclipStatus.TextColor3 = Color3.fromRGB(100, 200, 100)
    DisableCollisions()
    if NoclipConnection then NoclipConnection:Disconnect() end
    FrameCounter = 0
    NoclipConnection = RunService.RenderStepped:Connect(NoclipLoop)
end

local function DisableNoclip()
    if not NoclipActive then return end
    NoclipActive = false
    NoclipBtn.Text = "ВКЛЮЧИТЬ"
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    NoclipStatus.Text = "🔴 ВЫКЛ"
    NoclipStatus.TextColor3 = Color3.fromRGB(200, 80, 80)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    EnableCollisions()
end

local function ToggleNoclip()
    if NoclipActive then DisableNoclip() else EnableNoclip() end
end

-- === ФУНКЦИИ БЕССМЕРТИЯ (как в твоём коде) ===

local function RemoveMonsters()
    local Character = Player.Character
    local monstersFound = 0

    local function findAndRemove(obj)
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "monster") or
               string.find(name, "boss") or
               string.find(name, "chase") or
               string.find(name, "kill") or
               string.find(name, "deadly") or
               string.find(name, "enemy") or
               string.find(name, "zombie") then
                if obj ~= Character and obj.Parent ~= Character then
                    pcall(function() obj:Destroy() end)
                    monstersFound = monstersFound + 1
                end
            end
        end
        for _, child in pairs(obj:GetChildren()) do
            findAndRemove(child)
        end
    end

    pcall(function()
        findAndRemove(workspace)
    end)

    pcall(function()
        local killParts = workspace:GetDescendants()
        for _, part in pairs(killParts) do
            if part:IsA("BasePart") and part.CanCollide == false and part.Transparency > 0.5 then
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (part.Position - Character.HumanoidRootPart.Position).Magnitude
                    if dist > 50 then
                        pcall(function() part:Destroy() end)
                    end
                end
            end
        end
    end)

    return monstersFound
end

local function EnableGodMode()
    if GodActive then return end
    GodActive = true
    GodBtn.Text = "ВЫКЛЮЧИТЬ"
    GodBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    GodStatus.Text = "🟢 ВКЛ"
    GodStatus.TextColor3 = Color3.fromRGB(100, 200, 100)

    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
    end

    local count = RemoveMonsters()
    if count > 0 then
        GodStatus.Text = "🟢 УДАЛЕНО " .. count .. " МОНСТРОВ"
        GodStatus.TextColor3 = Color3.fromRGB(100, 200, 100)
        task.wait(0.8)
        GodStatus.Text = "🟢 ВКЛ"
        GodStatus.TextColor3 = Color3.fromRGB(100, 200, 100)
    end
end

local function DisableGodMode()
    if not GodActive then return end
    GodActive = false
    GodBtn.Text = "ВКЛЮЧИТЬ"
    GodBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    GodStatus.Text = "🔴 ВЫКЛ"
    GodStatus.TextColor3 = Color3.fromRGB(200, 80, 80)

    local Character = Player.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.MaxHealth = 100
            Humanoid.Health = 100
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end

local function ToggleGod()
    if GodActive then DisableGodMode() else EnableGodMode() end
end

-- === Восстановление при респавне ===

Player.CharacterAdded:Connect(function(Character)
    task.wait(0.1)
    if GodActive then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
        task.wait(0.5)
        RemoveMonsters()
    end
    if NoclipActive then
        DisableNoclip()
        EnableNoclip()
    end
end)

-- === КНОПКИ ===

NoclipBtn.MouseButton1Click:Connect(ToggleNoclip)
GodBtn.MouseButton1Click:Connect(ToggleGod)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == NoclipKey then
        ToggleNoclip()
    end
    if Input.KeyCode == GodKey then
        ToggleGod()
    end
end)

-- Минимизация
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "–"
    local size = Minimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 220)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = size}):Play()
end)

-- Закрытие
CloseBtn.MouseButton1Click:Connect(function()
    if NoclipActive then DisableNoclip() end
    if GodActive then DisableGodMode() end
    ScreenGui:Destroy()
end)

print("✅ ULTIMATE загружен! N — Ноклип, G — Бессмертие (с удалением монстров)")
