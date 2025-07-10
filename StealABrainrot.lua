local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Функция для вывода координат игрока
local function printPlayerPosition()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Создаем подключение к Heartbeat для постоянного вывода
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if humanoidRootPart and humanoidRootPart.Parent then
            local position = humanoidRootPart.Position
            print(string.format("Координаты игрока: X=%.2f, Y=%.2f, Z=%.2f", 
                              position.X, position.Y, position.Z))
        else
            -- Если персонаж уничтожен, отключаем
            connection:Disconnect()
        end
    end)
    
    return connection  -- Возвращаем соединение, чтобы можно было остановить
end

-- Запускаем вывод координат
local positionTracker = printPlayerPosition()
