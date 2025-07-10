local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local searchText = "вам нужно" -- Поиск без учета регистра
local debounce = false -- Защита от спама

-- Функция для проверки текста в любом объекте
local function containsText(obj, text)
    text = string.lower(text)
    
    -- 1. Проверка стандартных текстовых свойств
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        return obj.Text and string.find(string.lower(obj.Text), text)
    end

    -- 2. Проверка атрибутов
    local attrText = obj:GetAttribute("Text") or obj:GetAttribute("Description")
    if attrText and string.find(string.lower(attrText), text) then
        return true
    end

    -- 3. Проверка других свойств (например, звуков, инструментов)
    if obj:IsA("Sound") and obj.Name ~= "Sound" then
        return string.find(string.lower(obj.Name), text)
    end

    -- 4. Проверка 3D-текстов (BillboardGui, SurfaceGui)
    if obj:IsA("TextLabel") and (obj.Parent:IsA("BillboardGui") or obj.Parent:IsA("SurfaceGui")) then
        return obj.Text and string.find(string.lower(obj.Text), text)
    end

    -- 5. Проверка в скриптах (если нужно)
    -- if obj:IsA("Script") or obj:IsA("LocalScript") then
    --     local source = obj.Source
    --     return source and string.find(string.lower(source), text)
    -- end

    return false
end

-- Рекурсивный поиск по всем объектам
local function scanAllObjects(parent, results)
    for _, child in ipairs(parent:GetChildren()) do
        if containsText(child, searchText) then
            table.insert(results, {
                Object = child,
                Path = child:GetFullName(),
                Text = child.Text or child:GetAttribute("Text") or child.Name
            })
        end
        scanAllObjects(child, results) -- Рекурсивно проверяем детей
    end
end

-- Основная функция поиска
local function findAllTextMatches()
    if debounce then return end
    debounce = true
    
    local results = {}
    scanAllObjects(game, results) -- Начинаем с корня игры
    
    -- Вывод результатов
    if #results > 0 then
        print("🔍 Найдено объектов с текстом '"..searchText.."': "..#results)
        for i, item in ipairs(results) do
            print(i..". "..item.Path)
            print("   Текст: "..tostring(item.Text))
        end
    else
        print("❌ Текст '"..searchText.."' не найден ни в одном объекте.")
    end
    
    debounce = false
    return results
end

-- Автоматический поиск каждые 5 секунд
while true do
    findAllTextMatches()
    wait(1) -- Интервал проверки
end
