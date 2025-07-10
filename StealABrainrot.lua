-- Скрипт для вывода координат игроков в Roblox
-- Рекомендуется поместить в ServerScriptService

local Players = game:GetService("Players")

-- Функция для получения позиции игрока в формате (X, Y, Z)
local function getPlayerPosition(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            return humanoidRootPart.Position
        end
    end
    return nil
end

-- Функция для вывода координат всех игроков
local function printAllPlayerPositions()
    for _, player in ipairs(Players:GetPlayers()) do
        local position = getPlayerPosition(player)
        if position then
            print(string.format("%s: (%.2f, %.2f, %.2f)", 
                  player.Name, position.X, position.Y, position.Z))
        else
            print(player.Name .. ": Персонаж не найден")
        end
    end
end

-- Выводим координаты при подключении игрока
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Небольшая задержка для гарантии загрузки персонажа
        wait(1)
        local position = getPlayerPosition(player)
        if position then
            print(string.format("%s вошел в игру на позиции: (%.2f, %.2f, %.2f)", 
                  player.Name, position.X, position.Y, position.Z))
        end
    end)
end)

-- Выводим координаты при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    local position = getPlayerPosition(player)
    if position then
        print(string.format("%s вышел из игры с позиции: (%.2f, %.2f, %.2f)", 
              player.Name, position.X, position.Y, position.Z))
    else
        print(player.Name .. " вышел из игры (персонаж не найден)")
    end
end)

-- Выводим координаты всех игроков каждые 30 секунд
while true do
    wait(30)
    print("\nТекущие позиции игроков:")
    printAllPlayerPositions()
end
