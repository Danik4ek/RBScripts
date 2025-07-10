local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "Вам нужно"

-- Функция для проверки, содержит ли текст элемент
local function containsText(guiObject, text)
    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        return string.find(guiObject.Text, text) ~= nil
    elseif guiObject:IsA("ImageLabel") and guiObject:GetAttribute("AltText") then
        return string.find(guiObject:GetAttribute("AltText"), text) ~= nil
    end
    return false
end

-- Рекурсивная функция для поиска текста в GUI
local function scanGuiForText(gui, text, results)
    for _, child in ipairs(gui:GetChildren()) do
        if containsText(child, text) then
            table.insert(results, {
                Object = child,
                Path = getFullPath(child),
                Text = child.Text or child:GetAttribute("AltText")
            })
        end
        
        -- Рекурсивно проверяем дочерние элементы
        if child:IsA("GuiObject") or child:IsA("LayerCollector") then
            scanGuiForText(child, text, results)
        end
    end
end

-- Функция для получения полного пути к элементу
local function getFullPath(object)
    local path = {}
    while object and object ~= player.PlayerGui do
        table.insert(path, 1, object.Name)
        object = object.Parent
    end
    return table.concat(path, "/")
end

-- Основная функция поиска
local function findTextInPlayerGui()
    if not player or not player:FindFirstChild("PlayerGui") then return {} end
    
    local results = {}
    local playerGui = player:WaitForChild("PlayerGui")
    
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        scanGuiForText(screenGui, searchText, results)
    end
    
    return results
end

-- Функция для вывода результатов
local function printResults(results)
    print("=== Результаты поиска ===")
    print(string.format("Найдено элементов с текстом '%s': %d", searchText, #results))
    
    for i, result in ipairs(results) do
        print(string.format("%d. %s (%s)", i, result.Path, result.Object.ClassName))
        print("   Текст: " .. result.Text)
    end
end

-- Запускаем поиск каждую секунду
local connection
connection = RunService.Heartbeat:Connect(function()
    -- Проверяем раз в секунду (60 кадров)
    if tick() % 1 < 0.016 then
        local results = findTextInPlayerGui()
        if #results > 0 then
            printResults(results)
        end
    end
end)

-- Остановить поиск можно с помощью: connection:Disconnect()
