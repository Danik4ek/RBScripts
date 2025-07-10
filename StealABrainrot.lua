local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "вам нужно" -- Поиск без учета регистра
local lastCheck = 0

-- Функция для проверки текста в объекте (без DevConsole)
local function containsValidText(obj, text)
    text = string.lower(text)
    
    -- Игнорируем элементы консоли
    if obj:IsDescendantOf(game:GetService("CoreGui").DevConsoleMaster) then
        return false
    end

    -- Проверяем только нужные типы объектов
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        return obj.Text and string.find(string.lower(obj.Text), text)
    end

    -- Проверяем 3D-тексты
    if obj:IsA("TextLabel") and (obj.Parent:IsA("BillboardGui") or obj.Parent:IsA("SurfaceGui")) then
        return obj.Text and string.find(string.lower(obj.Text), text)
    end

    -- Проверяем атрибуты
    local attrText = obj:GetAttribute("Text") or obj:GetAttribute("Description")
    if attrText and string.find(string.lower(attrText), text) then
        return true
    end

    return false
end

-- Основная функция поиска
local function findTextInGame()
    local results = {}
    
    -- Сканируем только важные части игры
    local scanTargets = {
        workspace,
        player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui"),
        game:GetService("StarterGui")
    }

    for _, target in ipairs(scanTargets) do
        for _, obj in ipairs(target:GetDescendants()) do
            if containsValidText(obj, searchText) then
                table.insert(results, {
                    Object = obj,
                    Path = obj:GetFullName(),
                    Text = obj.Text or obj:GetAttribute("Text")
                })
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
        print(i..". "..item.Path)
        print("   Текст: "..(item.Text or "---"))
        print("   Тип: "..item.Object.ClassName)
    end
end

-- Проверка каждые 3 секунды
while true do
    if os.time() - lastCheck >= 3 then
        printResults(findTextInGame())
        lastCheck = os.time()
    end
    wait(0.1)
end
