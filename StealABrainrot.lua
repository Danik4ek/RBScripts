local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "вам нужно"
local lastCheck = 0

-- Безопасная проверка текста с защитой от ошибок
local function containsTargetText(obj)
    -- Пропускаем нерелевантные объекты
    if not obj:IsA("GuiObject") 
       and not obj:IsA("TextLabel") 
       and not obj:IsA("TextButton") 
       and not obj:IsA("TextBox") 
       and not obj:IsA("ImageLabel") then
        return false
    end

    -- Безопасная проверка свойств
    local function safeGetText(target)
        local text = nil
        pcall(function()
            -- Проверяем основные свойства
            if target:IsA("GuiObject") then
                text = target.Text
            end
            -- Проверяем атрибуты
            if not text then
                text = target:GetAttribute("Text") 
                     or target:GetAttribute("Description")
                     or target:GetAttribute("Tooltip")
            end
            -- Проверяем имя
            if not text then
                text = target.Name
            end
        end)
        return text
    end

    local text = safeGetText(obj)
    if text and string.find(string.lower(text), string.lower(searchText)) then
        return true
    end

    return false
end

-- Оптимизированный поиск
local function deepSearch()
    local targets = {
        player:WaitForChild("PlayerGui"),
        workspace:FindFirstChildOfClass("SurfaceGui") and workspace,
        game:GetService("StarterGui")
    }

    local results = {}
    
    for _, target in ipairs(targets) do
        if target then
            for _, obj in ipairs(target:GetDescendants()) do
                if containsTargetText(obj) then
                    table.insert(results, {
                        Object = obj,
                        Path = obj:GetFullName(),
                        Text = safeGetText(obj)
                    })
                end
            end
        end
    end
    
    return results
end

-- Улучшенный вывод
local function printResults(results)
    if #results == 0 then
        print("🔍 Текст не найден. Возможные причины:")
        print("- Текст является частью изображения")
        print("- Объект создаётся динамически (попробуйте подождать)")
        print("- Проверьте регистр: ищем '"..searchText.."'")
        return
    end
    
    print("✅ Найдено объектов: "..#results)
    for i, item in ipairs(results) do
        print(i..". "..item.Path)
        print("   Тип: "..item.Object.ClassName)
        print("   Текст: "..(item.Text or "---"))
    end
end

-- Главный цикл
while true do
    local results = deepSearch()
    printResults(results)
    wait(5) -- Интервал между проверками
end
