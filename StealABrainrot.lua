local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Улучшенная функция проверки элемента
local function checkElement(element)
    if not element then return false end
    
    -- Все возможные свойства с текстом
    local textProperties = {
        "Text", "RichText", "PlaceholderText", "Message", 
        "Description", "ToolTip", "Header", "Title"
    }
    
    for _, prop in ipairs(textProperties) do
        -- Безопасная проверка свойства
        local success, value = pcall(function()
            return element[prop]
        end)
        
        if success and type(value) == "string" and value:find("Вам нужно") then
            print("🔍 Найдено совпадение в:", element:GetFullName())
            print("📝 Содержимое ("..prop.."):", value)
            return true
        end
    end
    return false
end

-- Безопасный рекурсивный поиск
local function scanGuiRecursive(guiObject)
    if not guiObject or not guiObject:IsA("Instance") then return end
    
    -- Проверяем текущий элемент
    if not pcall(checkElement, guiObject) then
        warn("Ошибка при проверке элемента:", guiObject:GetFullName())
    end
    
    -- Проверяем детей
    for _, child in ipairs(guiObject:GetChildren()) do
        scanGuiRecursive(child)
    end
end

-- Полная проверка интерфейса
local function fullInterfaceScan()
    -- 1. Основной интерфейс
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        print("\n=== Сканирование PlayerGui ===")
        scanGuiRecursive(playerGui)
    end
    
    -- 2. Backpack (если есть текстовые элементы)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        print("\n=== Сканирование Backpack ===")
        scanGuiRecursive(backpack)
    end
    
    -- 3. 3D-интерфейсы персонажа
    if player.Character then
        print("\n=== Сканирование Character ===")
        for _, item in ipairs(player.Character:GetDescendants()) do
            if item:IsA("BillboardGui") or item:IsA("SurfaceGui") then
                scanGuiRecursive(item)
            end
        end
    end
end

-- Оптимизированный таймер для проверки
local scanInterval = 2 -- секунды
local lastScan = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastScan = lastScan + deltaTime
    if lastScan >= scanInterval then
        lastScan = 0
        print("\n"..string.rep("=", 40))
        print("Начинаем новую проверку интерфейса")
        print(string.rep("=", 40))
        fullInterfaceScan()
    end
end)

-- Мгновенная реакция на новые элементы
player:GetPropertyChangedSignal("PlayerGui"):Connect(function()
    if player.PlayerGui then
        player.PlayerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("GuiObject") then
                checkElement(descendant)
            end
        end)
    end
end)

-- Первоначальная настройка
if player.PlayerGui then
    player.PlayerGui.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("GuiObject") then
            checkElement(descendant)
        end
    end)
end

print("✅ Система мониторинга интерфейса активирована")
