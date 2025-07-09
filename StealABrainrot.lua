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

local function findBrainrotText(brainrotInstance)
    -- Получаем имя Brainrot для поиска в тексте
    local brainrotName = brainrotInstance.Name
    print("\n=== Поиск текста для:", brainrotName, "===")
    
    -- 1. Поиск BillboardGui/SurfaceGui на самом объекте и его частях
    for _, part in ipairs(brainrotInstance:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, gui in ipairs(part:GetDescendants()) do
                if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and gui.Enabled then
                    print("Найден GUI на части:", part:GetFullName())
                    analyzeGuiForBrainrotInfo(gui, brainrotName)
                end
            end
        end
    end
    
    -- 2. Поиск по всему Workspace (на случай если GUI прикреплен отдельно)
    for _, gui in ipairs(workspace:GetDescendants()) do
        if (gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and gui.Adornee == brainrotInstance then
            print("Найден GUI в Workspace:", gui:GetFullName())
            analyzeGuiForBrainrotInfo(gui, brainrotName)
        end
    end
    
    -- 3. Поиск в PlayerGui и StarterGui
    local function searchInPlayerGui(guiContainer)
        for _, screenGui in ipairs(guiContainer:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                for _, guiElement in ipairs(screenGui:GetDescendants()) do
                    if guiElement:IsA("TextLabel") or guiElement:IsA("TextButton") then
                        local text = guiElement.Text or ""
                        if text:find(brainrotName, 1, true) then  -- Поиск без учета регистра
                            print("Найден текст в PlayerGui:", guiElement:GetFullName())
                            extractBrainrotInfo(text, brainrotName)
                        end
                    end
                end
            end
        end
    end
    
    searchInPlayerGui(game:GetService("Players").LocalPlayer.PlayerGui)
    searchInPlayerGui(game:GetService("StarterGui"))
    
    -- 4. Проверка ReplicatedStorage (на случай хранения шаблонов)
    for _, item in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") then
            local text = item.Text or ""
            if text:find(brainrotName, 1, true) then
                print("Найден текст в ReplicatedStorage:", item:GetFullName())
                extractBrainrotInfo(text, brainrotName)
            end
        end
    end
end

-- Вспомогательная функция для анализа GUI
local function analyzeGuiForBrainrotInfo(gui, brainrotName)
    for _, element in ipairs(gui:GetDescendants()) do
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            local text = element.Text or ""
            if text ~= "" then
                print("Элемент GUI:", element:GetFullName(), "| Текст:", text)
                if text:find(brainrotName, 1, true) then
                    extractBrainrotInfo(text, brainrotName)
                end
            end
        end
    end
end

-- Вспомогательная функция для извлечения информации из текста
local function extractBrainrotInfo(text, brainrotName)
    -- Поиск редкости
    local rarities = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God", "Secret"}
    for _, rarity in ipairs(rarities) do
        if text:find(rarity) then
            print("Редкость:", rarity)
        end
    end
    
    -- Поиск цены ($100, $1.5K, $2M)
    local pricePattern = "%$[0-9%.]+[KMB]?"
    local price = text:match(pricePattern)
    if price then
        print("Цена:", price)
    end
    
    -- Поиск дохода ($50/s, $1.2K/s)
    local incomePattern = "%$[0-9%.]+[KMB]?/s"
    local income = text:match(incomePattern)
    if income then
        print("Доход в секунду:", income)
    end
    
    -- Поиск уровня (Level 5, Lvl 10)
    local levelPattern = "[Ll]evel?%s*[0-9]+"
    local level = text:match(levelPattern)
    if level then
        print("Уровень:", level)
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
                    currentlyFollowing = obj
                    findBrainrotText(obj) -- Анализируем статистику Brainrot
                    break
                end
            end
        end
    end
end

findAndFollowBrainrot()
