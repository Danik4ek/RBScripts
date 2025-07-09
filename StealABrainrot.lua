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
        task.wait(1)
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
    if not target or not target:IsDescendantOf(workspace) then return end

    -- Останавливаем предыдущее следование
    if activeConnections[target] then
        activeConnections[target]:Disconnect()
        activeConnections[target] = nil
    end

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Оптимизация: кешируем targetPart
    local targetPart = target:FindFirstChild("HumanoidRootPart") or 
                     target:FindFirstChildWhichIsA("BasePart") or
                     target.PrimaryPart
    if not targetPart then return end

    local lastPathUpdate = 0
    local lastPosition = targetPart.Position

    activeConnections[target] = RunService.Heartbeat:Connect(function(deltaTime)
        -- Быстрая проверка расстояния для взаимодействия
        local distance = (targetPart.Position - rootPart.Position).Magnitude
        
        -- Приоритет: если очень близко - спамим E
        if distance < 8 then
            simulateKeyPress(Enum.KeyCode.E)
            
            -- Дополнительное приближение если не достаточно близко
            if distance > 1 then
                humanoid:MoveTo(targetPart.Position)
            else
                humanoid:MoveTo(rootPart.Position) -- Стоим на месте
            end
            return
        end

        -- Обновляем путь только если:
        -- 1. Прошло >0.5 сек с последнего обновления
        -- 2. Цель сместилась >5 studs
        -- 3. Мы не слишком близко
        if (os.clock() - lastPathUpdate > 0.5) or 
           ((targetPart.Position - lastPosition).Magnitude > 3) then
            
            lastPathUpdate = os.clock()
            lastPosition = targetPart.Position
            
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })

            local success = pcall(function()
                path:ComputeAsync(rootPart.Position, targetPart.Position)
            end)

            if success and path.Status == Enum.PathStatus.Success then
                -- Очищаем текущее движение
                humanoid:MoveTo(rootPart.Position)
                
                for _, waypoint in ipairs(path:GetWaypoints()) do
                    -- Проверяем актуальность цели
                    if (targetPart.Position - rootPart.Position).Magnitude > 100 then break end
                    
                    humanoid:MoveTo(waypoint.Position)
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                    end
                    
                    -- Быстрая проверка расстояния во время движения
                    if (targetPart.Position - rootPart.Position).Magnitude < 8 then
                        simulateKeyPress(Enum.KeyCode.E)
                        break
                    end
                    
                    -- Ждем либо завершения движения, либо изменения расстояния
                    local startTime = os.clock()
                    while os.clock() - startTime < 1 and 
                          (humanoid.MoveDirection.Magnitude > 0.1) and
                          (targetPart.Position - rootPart.Position).Magnitude > 5 do
                        task.wait()
                    end
                end
            end
        end
    end)
end

local function findAndFollowBrainrot()
    local targetX = -410.7
    local tolerance = 2.0  -- Увеличенный допуск
    
    while task.wait(0.5) do  -- Постоянный поиск цели
        for _, brainrotName in ipairs(brainrotList) do
            local obj = workspace:FindFirstChild(brainrotName, true)
            if obj then
                local position = obj:GetPivot().Position
                if math.abs(position.X - targetX) <= tolerance then
                    print("Начинаем преследование:", brainrotName)
                    followMovingObject(obj)
                    return
                end
            end
        end
        print("Поиск цели...")
    end
end

findAndFollowBrainrot()
