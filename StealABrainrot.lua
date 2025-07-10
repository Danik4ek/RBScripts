local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Таблица для кэширования проверенных элементов
local checkedElements = {}

-- Быстрая проверка элемента
local function checkElement(element)
    -- Пропускаем уже проверенные элементы
    if checkedElements[element] then return end
    
    -- Только текстовые элементы
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        if element.Text and element.Text:find("Вам нужно") then
            print("🔍 Найдено в "..element:GetFullName()..":", element.Text)
            -- Можно добавить действие (например, element.Parent.Visible = false)
        end
    end
    
    -- Помечаем как проверенный
    checkedElements[element] = true
end

-- Оптимизированный поиск только в PlayerGui
local function scanPlayerGui()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    
    -- Очищаем кэш при каждом новом сканировании
    checkedElements = {}
    
    -- Проверяем только видимые ScreenGui
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") and screenGui.Enabled then
            -- Быстрая проверка без глубокой рекурсии
            for _, element in ipairs(screenGui:GetDescendants()) do
                checkElement(element)
                -- Добавляем небольшую задержку для снижения нагрузки
                if #checkedElements % 50 == 0 then
                    task.wait()
                end
            end
        end
    end
end

-- Запускаем с интервалом 3 секунды
local scanInterval = 3
local lastScan = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastScan = lastScan + deltaTime
    if lastScan >= scanInterval then
        lastScan = 0
        scanPlayerGui()
    end
end)

-- Мгновенная проверка новых элементов
player:GetPropertyChangedSignal("PlayerGui"):Connect(function()
    if player.PlayerGui then
        player.PlayerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("GuiObject") then
                checkElement(descendant)
            end
        end)
    end
end)

print("✅ Система мониторинга PlayerGui запущена")
