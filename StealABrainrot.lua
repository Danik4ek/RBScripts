local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local activeConnections = {}
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local currentlyFollowing = nil

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

local function findBrainrotStats(brainrotInstance)
    print("\n=== Полный анализ объекта: "..brainrotInstance:GetFullName().." ===")
    
    -- 1. Выводим всех непосредственных детей объекта
    print("\nНепосредственные дети объекта:")
    for _, child in ipairs(brainrotInstance:GetChildren()) do
        print(child:GetFullName(), "| Тип:", child.ClassName)
    end
    
    -- 2. Рекурсивно выводим всю иерархию объекта
    local function printHierarchy(obj, indent)
        indent = indent or 0
        local prefix = string.rep("  ", indent)
        print(prefix..obj:GetFullName(), "| Тип:", obj.ClassName)
        for _, child in ipairs(obj:GetChildren()) do
            printHierarchy(child, indent + 1)
        end
    end
    
    print("\nПолная иерархия объекта:")
    printHierarchy(brainrotInstance)
    
    -- 3. Поиск статистики во всех потомках
    print("\nПоиск статистики во всех потомках:")
    for _, descendant in ipairs(brainrotInstance:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            -- Поиск цены ($20K)
            if string.match(descendant.Text or "", "^%$[0-9%.]+[KMB]?$") then
                print("НАЙДЕНА ЦЕНА:", descendant:GetFullName(), "| Текст:", descendant.Text)
            end
            
            -- Поиск дохода в секунду ($13/s)
            if string.match(descendant.Text or "", "%$[0-9%.]+/s") then
                print("НАЙДЕН ДОХОД:", descendant:GetFullName(), "| Текст:", descendant.Text)
            end
            
            -- Поиск редкости
            if descendant.Text == "Common" or descendant.Text == "Rare" or 
               descendant.Text == "Epic" or descendant.Text == "Legendary" or 
               descendant.Text == "Mythic" or descendant.Text == "Brainrot God" or 
               descendant.Text == "Secret" then
                print("НАЙДЕНА РЕДКОСТЬ:", descendant:GetFullName(), "| Текст:", descendant.Text)
            end
            
            -- Выводим все текстовые элементы для отладки
            if descendant.Text and descendant.Text ~= "" then
                print("Текстовый элемент:", descendant:GetFullName(), "| Текст:", descendant.Text)
            end
        end
    end
    
    print("=== Анализ завершён ===\n")
end

-- Интеграция с вашим существующим скриптом
local function findAndFollowBrainrot()
    local targetX = -410.7
    local tolerance = 2.0
    
    while task.wait(0.3) do
        if currentlyFollowing and currentlyFollowing:IsDescendantOf(workspace) then
            local targetPos = currentlyFollowing:GetPivot().Position
            if math.abs(targetPos.X - targetX) <= tolerance and targetPos.Z < 255 then
                continue
            else
                currentlyFollowing = nil
            end
        end

        for _, brainrotName in ipairs(brainrotList) do
            local obj = workspace:FindFirstChild(brainrotName, true)
            if obj and obj ~= currentlyFollowing then
                local position = obj:GetPivot().Position
                if math.abs(position.X - targetX) <= tolerance and position.Z < 255 then
                    print("Начинаем преследование:", brainrotName)
                    currentlyFollowing = obj
                    findBrainrotStats(obj) -- Анализируем статистику Brainrot
                    break
                end
            end
        end
    end
end

findAndFollowBrainrot()
