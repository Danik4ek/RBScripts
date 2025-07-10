local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "вам нужно" -- Поиск без учета регистра
local lastCheck = 0

-- Безопасная функция проверки текста
local function containsValidText(obj, text)
    local success, result = pcall(function()
        text = string.lower(text)
        
        -- Игнорируем элементы консоли
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("DevConsoleMaster") and obj:IsDescendantOf(coreGui.DevConsoleMaster) then
            return false
        end

        -- Проверяем текстовые объекты
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            return obj.Text and string.find(string.lower(obj.Text), text) ~= nil
        end

        -- Проверяем 3D-тексты
        if obj:IsA("TextLabel") then
            local parent = obj.Parent
            if parent and (parent:IsA("BillboardGui") or parent:IsA("SurfaceGui")) then
                return obj.Text and string.find(string.lower(obj.Text), text) ~= nil
            end
        end

        -- Проверяем атрибуты
        local attrText = obj:GetAttribute("Text") or obj:GetAttribute("Description")
        if attrText and string.find(string.lower(attrText), text) then
            return true
        end

        return false
    end)
    
    return success and result or false
end

-- Безопасная функция поиска
local function findTextInGame()
    local results = {}
    
    -- Сканируем только важные части игры
    local scanTargets = {
        workspace,
        player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 2),
        game:GetService("StarterGui")
    }

    for _, target in ipairs(scanTargets) do
        if target then
            local success, descendants = pcall(function()
                return target:GetDescendants()
            end)
            
            if success then
                for _, obj in ipairs(descendants) do
                    if containsValidText(obj, searchText) then
                        table.insert(results, {
                            Object = obj,
                            Path = obj:GetFullName(),
                            Text = obj.Text or obj:GetAttribute("Text")
                        })
                    end
                end
            end
        end
    end

    return results
end

-- Улучшенный вывод результатов
local function printResults(results)
    if #results == 0 then
        print("❌ Текст '"..searchText.."' не найден в игровых объектах")
        return
    end

    print("✅ Найдено "..#results.." объектов с текстом '"..searchText.."':")
    for i, item in ipairs(results) do
        print(i..". "..(item.Path or "неизвестный путь"))
        print("   Текст: "..(item.Text or "---"))
        print("   Тип: "..(item.Object and item.Object.ClassName or "неизвестный тип"))
    end
end

-- Главный цикл с обработкой ошибок
while true do
    local success, err = pcall(function()
        if os.time() - lastCheck >= 3 then
            printResults(findTextInGame())
            lastCheck = os.time()
        end
    end)
    
    if not success then
        warn("Ошибка в главном цикле: "..tostring(err))
    end
    
    wait(1)
end
