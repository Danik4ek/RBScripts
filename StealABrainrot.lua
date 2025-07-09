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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function printPosition()
    local position = humanoidRootPart.Position
    print(string.format(
        "Позиция игрока: X=%.2f, Y=%.2f, Z=%.2f (CFrame: %s)",
        position.X,
        position.Y,
        position.Z,
        tostring(humanoidRootPart.CFrame)
    ))
end

-- Вариант 1: Вывод при изменении позиции
local lastPosition
RunService.Heartbeat:Connect(function()
    local currentPos = humanoidRootPart.Position
    if not lastPosition or (currentPos - lastPosition).Magnitude > 1 then
        lastPosition = currentPos
        printPosition()
    end
end)

local function moveToObject(target)
    -- Проверяем, что скрипт выполняется на клиенте
    if not game:GetService("RunService"):IsClient() then
        error("Эта функция должна работать в LocalScript")
        return false
    end

    -- Получаем сервисы
    local Players = game:GetService("Players")
    local PathfindingService = game:GetService("PathfindingService")
    
    -- Получаем персонажа игрока с проверкой
    local player = Players.LocalPlayer
    if not player then return false end
    
    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        print("У персонажа нет необходимых компонентов")
        return false
    end

    -- Проверка цели
    if not target or not target:IsDescendantOf(workspace) then
        print("Цель не существует или не в Workspace")
        return false
    end
    
    -- Поиск целевой части
    local targetPart = target:FindFirstChild("RootPart") or 
                      target:FindFirstChildWhichIsA("BasePart") or
                      target.PrimaryPart
    
    if not targetPart then
        print("У цели нет подходящей части для перемещения")
        return false
    end

    -- Настройка и расчет пути
    local path = PathfindingService:CreatePath({
        AgentRadius = 1.5,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    local success, errorMsg = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPart.Position)
    end)
    
    if not success then
        print("Ошибка расчета пути:", errorMsg)
        return false
    end

    -- Движение по точкам
    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(waypoint.Position)
            
            local reached
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
                reached = humanoid.MoveToFinished:Wait()  -- Ждем завершения прыжка
            else
                reached = humanoid.MoveToFinished:Wait()  -- Ждем достижения точки
            end
            
            if not reached then
                print("Прервано перед достижением точки")
                return false
            end
        end
        print("Успешно достигли цели!")
        return true
    else
        print("Не удалось построить маршрут. Статус:", path.Status)
        return false
    end
end

for _, brainrotName in ipairs(brainrotList) do
    local found = workspace:FindFirstChild(brainrotName)
    if found then
        print(brainrotName .. " — идет")
        moveToObject(found)
        RootPart = found:FindFirstChild("RootPart")
        print(RootPart.Position.X, RootPart.Position.Y, RootPart.Position.Z)
        
    else
        print(brainrotName .. " — нету на сцене")
    end
end
