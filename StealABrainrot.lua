local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
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

local isHoldingE = false
local lastEPressTime = 0

local function simulateKeyPress(key, holdDuration)
    if not VirtualInputManager then return end
    
    -- Если уже удерживаем E, сначала отпускаем
    if isHoldingE and key == Enum.KeyCode.E then
        VirtualInputManager:SendKeyEvent(false, key, false, nil)
        isHoldingE = false
    end
    
    -- Нажимаем клавишу
    VirtualInputManager:SendKeyEvent(true, key, false, nil)
    
    -- Если указано время удержания
    if holdDuration then
        isHoldingE = true
        task.delay(holdDuration, function()
            if isHoldingE then
                VirtualInputManager:SendKeyEvent(false, key, false, nil)
                isHoldingE = false
            end
        end)
    else
        -- Короткое нажатие
        task.delay(0.05, function()
            VirtualInputManager:SendKeyEvent(false, key, false, nil)
        end)
    end
    
    lastEPressTime = os.clock()
end

local function releaseAllKeys()
    if isHoldingE then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
        isHoldingE = false
    end
end

local function followMovingObject(target)
    if not target or not target:IsDescendantOf(workspace) then 
        releaseAllKeys()
        return 
    end

    -- Останавливаем предыдущее следование
    if activeConnections[target] then
        releaseAllKeys()
        activeConnections[target]:Disconnect()
        activeConnections[target] = nil
    end

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local targetPart = target:FindFirstChild("HumanoidRootPart") or 
                     target:FindFirstChildWhichIsA("BasePart") or
                     target.PrimaryPart
    if not targetPart then 
        releaseAllKeys()
        return 
    end

    local lastPathUpdate = 0
    local lastPosition = targetPart.Position
    local shouldContinue = true

    activeConnections[target] = RunService.Heartbeat:Connect(function()
        if not shouldContinue then return end
        
        -- Проверяем позицию цели по Z
        if targetPart.Position.Z >= 255 then
            print("Цель достигла Z ≥ 255, прекращаем преследование")
            humanoid:MoveTo(rootPart.Position)
            releaseAllKeys()
            activeConnections[target]:Disconnect()
            activeConnections[target] = nil
            shouldContinue = false
            return
        end

        local distance = (targetPart.Position - rootPart.Position).Magnitude
        
        -- Если очень близко - удерживаем E
        if distance < 5 then
            -- Нажимаем E только если прошло больше 0.5 сек с последнего нажатия
            if os.clock() - lastEPressTime > 0.5 then
                simulateKeyPress(Enum.KeyCode.E, 1) -- Удерживаем 1 секунду
            end
            
            -- Плавное приближение
            if distance > 1.5 then
                humanoid:MoveTo(targetPart.Position)
            else
                humanoid:MoveTo(rootPart.Position)
            end
            return
        else
            releaseAllKeys()
        end

        -- Обновляем путь с учетом частоты
        if (os.clock() - lastPathUpdate > 0.3) or 
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
                humanoid:MoveTo(rootPart.Position)
                
                for _, waypoint in ipairs(path:GetWaypoints()) do
                    if not shouldContinue then break end
                    if targetPart.Position.Z >= 255 then break end
                    
                    humanoid:MoveTo(waypoint.Position)
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                    end
                    
                    -- Проверка расстояния во время движения
                    if (targetPart.Position - rootPart.Position).Magnitude < 5 then
                        if os.clock() - lastEPressTime > 0.5 then
                            simulateKeyPress(Enum.KeyCode.E, 1)
                        end
                        break
                    end
                    
                    task.wait(0.1)
                end
            end
        end
    end)
end

local function findAndFollowBrainrot()
    local targetX = -410.7
    local tolerance = 2.0
    
    while task.wait(0.3) do
        for _, brainrotName in ipairs(brainrotList) do
            local obj = workspace:FindFirstChild(brainrotName, true)
            if obj then
                local position = obj:GetPivot().Position
                if math.abs(position.X - targetX) <= tolerance and position.Z < 255 then
                    print("Начинаем преследование:", brainrotName)
                    followMovingObject(obj)
                    task.wait(1)
                    break
                end
            end
        end
    end
end

findAndFollowBrainrot()
