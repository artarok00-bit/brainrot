-- Чит для Roblox: Перемещение персонажа по точкам
-- Поддерживает добавление, удаление точек и телепортацию

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Основной класс для управления точками
local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    self.Waypoints = {}
    self.CurrentIndex = 1
    self.IsTeleporting = false
    self.Speed = 30 -- скорость телепортации
    self.AutoTeleport = false
    self.Loop = false
    self.Humanoid = nil
    self.RootPart = nil
    
    -- Обновляем ссылки на персонажа
    self:UpdateCharacter()
    
    -- Событие смены персонажа
    player.CharacterAdded:Connect(function(newChar)
        self:UpdateCharacter()
    end)
    
    return self
end

function WaypointSystem:UpdateCharacter()
    self.Character = player.Character
    if self.Character then
        self.Humanoid = self.Character:FindFirstChild("Humanoid")
        self.RootPart = self.Character:FindFirstChild("HumanoidRootPart")
    end
end

-- Добавить точку (текущая позиция)
function WaypointSystem:AddCurrentPosition(name)
    if not self.RootPart then return end
    local pos = self.RootPart.Position
    table.insert(self.Waypoints, {
        Position = pos,
        Name = name or "Waypoint " .. #self.Waypoints + 1
    })
    print(string.format("✅ Добавлена точка: %s (%.1f, %.1f, %.1f)", 
        self.Waypoints[#self.Waypoints].Name, pos.X, pos.Y, pos.Z))
    return #self.Waypoints
end

-- Добавить точку по координатам
function WaypointSystem:AddWaypoint(position, name)
    table.insert(self.Waypoints, {
        Position = position,
        Name = name or "Waypoint " .. #self.Waypoints + 1
    })
    print(string.format("✅ Добавлена точка: %s (%.1f, %.1f, %.1f)", 
        self.Waypoints[#self.Waypoints].Name, position.X, position.Y, position.Z))
    return #self.Waypoints
end

-- Удалить точку по индексу
function WaypointSystem:RemoveWaypoint(index)
    if self.Waypoints[index] then
        local name = self.Waypoints[index].Name
        table.remove(self.Waypoints, index)
        print("❌ Удалена точка: " .. name)
        return true
    end
    return false
end

-- Очистить все точки
function WaypointSystem:ClearWaypoints()
    self.Waypoints = {}
    self.CurrentIndex = 1
    print("🗑️ Все точки очищены")
end

-- Телепорт к точке по индексу
function WaypointSystem:TeleportTo(index)
    if not self.RootPart or not self.Humanoid then return end
    if not self.Waypoints[index] then 
        print("❌ Точка не найдена!")
        return 
    end
    
    if self.IsTeleporting then return end
    self.IsTeleporting = true
    
    local targetPos = self.Waypoints[index].Position
    local currentPos = self.RootPart.Position
    
    -- Проверка, чтобы не телепортироваться под карту
    targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y, 0), targetPos.Z)
    
    print(string.format("🚀 Телепорт к: %s", self.Waypoints[index].Name))
    
    -- Вариант 1: Мгновенная телепортация
    self.RootPart.CFrame = CFrame.new(targetPos)
    
    -- Вариант 2: Плавная телепортация (раскомментируйте если нужно)
    -- local tween = TweenService:Create(self.RootPart, 
    --     TweenInfo.new((currentPos - targetPos).Magnitude / self.Speed, 
    --     Enum.EasingStyle.Linear), 
    --     {CFrame = CFrame.new(targetPos)}
    -- )
    -- tween:Play()
    -- tween.Completed:Wait()
    
    task.wait(0.1) -- небольшая задержка
    self.IsTeleporting = false
    print("✅ Телепорт завершен")
end

-- Переместиться к следующей точке
function WaypointSystem:NextWaypoint()
    if #self.Waypoints == 0 then 
        print("⚠️ Нет сохраненных точек!")
        return 
    end
    
    if self.CurrentIndex > #self.Waypoints then
        if self.Loop then
            self.CurrentIndex = 1
        else
            print("🏁 Все точки пройдены!")
            self.AutoTeleport = false
            return
        end
    end
    
    self:TeleportTo(self.CurrentIndex)
    self.CurrentIndex = self.CurrentIndex + 1
end

-- Начать автоматическое перемещение
function WaypointSystem:StartAutoTeleport()
    if #self.Waypoints == 0 then
        print("⚠️ Нет точек для авто-телепортации!")
        return
    end
    self.AutoTeleport = true
    self.CurrentIndex = 1
    print("▶️ Авто-телепортация запущена")
    self:NextWaypoint()
end

-- Остановить автоматическое перемещение
function WaypointSystem:StopAutoTeleport()
    self.AutoTeleport = false
    print("⏹️ Авто-телепортация остановлена")
end

-- Список всех точек
function WaypointSystem:ListWaypoints()
    if #self.Waypoints == 0 then
        print("📋 Список точек пуст")
        return
    end
    
    print(string.format("📋 Список точек (%d):", #self.Waypoints))
    for i, wp in ipairs(self.Waypoints) do
        local pos = wp.Position
        print(string.format("  %d. %s - (%.1f, %.1f, %.1f)", 
            i, wp.Name, pos.X, pos.Y, pos.Z))
    end
end

-- Получить текущую позицию
function WaypointSystem:GetCurrentPosition()
    if self.RootPart then
        return self.RootPart.Position
    end
    return nil
end

-- Сохранить точки в файл (для отладки)
function WaypointSystem:SaveToClipboard()
    if #self.Waypoints == 0 then return end
    
    local data = "-- Waypoints data\nlocal waypoints = {\n"
    for i, wp in ipairs(self.Waypoints) do
        local pos = wp.Position
        data = data .. string.format("    {%.1f, %.1f, %.1f}, -- %s\n", 
            pos.X, pos.Y, pos.Z, wp.Name)
    end
    data = data .. "}\n"
    
    -- Копирование в буфер обмена (только для Roblox)
    setclipboard and setclipboard(data)
    print("📋 Данные скопированы в буфер обмена!")
end

return WaypointSystem
