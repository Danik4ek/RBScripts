local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "вам нужно"
local lastCheck = 0

-- Расширенная проверка текста
local function containsTargetText(obj)
    -- Проверяем все возможные текстовые свойства
    local textSources = {
        obj.Text,
        obj:GetAttribute("Text"),
        obj:GetAttribute("Description"),
        obj.Name
    }
    
    -- Игнорируем служебные объекты
    if obj:IsDescendantOf(game:GetService("CoreGui")) then
        return false
    end

    -- Проверяем все источники текста
    for _, text in ipairs(textSources) do
        if text and string.find(string.lower(text), string.lower(searchText)) then
            return true
        end
    end
    
    -- Дополнительные проверки
    if obj:IsA("ImageLabel") then
        local altText = obj:GetAttribute("AltText") or obj:GetAttribute("Tooltip")
        if altText and string.find(string.lower(altText), string.lower(searchText)) then
            return true
        end
    end
    
    return false
end

-- Глубокий поиск с задержкой
local function deepSearch()
    local targets = {
        workspace,
        player:WaitForChild("PlayerGui"),
        game:GetService("StarterGui"),
        game:GetService("CoreGui")
    }
    
    local results = {}
    
    for _, target in ipairs(targets) do
        for _, obj in ipairs(target:GetDescendants()) do
            if containsTargetText(obj) then
                table.insert(results, {
                    Object = obj,
                    Path = obj:GetFullName(),
                    Text = obj.Text or obj:GetAttribute("Text") or obj.Name
                })
            end
        end
    end
    
    return results
end

-- Умный вывод результатов
local function printSmartResults(results)
    if #results == 0 then
        print("ℹ️ Попробуйте следующее:")
        print("1. Убедитесь, что текст не является частью текстуры")
        print("2. Проверьте регистр (используется поиск: '"..searchText.."')")
        print("3. Объект может создаваться динамически - подождите 10 секунд")
        return
    end
    
    print("✅ Найдено совпадений: "..#results)
    for i, item in ipairs(results) do
        print(i..". "..item.Path)
        print("   Тип: "..item.Object.ClassName)
        print("   Текст: "..(item.Text or "---"))
    end
end

-- Главный цикл с повтором
while true do
    local results = deepSearch()
    printSmartResults(results)
    
    if #results == 0 then
        -- Повторная попытка через 5 секунд
        wait(5)
        print("\nПовторная проверка...")
        results = deepSearch()
        printSmartResults(results)
    end
    
    wait(10) -- Интервал между проверками
end
