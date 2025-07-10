local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local searchText = "вам нужно"
local lastFound = nil

-- Улучшенная функция проверки текста
local function checkForText(obj)
    -- Проверяем только объекты, которые могут содержать текст
    if not (obj:IsA("GuiObject") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return false
    end

    -- Безопасное получение текста
    local text
    pcall(function()
        text = obj.Text or obj:GetAttribute("Text") or obj:GetAttribute("Description") or obj.Name
    end)

    -- Проверка совпадения
    if text and string.find(string.lower(tostring(text)), string.lower(searchText)) then
        return true, text
    end

    return false
end

-- Функция для мониторинга изменений
local function monitorChanges()
    while true do
        -- Проверяем все возможные места
        local locations = {
            player.PlayerGui,
            workspace,
            game:GetService("StarterGui")
        }

        for _, location in ipairs(locations) do
            if location then
                for _, obj in ipairs(location:GetDescendants()) do
                    local found, text = checkForText(obj)
                    if found then
                        if not lastFound or lastFound.Object ~= obj then
                            print("Обнаружен изменяемый текст:")
                            print("Объект:", obj:GetFullName())
                            print("Текущий текст:", text)
                            print("Тип:", obj.ClassName)
                            print("----------------------")
                            lastFound = {Object = obj, Text = text}
                        end
                    end
                end
            end
        end

        wait(1) -- Проверка каждую секунду
    end
end

-- Запуск мониторинга
spawn(monitorChanges)
