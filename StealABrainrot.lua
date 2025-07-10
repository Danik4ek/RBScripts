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
local currentlyFollowing = nil
local initialPosition = nil
local isCollecting = false

local function simulateKeyPress(key, holdDuration)
    if not VirtualInputManager then return end
    
    if isHoldingE and key == Enum.KeyCode.E then
        VirtualInputManager:SendKeyEvent(false, key, false, nil)
        isHoldingE = false
    end
    
    VirtualInputManager:SendKeyEvent(true, key, false, nil)
    
    if holdDuration then
        isHoldingE = true
        task.delay(holdDuration, function()
            if isHoldingE then
                VirtualInputManager:SendKeyEvent(false, key, false, nil)
                isHoldingE = false
            end
        end)
    else
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

local function getPlayerBalance()
    -- Получаем путь к элементу (из вашего лога)
    local balanceElement = game:GetService("Players").LocalPlayer.PlayerGui.Main.CoinsShop.Content.Items.Template.Buy.Price
    
    if balanceElement and balanceElement:IsA("TextLabel") then
        -- Извлекаем число из текста (удаляем "$" и преобразуем в число)
        local balanceText = balanceElement.Text
        local balanceNumber = tonumber(balanceText:match("%$(%d+)"))
        
        if balanceNumber then
            return balanceNumber
        else
            warn("Не удалось преобразовать баланс в число:", balanceText)
            return 0
        end
    else
        warn("Элемент баланса не найден или не является TextLabel")
        return 0
    end
end

local function collectMoney()
    if isCollecting then return end
    isCollecting = true
    
    -- Прерываем текущее преследование
    if currentlyFollowing then
        releaseAllKeys()
        if activeConnections[currentlyFollowing] then
            activeConnections[currentlyFollowing]:Disconnect()
            activeConnections[currentlyFollowing] = nil
        end
        currentlyFollowing = nil
    end
    
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then 
        isCollecting = false
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then 
        isCollecting = false
        return 
    end

    -- Запоминаем начальную позицию при первом запуске
    if not initialPosition then
        initialPosition = rootPart.Position
        print("Запомнена начальная позиция:", initialPosition)
    end

    -- Определяем траекторию движения
    local path = {}
    local targetZ1, targetZ2
    local xValues = {}
    
    if math.abs(initialPosition.X - (-466)) < 5 then
        -- Левая сторона (x ≈ -466)
        xValues = {-488, -496, -503, -510, -517}
        
        if math.abs(initialPosition.Z - (-100)) < 5 then
            targetZ1, targetZ2 = -113, -88
        elseif math.abs(initialPosition.Z - 7) < 5 then
            targetZ1, targetZ2 = -5, 18
        elseif math.abs(initialPosition.Z - 113) < 5 then
            targetZ1, targetZ2 = 101, 126
        elseif math.abs(initialPosition.Z - 221) < 5 then
            targetZ1, targetZ2 = 208, 232
        end
    elseif math.abs(initialPosition.X - (-352)) < 5 then
        -- Правая сторона (x ≈ -352)
        xValues = {-330, -323, -315, -308, -302}
        
        if math.abs(initialPosition.Z - (-100)) < 5 then
            targetZ1, targetZ2 = -113, -88
        elseif math.abs(initialPosition.Z - 7) < 5 then
            targetZ1, targetZ2 = -5, 18
        elseif math.abs(initialPosition.Z - 113) < 5 then
            targetZ1, targetZ2 = 101, 126
        elseif math.abs(initialPosition.Z - 221) < 5 then
            targetZ1, targetZ2 = 208, 232
        end
    else
        warn("Неизвестная начальная позиция")
        isCollecting = false
        return
    end

    -- Строим путь: первый ряд (z1)
    for _, x in ipairs(xValues) do
        table.insert(path, Vector3.new(x, initialPosition.Y, targetZ1))
    end
    
    -- Строим путь: второй ряд (z2) в обратном порядке
    for i = #xValues, 1, -1 do
        table.insert(path, Vector3.new(xValues[i], initialPosition.Y, targetZ2))
    end

    -- Выполняем движение по точкам
    for i, point in ipairs(path) do
        humanoid:MoveTo(point)
        print("Двигаемся к точке", i, point)
        
        -- Ждем достижения точки (с таймаутом)
        local startTime = os.clock()
        while (rootPart.Position - point).Magnitude > 5 do
            if os.clock() - startTime > 3 then
                warn("Таймаут достижения точки", i)
                break
            end
            task.wait(0.1)
        end
        
        -- Небольшая пауза между точками
        task.wait(0.1)
    end
    
    isCollecting = false
    print("Маршрут завершен!")
end

local function BuyBrainrot(target)
    if not target or not target:IsDescendantOf(workspace) then 
        releaseAllKeys()
        currentlyFollowing = nil
        return 
    end

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
        currentlyFollowing = nil
        return 
    end

    -- Получаем начальный баланс
    local initialBalance = getPlayerBalance()
    print("Начальный баланс:", initialBalance)
    
    currentlyFollowing = target
    local lastPathUpdate = 0
    local lastPosition = targetPart.Position
    local lastBalanceCheck = os.clock()
    local shouldContinue = true

    activeConnections[target] = RunService.Heartbeat:Connect(function()
        if not shouldContinue then return end
        
        -- Проверяем баланс каждые 0.5 секунд
        if os.clock() - lastBalanceCheck > 0.5 then
            local currentBalance = getPlayerBalance()
            lastBalanceCheck = os.clock()
            
            if currentBalance < initialBalance then
                print("Баланс уменьшился! Покупка совершена. Прекращаем преследование.")
                humanoid:MoveTo(rootPart.Position)
                releaseAllKeys()
                activeConnections[target]:Disconnect()
                activeConnections[target] = nil
                currentlyFollowing = nil
                shouldContinue = false
                return
            end
        end
        
        if targetPart.Position.Z >= 255 then
            print("Цель достигла Z ≥ 255, прекращаем преследование")
            humanoid:MoveTo(rootPart.Position)
            releaseAllKeys()
            activeConnections[target]:Disconnect()
            activeConnections[target] = nil
            currentlyFollowing = nil
            shouldContinue = false
            return
        end

        local distance = (targetPart.Position - rootPart.Position).Magnitude
        
        if distance < 5 then
            if os.clock() - lastEPressTime > 0.5 then
                simulateKeyPress(Enum.KeyCode.E, 1)
            end
            
            if distance > 1 then
                humanoid:MoveTo(targetPart.Position)
            else
                humanoid:MoveTo(rootPart.Position)
            end
            return
        else
            releaseAllKeys()
        end

        if (os.clock() - lastPathUpdate > 0.1) or 
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

local function findBrainrot()
    local targetX = -410.7
    local tolerance = 2.0
    
    while task.wait(0.3) do
        -- Не ищем новую цель, если уже следим за кем-то
        if currentlyFollowing and currentlyFollowing:IsDescendantOf(workspace) then
            local targetPos = currentlyFollowing:GetPivot().Position
            if math.abs(targetPos.X - targetX) <= tolerance and targetPos.Z < 255 then
                -- Цель все еще валидна, продолжаем следить
                continue
            else
                -- Цель больше не подходит
                currentlyFollowing = nil
            end
        end

        for _, brainrotName in ipairs(brainrotList) do
            local obj = workspace:FindFirstChild("Noobini pizzanini", true)
            if obj and obj ~= currentlyFollowing then
                local position = obj:GetPivot().Position
                if math.abs(position.X - targetX) <= tolerance and position.Z < 255 then
                    print("Начинаем преследование:", brainrotName)
                    followMovingObject(obj)
                    break
                end
            end
        end
    end
end

local function initCharacter()
    local character = Players.LocalPlayer.Character
    if character then
        local rootPart = character:WaitForChild("HumanoidRootPart")
        if not initialPosition then
            initialPosition = rootPart.Position
        end
    end
end

Players.LocalPlayer.CharacterAdded:Connect(initCharacter)
if Players.LocalPlayer.Character then
    initCharacter()
    findBrainrot()
    collectMoney()
end
