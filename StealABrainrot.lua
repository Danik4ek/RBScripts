local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Оптимизированная функция проверки
local function checkForText()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    
    -- Ищем только в активных ScreenGui
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") and screenGui.Enabled then
            -- Проверяем текстовые элементы
            for _, element in ipairs(screenGui:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    if element.Text and element.Text:find("Вам нужно") then
                        print("Найдено уведомление в:", element:GetFullName())
                        -- Дополнительные действия (например, закрыть уведомление)
                        local frame = element:FindFirstAncestorWhichIsA("Frame")
                        if frame then
                            frame.Visible = false
                        end
                    end
                end
                -- Микро-пауза для снижения нагрузки
                task.wait()
            end
        end
    end
end

-- Проверка с интервалом 5 секунд
while true do
    checkForText()
    wait(5) -- Интервал можно уменьшить до 1-2 секунд при необходимости
end
