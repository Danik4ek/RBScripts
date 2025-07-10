local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local searchText = "вам нужно"
local searchTextLower = string.lower(searchText)

-- Безопасное получение текста из любого объекта
local function getSafeText(obj)
    local text = nil
    
    -- Защищённое получение текста
    pcall(function()
        -- Основные текстовые свойства
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            text = obj.Text
        elseif obj:IsA("ImageLabel") then
            text = obj:GetAttribute("AltText") or obj:GetAttribute("Tooltip")
        end
        
        -- Дополнительные источники текста
        if not text then
            text = obj:GetAttribute("Text") 
                 or obj:GetAttribute("Description")
                 or obj.Name
        end
    end)
    
    return text and tostring(text) or nil
end

-- Безопасная проверка совпадения
local function isTextMatch(obj)
    local text = getSafeText(obj)
    if not text then return false end
    
    -- Защита от nil после tostring
    local success, result = pcall(function()
        return string.find(string.lower(text), searchTextLower)
    end)
    
    return success and result ~= nil
end

-- Оптимизированный поиск
local function findText()
    local targets = {
        player:WaitForChild("PlayerGui"),
        workspace,
        game:GetService("StarterGui")
    }

    local results = {}
    
    for _, target in ipairs(targets) do
        if target then
            for _, obj in ipairs(target:GetDescendants()) do
                if isTextMatch(obj) then
                    table.insert(results, {
                        Object = obj,
                        Path = obj:GetFullName(),
                        Text = getSafeText(obj)
                    })
                end
            end
        end
    end
    
    return results
end

-- Умный вывод результатов
local function printResults(results)
    if #results == 0 then
        print("🔍 Текст не найден. Проверьте:")
        print("- Виден ли текст в игре прямо сейчас")
        print("- Не является ли текст частью изображения")
        print("- Попробуйте поискать часть текста")
        return
    end
    
    print("✅ Найдено совпадений: "..#results)
    for i, item in ipairs(results) do
        print(string.format("%d. %s (%s)", i, item.Path, item.Object.ClassName))
        print("   Текст: "..(item.Text or "---"))
    end
end

-- Основной цикл с интервалом
while true do
    local results = findText()
    printResults(results)
    wait(5) -- Интервал между проверками
end
