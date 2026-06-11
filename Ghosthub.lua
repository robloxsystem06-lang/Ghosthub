--[[
    👻 GHOST HUB - SCRIPT AVANÇADO PARA BLOX FRUITS
    Inspirado em Redz Hub, Maru Hub, Banana Hub
    Keyless • Interface Moderna • Todas Funções
    Compatível com todos executores (Delta, Krnl, Fluxus, etc.)
    
    ⚠️ Use com responsabilidade. Conta secundária recomendada.
    ⚠️ Este script é educacional. Não me responsabilizo por bans.
]]

-- ============================================
-- CONFIGURAÇÕES INICIAIS & ANTI-DETECÇÃO
-- ============================================
local ScriptName = "GhostHub"
local ScriptVersion = "v1.0.0"
local ScriptAuthor = "Ghost"

-- Anti-Detecção Básica
pcall(function()
    getgenv().GhostHub_Config = nil
    getgenv().GhostHub_Data = nil
end)

-- ============================================
-- SERVIÇOS ROBLOX
-- ============================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ============================================
-- VARIÁVEIS GLOBAIS
-- ============================================
local GhostHub = {
    Config = {},
    Data = {
        Enemies = {},
        Fruits = {},
        NPCs = {},
        Players = {},
        ESP_Objects = {},
        Teleports = {},
        Stats = {},
        Weapons = {},
        Quests = {}
    },
    Connections = {},
    Toggles = {},
    GUI = {},
    LoopConnections = {}
}

-- ============================================
-- UTILITÁRIOS
-- ============================================
local function Notify(Title, Text, Duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title or "Ghost Hub",
            Text = Text or "",
            Duration = Duration or 5,
            Icon = ""
        })
    end)
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoidRootPart()
    local Char = GetCharacter()
    return Char and Char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local Char = GetCharacter()
    return Char and Char:FindFirstChild("Humanoid")
end

local function SafeCall(Func, ...)
    local Success, Result = pcall(Func, ...)
    if not Success then
        warn("[GhostHub] Erro:", Result)
    end
    return Success, Result
end

local function Round(Number, Decimals)
    return math.floor(Number * 10^Decimals + 0.5) / 10^Decimals
end

local function FormatNumber(Num)
    if Num >= 1e9 then
        return string.format("%.1fB", Num / 1e9)
    elseif Num >= 1e6 then
        return string.format("%.1fM", Num / 1e6)
    elseif Num >= 1e3 then
        return string.format("%.1fK", Num / 1e3)
    else
        return tostring(Num)
    end
end

-- ============================================
-- SISTEMA DE CONFIGURAÇÕES (AUTO-SAVE)
-- ============================================
local ConfigManager = {}
ConfigManager.FilePath = "GhostHub_Settings.json"

function ConfigManager:Save()
    local Success, Json = pcall(function()
        return HttpService:JSONEncode(GhostHub.Config)
    end)
    if Success then
        writefile(ConfigManager.FilePath, Json)
    end
end

function ConfigManager:Load()
    local Success, Data = pcall(function()
        return readfile(ConfigManager.FilePath)
    end)
    if Success then
        local Decoded = HttpService:JSONDecode(Data)
        for Key, Value in pairs(Decoded) do
            GhostHub.Config[Key] = Value
        end
    end
end

-- Configurações Padrão
GhostHub.Config = {
    -- Farm
    AutoFarm = false,
    AutoFarmRange = 100,
    AutoFarmMethod = "Sword", -- Sword, Gun, Fruit, Melee
    BringMob = false,
    BringMobRange = 200,
    FastAttack = false,
    
    -- Quest
    AutoQuest = false,
    
    -- Haki
    AutoHaki = false,
    AutoKen = false,
    AutoSoru = false,
    AutoBuso = false,
    
    -- Stats
    AutoStats = false,
    StatsRatio = {Melee = 1, Defense = 2, Sword = 1, Gun = 0, Fruit = 0},
    
    -- Events
    AutoSeaBeast = false,
    AutoBoss = false,
    AutoRaid = false,
    AutoFactory = false,
    
    -- Fruit
    AutoFruitSniper = false,
    AutoStoreFruit = false,
    FruitFilter = {"Buddha", "Dough", "Dragon", "Venom", "Spirit", "Leopard", "Kitsune"},
    
    -- ESP
    ESPFruits = false,
    ESPPlayers = false,
    ESPEnemies = false,
    ESPNPCs = false,
    ESPChests = false,
    
    -- Teleport
    TeleportEnabled = false,
    SelectedTeleport = "Pirate Village",
    
    -- Visual
    UITheme = "Ghost", -- Ghost, Dark, Light
    UIScale = 1.0,
    
    -- Misc
    AntiAFK = true,
    AutoEquip = true,
    WeaponPriority = "Sword",
    SpeedBoost = false,
    SpeedAmount = 50,
    
    -- Performance
    OptimizationMode = false,
    RenderDistance = 500,
    ParticleReduction = true
}

ConfigManager:Load()

-- ============================================
-- UI - INTERFACE MODERNA COM ABAS
-- ============================================
local function CreateUI()
    -- Proteção contra múltiplas UIs
    if GhostHub.GUI.Main then
        GhostHub.GUI.Main:Destroy()
    end
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GhostHub_UI"
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    GhostHub.GUI.ScreenGui = ScreenGui
    
    -- Botão Toggle (móvel)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "👻"
    ToggleButton.TextSize = 26
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ScreenGui
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
    
    -- Arrastar Toggle
    local DraggingToggle = false
    local ToggleDragStart, TogglePosStart
    
    ToggleButton.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            DraggingToggle = true
            ToggleDragStart = Input.Position
            TogglePosStart = ToggleButton.Position
            
            if Input.UserInputType == Enum.UserInputType.Touch then
                -- Verificar clique rápido para abrir/fechar
                task.delay(0.15, function()
                    if DraggingToggle and (Input.Position - ToggleDragStart).Magnitude < 8 then
                        GhostHub.GUI.MainFrame.Visible = not GhostHub.GUI.MainFrame.Visible
                        DraggingToggle = false
                    end
                end)
            end
        end
    end)
    
    ToggleButton.InputEnded:Connect(function(Input)
        if DraggingToggle and (Input.Position - ToggleDragStart).Magnitude < 8 then
            GhostHub.GUI.MainFrame.Visible = not GhostHub.GUI.MainFrame.Visible
        end
        DraggingToggle = false
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if DraggingToggle and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - ToggleDragStart
            ToggleButton.Position = UDim2.new(
                TogglePosStart.X.Scale,
                TogglePosStart.X.Offset + Delta.X,
                TogglePosStart.Y.Scale,
                TogglePosStart.Y.Offset + Delta.Y
            )
        end
    end)
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    GhostHub.GUI.MainFrame = MainFrame
    
    -- Borda Neon
    local MainBorder = Instance.new("Frame")
    MainBorder.Size = UDim2.new(1, 4, 1, 4)
    MainBorder.Position = UDim2.new(0, -2, 0, -2)
    MainBorder.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
    MainBorder.BackgroundTransparency = 0.5
    MainBorder.BorderSizePixel = 0
    MainBorder.Parent = MainFrame
    Instance.new("UICorner", MainBorder).CornerRadius = UDim.new(0, 13)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(100, 70, 220)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "👻 GHOST HUB | " .. ScriptVersion
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 18
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    -- Abas
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 130, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 12)
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 2)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    -- Conteúdo das Abas
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -140, 1, -55)
    ContentFrame.Position = UDim2.new(0, 135, 0, 55)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 10)
    
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -10, 1, -10)
    ContentScroll.Position = UDim2.new(0, 5, 0, 5)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
    ContentScroll.Parent = ContentFrame
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 6)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentScroll
    
    GhostHub.GUI.ContentScroll = ContentScroll
    GhostHub.GUI.ContentList = ContentList
    
    -- Status Bar
    local StatusBar = Instance.new("Frame")
    StatusBar.Size = UDim2.new(1, -10, 0, 30)
    StatusBar.Position = UDim2.new(0, 5, 1, -35)
    StatusBar.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    StatusBar.BorderSizePixel = 0
    StatusBar.Parent = MainFrame
    Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0, 8)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 1, 0)
    StatusLabel.Position = UDim2.new(0, 5, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "👻 Pronto para dominar!"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusBar
    
    GhostHub.GUI.StatusLabel = StatusLabel
    
    -- Sistema de Abas
    local Tabs = {
        {Name = "⚔️ Farm", Page = "Farm"},
        {Name = "👑 Bosses", Page = "Bosses"},
        {Name = "👁️ ESP", Page = "ESP"},
        {Name = "🍈 Frutas", Page = "Fruits"},
        {Name = "🏝️ Teleport", Page = "Teleport"},
        {Name = "💪 Stats", Page = "Stats"},
        {Name = "⚙️ Config", Page = "Config"}
    }
    
    local TabButtons = {}
    local CurrentTab = "Farm"
    
    -- Função para criar botão Toggle
    local function CreateToggle(Page, Name, Default, Callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 22, 45)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = Page
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = Name
        ToggleLabel.TextColor3 = Color3.fromRGB(220, 210, 255)
        ToggleLabel.TextSize = 13
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleStatus = Instance.new("TextButton")
        ToggleStatus.Size = UDim2.new(0, 45, 0, 22)
        ToggleStatus.Position = UDim2.new(1, -58, 0, 8)
        ToggleStatus.BackgroundColor3 = Default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(255, 60, 60)
        ToggleStatus.BorderSizePixel = 0
        ToggleStatus.Text = Default and "ON" or "OFF"
        ToggleStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleStatus.TextSize = 10
        ToggleStatus.Font = Enum.Font.GothamBlack
        ToggleStatus.AutoButtonColor = false
        ToggleStatus.Parent = ToggleFrame
        Instance.new("UICorner", ToggleStatus).CornerRadius = UDim.new(0, 5)
        
        local IsEnabled = Default or false
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        ToggleButton.MouseButton1Click:Connect(function()
            IsEnabled = not IsEnabled
            ToggleStatus.BackgroundColor3 = IsEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(255, 60, 60)
            ToggleStatus.Text = IsEnabled and "ON" or "OFF"
            
            if Callback then
                Callback(IsEnabled)
            end
        end)
        
        return ToggleFrame
    end
    
    -- Função para criar Dropdown
    local function CreateDropdown(Page, Name, Options, Default, Callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 22, 45)
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Parent = Page
        Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Size = UDim2.new(0, 150, 1, 0)
        DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Text = Name
        DropdownLabel.TextColor3 = Color3.fromRGB(220, 210, 255)
        DropdownLabel.TextSize = 12
        DropdownLabel.Font = Enum.Font.GothamBold
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Size = UDim2.new(0, 120, 0, 24)
        DropdownButton.Position = UDim2.new(1, -132, 0, 7)
        DropdownButton.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Text = Default or Options[1]
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 11
        DropdownButton.Font = Enum.Font.GothamBold
        DropdownButton.AutoButtonColor = false
        DropdownButton.Parent = DropdownFrame
        Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 5)
        
        local CurrentIndex = 1
        for i, opt in ipairs(Options) do
            if opt == Default then
                CurrentIndex = i
                break
            end
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            CurrentIndex = CurrentIndex + 1
            if CurrentIndex > #Options then CurrentIndex = 1 end
            DropdownButton.Text = Options[CurrentIndex]
            
            if Callback then
                Callback(Options[CurrentIndex])
            end
        end)
        
        return DropdownFrame
    end
    
    -- Função para criar Slider
    local function CreateSlider(Page, Name, Min, Max, Default, Callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 55)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 22, 45)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Page
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(1, -20, 0, 18)
        SliderLabel.Position = UDim2.new(0, 10, 0, 4)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = Name .. ": " .. Default
        SliderLabel.TextColor3 = Color3.fromRGB(220, 210, 255)
        SliderLabel.TextSize = 11
        SliderLabel.Font = Enum.Font.GothamBold
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, -40, 0, 8)
        SliderBg.Position = UDim2.new(0, 20, 0, 28)
        SliderBg.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
        SliderBg.BorderSizePixel = 0
        SliderBg.Parent = SliderFrame
        Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 4)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBg
        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)
        
        local SliderBtn = Instance.new("TextButton")
        SliderBtn.Size = UDim2.new(1, 0, 1, 0)
        SliderBtn.BackgroundTransparency = 1
        SliderBtn.Text = ""
        SliderBtn.Parent = SliderFrame
        
        local function UpdateSlider(Input)
            local MousePos = UserInputService:GetMouseLocation()
            local SliderPos = SliderBg.AbsolutePosition
            local SliderSize = SliderBg.AbsoluteSize
            local Percent = math.clamp((MousePos.X - SliderPos.X) / SliderSize.X, 0, 1)
            local Value = math.floor(Min + (Max - Min) * Percent)
            
            SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
            SliderLabel.Text = Name .. ": " .. Value
            
                        if Callback then
                Callback(Value)
            end
        end
        
        SliderBtn.MouseButton1Down:Connect(function()
            local Connection
            Connection = RunService.RenderStepped:Connect(function()
                UpdateSlider()
            end)
            
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Connection:Disconnect()
                end
            end)
        end)
        
        return SliderFrame
    end
    
    -- Função para criar botão
    local function CreateButton(Page, Name, Icon, Callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 38)
        Button.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
        Button.BorderSizePixel = 0
        Button.Text = (Icon or "") .. " " .. Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 13
        Button.Font = Enum.Font.GothamBold
        Button.AutoButtonColor = false
        Button.Parent = Page
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
        
        Button.MouseButton1Click:Connect(function()
            if Callback then Callback() end
        end)
        
        return Button
    end
    
    -- Criar Páginas
    local Pages = {}
    
    for _, Tab in ipairs(Tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 40)
        TabButton.BackgroundColor3 = Tab.Page == "Farm" and Color3.fromRGB(140, 100, 255) or Color3.fromRGB(30, 22, 45)
        TabButton.BorderSizePixel = 0
        TabButton.Text = Tab.Name
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.GothamBold
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
        
        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = Tab.Page == "Farm"
        Page.Parent = ContentScroll
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 4)
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        
        Pages[Tab.Page] = Page
        TabButtons[Tab.Page] = TabButton
        
        TabButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabButtons) do btn.BackgroundColor3 = Color3.fromRGB(30, 22, 45) end
            for _, pg in pairs(Pages) do pg.Visible = false end
            TabButton.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
            Page.Visible = true
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
    end
    
    -- Preencher Páginas
    CreateToggle(Pages["Farm"], "Auto Farm", false, function(V) GhostHub.Config.AutoFarm = V end)
    CreateDropdown(Pages["Farm"], "Metodo", {"Sword", "Gun", "Fruit", "Melee"}, "Sword", function(V) GhostHub.Config.AutoFarmMethod = V end)
    CreateSlider(Pages["Farm"], "Alcance", 10, 500, 100, function(V) GhostHub.Config.AutoFarmRange = V end)
    CreateToggle(Pages["Farm"], "Bring Mob", false, function(V) GhostHub.Config.BringMob = V end)
    CreateToggle(Pages["Farm"], "Fast Attack", false, function(V) GhostHub.Config.FastAttack = V end)
    CreateToggle(Pages["Farm"], "Auto Quest", false, function(V) GhostHub.Config.AutoQuest = V end)
    
    CreateToggle(Pages["Bosses"], "Auto Boss", false, function(V) GhostHub.Config.AutoBoss = V end)
    CreateToggle(Pages["Bosses"], "Auto Sea Beast", false, function(V) GhostHub.Config.AutoSeaBeast = V end)
    
    CreateToggle(Pages["ESP"], "ESP Frutas", false, function(V) GhostHub.Config.ESPFruits = V end)
    CreateToggle(Pages["ESP"], "ESP Inimigos", false, function(V) GhostHub.Config.ESPEnemies = V end)
    CreateToggle(Pages["ESP"], "ESP Baús", false, function(V) GhostHub.Config.ESPChests = V end)
    
    CreateToggle(Pages["Fruits"], "Auto Fruit Sniper", false, function(V) GhostHub.Config.AutoFruitSniper = V end)
    
    CreateToggle(Pages["Stats"], "Auto Stats", false, function(V) GhostHub.Config.AutoStats = V end)
    CreateToggle(Pages["Stats"], "Auto Haki", false, function(V) GhostHub.Config.AutoHaki = V end)
    CreateToggle(Pages["Stats"], "Auto Ken", false, function(V) GhostHub.Config.AutoKen = V end)
    
    CreateToggle(Pages["Config"], "Anti AFK", true, function(V) GhostHub.Config.AntiAFK = V end)
    CreateButton(Pages["Config"], "Salvar Config", "💾", function() ConfigManager:Save() Notify("Ghost Hub", "Salvo!", 2) end)
    
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Pages["Farm"]:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 20)
    
    -- Arrastar
    local dm, ds, dp
    Header.InputBegan:Connect(function(I)
        if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
            dm = true ds = I.Position dp = MainFrame.Position
        end
    end)
    Header.InputEnded:Connect(function() dm = false end)
    UserInputService.InputChanged:Connect(function(I)
        if dm then
            local D = I.Position - ds
            MainFrame.Position = UDim2.new(dp.X.Scale, dp.X.Offset + D.X, dp.Y.Scale, dp.Y.Offset + D.Y)
        end
    end)
end

-- ============================================
-- SISTEMAS DE FARM
-- ============================================
local function GetEnemies()
    local List = {}
    local F = Workspace:FindFirstChild("Enemies")
    if not F then return List end
    for _, E in pairs(F:GetChildren()) do
        pcall(function()
            if E:FindFirstChild("Humanoid") and E.Humanoid.Health > 0 and E:FindFirstChild("HumanoidRootPart") then
                table.insert(List, E)
            end
        end)
    end
    return List
end

local function GetNearestEnemy()
    local HRP = GetHumanoidRootPart()
    if not HRP then return nil end
    local Best, D = nil, GhostHub.Config.AutoFarmRange or 200
    for _, E in pairs(GetEnemies()) do
        local Dist = (E.HumanoidRootPart.Position - HRP.Position).Magnitude
        if Dist < D then D = Dist Best = E end
    end
    return Best
end

local function EquipWeapon()
    if not GhostHub.Config.AutoEquip then return end
    local H = GetHumanoid()
    if not H then return end
    for _, T in pairs(LocalPlayer.Backpack:GetChildren()) do
        if T:IsA("Tool") then H:EquipTool(T) return end
    end
end

local function Attack()
    for i = 1, 6 do
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0)
            task.wait(GhostHub.Config.FastAttack and 0.03 or 0.08)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0)
            task.wait(GhostHub.Config.FastAttack and 0.03 or 0.08)
        end)
    end
end

-- ============================================
-- ESP
-- ============================================
local function UpdateESP()
    for _, O in pairs(GhostHub.Data.ESP_Objects) do pcall(function() O:Destroy() end) end
    GhostHub.Data.ESP_Objects = {}
    
    if GhostHub.Config.ESPFruits then
        for _, O in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if O:IsA("BasePart") and O.Name:lower():find("fruit") and O.Name ~= "Fruit" then
                    local H = Instance.new("Highlight"); H.FillColor = Color3.fromRGB(255,180,0); H.Parent = O
                    table.insert(GhostHub.Data.ESP_Objects, H)
                end
            end)
        end
    end
    if GhostHub.Config.ESPChests then
        for _, O in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if O:IsA("BasePart") and O.Name:lower():find("chest") then
                    local H = Instance.new("Highlight"); H.FillColor = Color3.fromRGB(255,255,0); H.Parent = O
                    table.insert(GhostHub.Data.ESP_Objects, H)
                end
            end)
        end
    end
    if GhostHub.Config.ESPEnemies then
        for _, E in pairs(GetEnemies()) do
            pcall(function()
                local H = Instance.new("Highlight"); H.FillColor = Color3.fromRGB(255,80,80); H.Parent = E
                table.insert(GhostHub.Data.ESP_Objects, H)
            end)
        end
    end
end

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
task.spawn(function()
    while true do
        pcall(function()
            local HRP = GetHumanoidRootPart()
            if HRP then
                -- Anti AFK
                if GhostHub.Config.AntiAFK then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0)
                end
                
                -- Auto Farm
                if GhostHub.Config.AutoFarm then
                    local E = GetNearestEnemy()
                    if E then
                        EquipWeapon()
                        if GhostHub.Config.BringMob then
                            E.HumanoidRootPart.CFrame = HRP.CFrame * CFrame.new(0,0,-5)
                        else
                            HRP.CFrame = E.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                        end
                        Attack()
                    end
                end
                
                -- Auto Quest
                if GhostHub.Config.AutoQuest then
                    for _, NPC in pairs(Workspace:GetDescendants()) do
                        pcall(function()
                            if NPC.Name:lower():find("quest") and NPC:FindFirstChild("Head") and (NPC.Head.Position - HRP.Position).Magnitude < 60 then
                                HRP.CFrame = NPC.Head.CFrame * CFrame.new(0,0,-3)
                                task.wait(0.3)
                                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,nil,0)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,nil,0)
                            end
                        end)
                    end
                end
                
                -- Auto Haki
                if GhostHub.Config.AutoHaki then
                    VirtualInputManager:SendKeyEvent(true,"E",false,nil)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false,"E",false,nil)
                end
                
                -- Auto Ken
                if GhostHub.Config.AutoKen then
                    VirtualInputManager:SendKeyEvent(true,"T",false,nil)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false,"T",false,nil)
                end
                
                -- Auto Sea Beast
                if GhostHub.Config.AutoSeaBeast then
                    for _, O in pairs(Workspace:GetDescendants()) do
                        pcall(function()
                            if O.Name:lower():find("sea") and O:FindFirstChild("Humanoid") and O.Humanoid.Health > 0 then
                                HRP.CFrame = O.HumanoidRootPart.CFrame * CFrame.new(0,0,6)
                                Attack()
                            end
                        end)
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

-- ESP Loop
task.spawn(function()
    while true do
        pcall(UpdateESP)
        task.wait(2)
    end
end)

-- ============================================
-- INICIAR
-- ============================================
CreateUI()
Notify("👻 Ghost Hub", "Script carregado! v1.0.0", 5)
print("👻 Ghost Hub pronto!")
