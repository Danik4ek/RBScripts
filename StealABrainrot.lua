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

local function findBrainrotStats(brainrotInstance)
    -- Ищем GUI в потомках самого Brainrot (BillboardGui)
    local billboardGui = brainrotInstance:FindFirstChildOfClass("BillboardGui")
    if billboardGui then
        for _, guiElement in ipairs(billboardGui:GetDescendants()) do
            if guiElement:IsA("TextLabel") or guiElement:IsA("TextButton") then
                -- Поиск цены ($20K)
                if string.match(guiElement.Text, "^%$[0-9%.]+[KMB]?$") then
                    print("Найдена цена:", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                end
                
                -- Поиск дохода в секунду ($13/s)
                if string.match(guiElement.Text, "%$[0-9%.]+/s") then
                    print("Найден доход:", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                end
                
                -- Поиск редкости (Common/Rare/Epic и т.д.)
                if guiElement.Text == "Common" or guiElement.Text == "Rare" 
                   or guiElement.Text == "Epic" or guiElement.Text == "Legendary" or guiElement.Text == "Mythic" or guiElement.Text == "Brainrot God" or guiElement.Text == "Secret" then
                    print("Найдена редкость:", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                end
            end
        end
    end
    
    -- Дополнительно проверяем PlayerGui на случай, если статистика там
    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
    for _, screenGui in ipairs(playerGui:GetChildren()) do
        if screenGui:IsA("ScreenGui") then
            for _, guiElement in ipairs(screenGui:GetDescendants()) do
                if (guiElement:IsA("TextLabel") or guiElement:IsA("TextButton")) 
                   and string.find(guiElement.Name:lower(), "brainrot") then
                    -- Анализ текста элемента
                    if string.match(guiElement.Text, "^%$[0-9%.]+[KMB]?$") then
                        print("Найдена цена (в PlayerGui):", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                    elseif string.match(guiElement.Text, "%$[0-9%.]+/s") then
                        print("Найден доход (в PlayerGui):", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                    elseif guiElement.Text == "Common" or guiElement.Text == "Rare" 
                           or guiElement.Text == "Epic" or guiElement.Text == "Legendary" then
                        print("Найдена редкость (в PlayerGui):", guiElement:GetFullName(), "| Текст:", guiElement.Text)
                    end
                end
            end
        end
    end
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
                    findBrainrotStats(obj) -- Анализируем статистику Brainrot
                    followMovingObject(obj)
                    break
                end
            end
        end
    end
end

findAndFollowBrainrot()
