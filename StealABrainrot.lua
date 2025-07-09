local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local activeConnections = {}


local brainrotList = {
    "Noobini pizzanini",
    "Lirilì Larilà",
    "Tim Cheese",
    "Fluriflura",
    "Talpa di ferro",
    "Svinina Bombardino",
    "Pipi Kiwi",
    "Trippi Troppi",
    "Tung Tung Tung Sahur",
    "Gangster Footera",
    "Bandito Bobritto",
    "Boneca Ambalabu",
    "Ta Ta Ta Ta Sahur",
    "Tric Trac Baraboom",
    "Cappuccino Assassino",
    "Brr Brr Patapim",
    "Trulimero Trulicina",
    "Bambini Crostini",
    "Bananita Dolphinita",
    "Perochello Lemonchello",
    "Brri Brri Bicus Dicus Bombicus",
    "Burbaloni Loliloli",
    "Chimpanzini Bananini",
    "Ballerina Cappuccina",
    "Chef Crabracadabra",
    "Lionel Cactuseli",
    "Glorbo Fruttodrillo",
    "Blueberrinni Octopusini",
    "Frigo Camelo",
    "Orangutini Ananassini",
    "Rhino Toasterino",
    "Bombardiro Crocodilo",
    "Bombombini Gusini",
    "Cavallo Virtuoso",
    "Cocofanto Elefanto",
    "Gattatino Nyanino",
    "Girafa Celestre",
    "Matteo",
    "Tralalero Tralala",
    "Odin Din Din Dun",
    "Unclito Samito",
    "Trenostruzzo Turbo 3000",
    "La Vacca Saturno Saturnita",
    "Sammyni Spiderini",
    "Los Tralaleritos",
    "Graipuss Medussi",
    "La Grande Combinazione",
    "Garama and Madundung",
    "Orcalero Orcala and de Tabrak",
    "Developini Braziliaspidini",
    "Kings Coleslaw",
    "Ballerino Lololo",
    "Crocodillo Ananasinno"
}

local function simulateKeyPress(key)
    -- Эмулируем нажатие клавиши через VirtualInputManager (если доступен)
    if game:GetService("VirtualInputManager") then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, nil)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, nil)
    else
        -- Альтернативный способ (менее надежный)
        local player = Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Эмулируем действие (например, прыжок)
            end
        end
    end
end

local function followMovingObject(target)
    -- Проверка цели
    if not target or not target:IsDescendantOf(workspace) then
        print("Цель не существует или не в Workspace")
        return
    end

    -- Останавливаем предыдущее следование за этой целью
    if activeConnections[target] then
        activeConnections[target]:Disconnect()
        activeConnections[target] = nil
    end

    -- Получаем персонажа
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Функция для обновления пути
    local function updatePath()
        local targetPart = target:FindFirstChild("RootPart") or 
                         target:FindFirstChildWhichIsA("BasePart") or
                         target.PrimaryPart

        if not targetPart then
            print("У цели нет подходящей части для перемещения")
            return
        end

        -- Проверяем расстояние до цели
        local distance = (targetPart.Position - rootPart.Position).Magnitude
        
        -- Если игрок достаточно близко, эмулируем нажатие E
        if distance < 5 then
            simulateKeyPress(Enum.KeyCode.E)
            return
        end

        -- Создаем новый путь
        local path = PathfindingService:CreatePath({
            AgentRadius = 1.5,
            AgentHeight = 5,
            AgentCanJump = true
        })

        -- Вычисляем маршрут
        local success, err = pcall(function()
            path:ComputeAsync(rootPart.Position, targetPart.Position)
        end)

        if not success then
            print("Ошибка расчета пути:", err)
            return
        end

        -- Движение по новым точкам
        if path.Status == Enum.PathStatus.Success then
            for _, waypoint in ipairs(path:GetWaypoints()) do
                -- Проверяем расстояние перед каждым движением
                local currentDistance = (targetPart.Position - rootPart.Position).Magnitude
                if currentDistance < 5 then
                    simulateKeyPress(Enum.KeyCode.E)
                    break
                end
                
                humanoid:MoveTo(waypoint.Position)
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                
                -- Прерываем движение, если цель слишком далеко
                if (targetPart.Position - rootPart.Position).Magnitude > 100 then
                    break
                end
                
                humanoid.MoveToFinished:Wait()
            end
        end
    end

    -- Запускаем постоянное обновление пути
    activeConnections[target] = RunService.Heartbeat:Connect(function()
        -- Проверяем расстояние до цели
        local targetPart = target:FindFirstChildWhichIsA("BasePart") or target.PrimaryPart
        if not targetPart then return end
        
        local distance = (targetPart.Position - rootPart.Position).Magnitude
        
        -- Если цель слишком далеко, прекращаем преследование
        if distance > 150 then
            print("Цель слишком далеко, прекращаем преследование")
            activeConnections[target]:Disconnect()
            activeConnections[target] = nil
            return
        end
        
        -- Если игрок достаточно близко, эмулируем нажатие E
        if distance < 5 then
            simulateKeyPress(Enum.KeyCode.E)
            return
        end
        
        -- Обновляем путь каждые 0.5 секунды или если цель значительно сместилась
        if distance > 10 then
            updatePath()
        end
    end)
end

local function findAndFollowBrainrot()
    local targetX = -410.7
    local tolerance = 0.5  -- Увеличили допуск для движущихся целей
    
    for _, brainrotName in ipairs(brainrotList) do
        local obj = workspace:FindFirstChild(brainrotName, true)
        
        if obj then
            local position
            if obj:IsA("Model") then
                position = obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
            elseif obj:IsA("BasePart") then
                position = obj.Position
            end
            
            if position and math.abs(position.X - targetX) <= tolerance then
                print("Начинаем преследование:", brainrotName)
                followMovingObject(obj)
                return  -- Начинаем следить за первым найденным
            end
        end
    end
    
    print("Подходящий Brainrot не найден")
end

findAndFollowBrainrot()
