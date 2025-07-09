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

local function moveToObject(target)
    -- Получаем персонажа игрока
    local player = Workspace:FindFirstChild("kirillllllllllir")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Проверяем что цель существует
    if not target or not target:IsDescendantOf(workspace) then
        print("Цель не существует или не находится в Workspace")
        return false
    end
    
    -- Находим RootPart цели (или любую BasePart)
    local targetPart = target:FindFirstChild("RootPart") or 
                      target:FindFirstChildWhichIsA("BasePart") or
                      target.PrimaryPart
    
    if not targetPart then
        print("У цели нет подходящей части для перемещения")
        return false
    end
    
    -- Создаем путь
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    -- Вычисляем маршрут
    path:ComputeAsync(character.HumanoidRootPart.Position, targetPart.Position)
    
    if path.Status == Enum.PathStatus.Success then
        -- Проходим по точкам маршрута
        for _, waypoint in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
        print("Достигли цели!")
        return true
    else
        print("Не удалось построить маршрут")
        return false
    end
end

for _, brainrotName in ipairs(brainrotList) do
    local found = workspace:FindFirstChild(brainrotName)
    if found then
        print(brainrotName .. " — идет")
        moveToObject(found)
        RootPart = found:FindFirstChild("RootPart")
    else
        print(brainrotName .. " — нету на сцене")
    end
end
