local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Функция для рекурсивного вывода элементов GUI
local function printGuiElements(guiObject, indent)
    indent = indent or 0
    local prefix = string.rep(" ", indent) .. "└─ "
    
    print(prefix .. guiObject.ClassName .. ": " .. guiObject.Name)
    
    -- Проверяем, является ли объект контейнером (имеет дочерние элементы)
    if guiObject:IsA("GuiObject") or guiObject:IsA("LayerCollector") then
        for _, child in ipairs(guiObject:GetChildren()) do
            printGuiElements(child, indent + 2)
        end
    end
end

-- Выводим все экраны GUI
for _, screenGui in ipairs(playerGui:GetChildren()) do
    print("===== " .. screenGui.Name .. " =====")
    printGuiElements(screenGui)
    print("\n")
end
