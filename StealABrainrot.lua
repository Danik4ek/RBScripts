local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local searchText = "вам нужно" -- в нижнем регистре

local function getFullPath(object)
    local path = {}
    while object and object ~= player.PlayerGui and object ~= StarterGui do
        table.insert(path, 1, object.Name)
        object = object.Parent
    end
    return table.concat(path, "/")
end

local function containsText(guiObject, text)
    -- Проверка стандартных элементов
    if (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox")) and guiObject.Text then
        return string.find(string.lower(guiObject.Text), string.lower(text)) ~= nil
    end
    
    -- Проверка 3D GUI
    if guiObject:IsA("SurfaceGui") or guiObject:IsA("BillboardGui") then
        for _, child in ipairs(guiObject:GetDescendants()) do
            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text then
                if string.find(string.lower(child.Text), string.lower(text)) then
                    return true
                end
            end
        end
    end
    
    -- Проверка атрибутов
    local attrText = guiObject:GetAttribute("Text") or guiObject:GetAttribute("AltText")
    if attrText and string.find(string.lower(attrText), string.lower(text)) then
        return true
    end
    
    return false
end

local function scanGuiForText(gui, text, results)
    for _, child in ipairs(gui:GetChildren()) do
        if containsText(child, text) then
            table.insert(results, {
                Object = child,
                Path = getFullPath(child),
                Text = child.Text or child:GetAttribute("Text") or child:GetAttribute("AltText")
            })
        end
        
        -- Рекурсивная проверка
        if #child:GetChildren() > 0 then
            scanGuiForText(child, text, results)
        end
    end
end

local function findAllTextInstances()
    local results = {}
    
    -- Проверяем PlayerGui
    if player:FindFirstChild("PlayerGui") then
        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            scanGuiForText(gui, searchText, results)
        end
    end
    
    -- Проверяем StarterGui
    for _, gui in ipairs(StarterGui:GetChildren()) do
        scanGuiForText(gui, searchText, results)
    end
    
    -- Проверяем 3D интерфейсы в Workspace
    for _, gui in ipairs(workspace:GetDescendants()) do
        if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
            scanGuiForText(gui, searchText, results)
        end
    end
    
    return results
end

-- Запускаем поиск каждую секунду
while true do
    local results = findAllTextInstances()
    if #results > 0 then
        print("Найдены элементы с текстом '"..searchText.."':")
        for i, item in ipairs(results) do
            print(i..". "..item.Path.." ("..item.Object.ClassName..")")
            print("   Текст: "..tostring(item.Text))
        end
    else
        print("Текст не найден (проверка: "..os.date("%X")..")")
    end
    wait(1)
end
