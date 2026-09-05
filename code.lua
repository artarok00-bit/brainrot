-- [[ NOCLIP ULTRA (плавный, безопасный) ]]
-- Уменьшенный шаг + движение только при ходьбе + новый интерфейс

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local NoclipActive = false
local Minimized = false
local Hotkey = Enum.KeyCode.LeftAlt
local Connection = nil
local FrameCounter = 0
local StepSize = 0.15 -- Безопасный шаг

-- GUI (такой же как в предыдущем, копируем полностью)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoclipGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Background = Instance.new("Frame")
Background.Size = UDim2.new(0, 0, 0, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.5
Background.BorderSizePixel = 0
Background.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
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
TitleText.Text = "🧱 NOCLIP ULTRA"
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

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local OnBtn = Instance.new("TextButton")
OnBtn.Size = UDim2.new(0.4, 0, 0, 40)
OnBtn.Position = UDim2.new(0.08, 0, 0.1, 0)
OnBtn.Text = "✅ ДАВАЙ ВКЛЮЧАЙ"
OnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OnBtn.TextSize = 16
OnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
OnBtn.BorderSizePixel = 0
OnBtn.Font = Enum.Font.GothamSemibold
OnBtn.Parent = Content
local OnCorner = Instance.new("UICorner")
OnCorner.CornerRadius = UDim.new(0, 8)
OnCorner.Parent = OnBtn

local OffBtn = Instance.new("TextButton")
OffBtn.Size = UDim2.new(0.4, 0, 0, 40)
OffBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
OffBtn.Text = "❌ ВЫРУБИ НАХУЙ"
OffBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OffBtn.TextSize = 16
OffBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
OffBtn.BorderSizePixel = 0
OffBtn.Font = Enum.Font.GothamSemibold
OffBtn.Parent = Content
local OffCorner = Instance.new("UICorner")
OffCorner.CornerRadius = UDim.new(0, 8)
OffCorner.Parent = OffBtn

local function OnHover(btn, hover)
    local tween = TweenService:Create(btn, TweenInfo.new(0.2), {
        BackgroundColor3 = hover and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(0, 180, 80)
    })
    tween:Play()
end

OnBtn.MouseEnter:Connect(function() OnHover(OnBtn, true) end)
OnBtn.MouseLeave:Connect(function() OnHover(OnBtn, false) end)

OffBtn.MouseEnter:Connect(function() 
    local tween = TweenService:Create(OffBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    })
    tween:Play()
end)
OffBtn.MouseLeave:Connect(function() 
    local tween = TweenService:Create(OffBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    })
    tween:Play()
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
StatusLabel.TextSize = 15
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Content

local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Size = UDim2.new(0.9, 0, 0, 20)
HotkeyLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
HotkeyLabel.Text = "⌨️ LAlt — переключить"
HotkeyLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
HotkeyLabel.TextSize = 13
HotkeyLabel.TextXAlignment = Enum.TextXAlignment.Center
HotkeyLabel.BackgroundTransparency = 1
HotkeyLabel.Font = Enum.Font.Gotham
HotkeyLabel.Parent = Content

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
SpeedLabel.Text = "⚡ СКОРОСТЬ: ОПТИМАЛЬНАЯ"
SpeedLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = Content

-- ===== ОСНОВНАЯ ЛОГИКА (ПЛАВНАЯ) =====

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
    
    -- Двигаемся только если персонаж пытается идти (нажата клавиша)
    if Humanoid.MoveDirection.Magnitude < 0.1 then
        return -- не двигаемся, если стоим
    end
    
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    
    -- Отключаем коллизии
    DisableCollisions()
    
    -- Берём направление камеры (горизонтальное)
    local LookDirection = Camera.CFrame.LookVector
    local HorizontalLook = Vector3.new(LookDirection.X, 0, LookDirection.Z).Unit
    if HorizontalLook.Magnitude < 0.1 then
        HorizontalLook = Vector3.new(1, 0, 0)
    end
    
    -- Делаем шаг только каждый 2-й кадр для плавности
    FrameCounter = FrameCounter + 1
    if FrameCounter % 2 == 0 then
        local NewPos = RootPart.Position + HorizontalLook * StepSize
        RootPart.CFrame = CFrame.new(NewPos)
    end
    
    -- Сбрасываем скорость только у RootPart (мягко)
    RootPart.Velocity = RootPart.Velocity * 0.9
    RootPart.RotVelocity = RootPart.RotVelocity * 0.9
end

local function EnableNoclip()
    if NoclipActive then return end
    NoclipActive = true
    
    StatusLabel.Text = "🟢 ВКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    SpeedLabel.Text = "⚡ СКОРОСТЬ: ОПТИМАЛЬНАЯ"
    
    DisableCollisions()
    
    if Connection then
        Connection:Disconnect()
    end
    
    FrameCounter = 0
    Connection = RunService.RenderStepped:Connect(NoclipLoop)
end

local function DisableNoclip()
    if not NoclipActive then return end
    NoclipActive = false
    
    StatusLabel.Text = "🔴 ВЫКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    SpeedLabel.Text = "⚡ СКОРОСТЬ: ОПТИМАЛЬНАЯ"
    
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    EnableCollisions()
end

local function ToggleNoclip()
    if NoclipActive then DisableNoclip() else EnableNoclip() end
end

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
    local size = Minimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 180)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = size}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    DisableNoclip()
    ScreenGui:Destroy()
end)

print("✅ NOCLIP ULTRA (плавный) загружен! Шаг 0.15, движение только при ходьбе. Нажми LAlt.")
