-- Функция для получения всех объектов PlayerGui
function getAllPlayerGuiElements(player)
    -- Проверяем, существует ли игрок и его PlayerGui
    if not player or not player:FindFirstChild("PlayerGui") then
        warn("PlayerGui не найден для игрока " .. tostring(player))
        return {}
    end
    
    local guiElements = {}
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Рекурсивная функция для сбора всех GUI-объектов
    local function scanGuiObjects(gui, path)
        path = path or ""
        for _, child in ipairs(gui:GetChildren()) do
            local newPath = path .. "/" .. child.Name
            table.insert(guiElements, {
                Object = child,
                Path = newPath,
                ClassName = child.ClassName,
                FullName = player.Name .. ".PlayerGui" .. newPath
            })
            
            -- Если объект является контейнером, сканируем его содержимое
            if child:IsA("GuiObject") or child:IsA("LayerCollector") then
                scanGuiObjects(child, newPath)
            end
        end
    end
    
    -- Сканируем каждый ScreenGui и StarterGui
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        scanGuiObjects(screenGui)
    end
    
    return guiElements
end

-- Пример использования для локального игрока
local player = game:GetService("Players").LocalPlayer

-- Подождем, пока PlayerGui загрузится
player:WaitForChild("PlayerGui")

-- Получаем все элементы GUI
local allGuiElements = getAllPlayerGuiElements(player)

-- Выводим информацию в output
print("=== Все элементы интерфейса игрока ===")
print("Всего элементов: " .. #allGuiElements)

for i, element in ipairs(allGuiElements) do
    print(string.format("%d. %s (%s)", i, element.FullName, element.ClassName))
end

-- Альтернативный вариант: возвращаем таблицу с элементами
return allGuiElements
