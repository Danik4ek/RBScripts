local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Функция для поиска TextLabel или TextButton с текстом "$число"
local function findBalanceGuiElement(parent)
    for _, child in ipairs(parent:GetChildren()) do
        -- Проверяем, является ли элемент TextLabel/TextButton и содержит ли "$"
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and string.match(child.Text, "^%$[0-9]+") then
            print("Найден элемент баланса:")
            print("Тип: " .. child.ClassName)
            print("Имя: " .. child.Name)
            print("Текст: " .. child.Text)
            print("Путь: " .. child:GetFullName()) -- Полный путь в иерархии
            return child -- Возвращаем найденный элемент
        end
        
        -- Рекурсивно проверяем дочерние элементы
        local found = findBalanceGuiElement(child)
        if found then
            return found
        end
    end
    return nil
end

-- Ищем во всех ScreenGui
for _, screenGui in ipairs(playerGui:GetChildren()) do
    if screenGui:IsA("ScreenGui") then
        local balanceElement = findBalanceGuiElement(screenGui)
        if balanceElement then
            break -- Если нашли, останавливаем поиск
        end
    end
end
