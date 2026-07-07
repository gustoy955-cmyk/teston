--[[
    RANOX - Script para MESCLAR UMA BOMBA NUCLEAR
    Desenvolvido por Keybrew
    Interface com tema salvável, aplicação imediata e otimização de memória
]]

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)

-- Tabela de Estado Local (Substitui _G e shared para evitar conflitos e vazamentos)
local State = {
    GuerraCooldown = false,
    LaunchAtCoord = false,
    MarkedCoord = nil,
    AutoMerge = false,
    AutoMergeUltra = false,
    AutoPickUp = false,
    AutoWalkPickUp = false,
    InstantPickUp = false,
    LockBase = false,
    AutoUpgrade = false,
    SelectedUpgrades = {},
    
    TargetWalkSpeed = 16,
    WalkSpeedEnabled = false,
    TargetJumpPower = 50,
    JumpPowerEnabled = false,
    InfJumpEnabled = false,
    
    FlySpeed = 50,
    FlyEnabled = false,
    NoclipEnabled = false,
    
    EspEnabled = false,
    EspConnections = {},
    EspFolder = nil
}

-- Configuração da pasta de ESP (Garante que não duplique ao trocar de tema)
local function SetupESPFolder()
    local espName = "RANOX_ESP_FOLDER"
    local parent = pcall(function() return CoreGui end) and CoreGui or Workspace
    if parent:FindFirstChild(espName) then
        parent[espName]:Destroy()
    end
    State.EspFolder = Instance.new("Folder")
    State.EspFolder.Name = espName
    State.EspFolder.Parent = parent
end

SetupESPFolder()

-- Lista de temas disponíveis
local temas_disponiveis = {
    "Default", "Amethyst", "Ocean", "Serenity", "Mocha", 
    "Sunset", "Midnight", "Dark", "Light"
}

-- Garante que a pasta de configurações existe
if not isfolder("RANOXHubConfigs") then
    makefolder("RANOXHubConfigs")
end

-- Função para carregar o tema salvo manualmente
local function carregarTemaSalvo()
    local caminho = "RANOXHubConfigs/theme.txt"
    if isfile(caminho) then
        local sucesso, tema = pcall(function() return readfile(caminho) end)
        if sucesso and tema then
            tema = tema:gsub("%s+", "")
            for _, t in ipairs(temas_disponiveis) do
                if t:lower() == tema:lower() then return t end
            end
        end
    end
    return "Default"
end

-- Variáveis globais da interface
local Window, Rayfield
local Main, UniversalTab, ConfigTab, CreditsTab
local GuiConnections = {} -- Armazena TODAS as conexões para evitar Memory Leaks

-- Função principal para construir toda a interface com um tema específico
local function ConstruirInterface(tema)
    -- Limpa conexões anteriores (Memory Leak fix)
    for _, conn in ipairs(GuiConnections) do
        pcall(function() conn:Disconnect() end)
    end
    GuiConnections = {}

    -- Desativa estados visuais/movimento ao reconstruir
    State.FlyEnabled = false
    State.NoclipEnabled = false
    
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "🔥 RANOX HUB",
        LoadingTitle = "RANOX Hub",
        LoadingSubtitle = "by Keybrew 💣",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "RANOXHubConfigs",
            FileName = "RANOXHub"
        },
        KeySystem = false,
        Theme = tema,
        ToggleUIKeybind = Enum.KeyCode.RightAlt
    })

    Rayfield:Notify({
        Title = "🎨 Tema Atual",
        Content = "Tema: " .. tema,
        Duration = 4,
        Image = 4483362458,
    })

    -- Criação das abas
    Main = Window:CreateTab("⚔️ Principal", 4483362458)
    UniversalTab = Window:CreateTab("🌀 Universal", 4483362458)
    ConfigTab = Window:CreateTab("⚙️ Configurações", 4483362458)
    CreditsTab = Window:CreateTab("📜 Créditos", 4483362458)

    -- ================ UTILITÁRIOS ================
    local function GetPlayerBase()
        local BasesFolder = Workspace:FindFirstChild("Bases")
        if BasesFolder then
            for _, folder in ipairs(BasesFolder:GetChildren()) do
                local attributeValue = folder:GetAttribute("OwnerUserId")
                if attributeValue and tonumber(attributeValue) == PlayerId then
                    return folder
                end
            end
        end
        return nil
    end

    local function TeleportTo(object)
        if not object or not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        -- Fix: Levanta o personagem se ele estiver sentado antes de teleportar
        if hum and hum.Sit then
            hum.Sit = false
            task.wait(0.1)
        end
        
        local position = nil
        if object:IsA("Model") then
            position = object:GetPivot().Position
        elseif object:IsA("BasePart") then
            position = object.Position
        end
        if root and position then
            root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
        end
    end

    -- ================ ABA PRINCIPAL ================
    Main:CreateSection("💣 FUNÇÕES DE GUERRA")
    Main:CreateButton({
        Name = "🧨 Interface de Guerra",
        Callback = function()
            if State.GuerraCooldown then
                Rayfield:Notify({Title = "⏳ Aguarde", Content = "Aguarde 5 segundos para usar novamente.", Duration = 3, Image = 4483362458})
                return
            end
            State.GuerraCooldown = true
            local sucesso, erro = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/SAMUCARARONOB/Inf/refs/heads/main/RANOXv2.lua"))()
            end)
            if sucesso then
                Rayfield:Notify({Title = "✅ Sucesso", Content = "Interface carregada!", Duration = 3, Image = 4483362458})
            else
                Rayfield:Notify({Title = "❌ Erro", Content = "Falha ao carregar.", Duration = 3, Image = 4483362458})
            end
            task.delay(5, function() State.GuerraCooldown = false end)
        end
    })

    Main:CreateSection("🎯 ATAQUE A COORDENADA")
    Main:CreateButton({
        Name = "📍 Marcar Posição",
        Callback = function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                State.MarkedCoord = root.Position
                Rayfield:Notify({Title = "📍 Posição Marcada", Content = string.format("%.1f, %.1f, %.1f", State.MarkedCoord.X, State.MarkedCoord.Y, State.MarkedCoord.Z), Duration = 2})
            end
        end
    })

    Main:CreateToggle({
        Name = "🚀 Lançar Nuke na Coordenada",
        CurrentValue = false,
        Flag = "ToggleLaunchAtCoord",
        Callback = function(Value)
            State.LaunchAtCoord = Value
            if not Value then return end
            task.spawn(function()
                while State.LaunchAtCoord do
                    if not State.MarkedCoord then task.wait(2) continue end
                    local myBase = GetPlayerBase()
                    if myBase and myBase:FindFirstChild("Nukes") then
                        local nukes = {}
                        for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                            if nuke.Name == "Nuke" and nuke.Parent then table.insert(nukes, nuke) end
                        end
                        if #nukes > 0 then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local chosenNuke = nukes[math.random(1, #nukes)]
                                local oldPos = root.CFrame
                                TeleportTo(chosenNuke)
                                task.wait(0.05)
                                ReplicatedStorage.NukeRemotes.PickUp:FireServer(chosenNuke)
                                task.wait(0.05)
                                ReplicatedStorage.NukeRemotes.LaunchConfirm:FireServer(State.MarkedCoord)
                                if oldPos then root.CFrame = oldPos end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    })

    -- Seções de Merge/Pickup (Auto Fusão, Auto Pegar Tudo, etc) seguem o mesmo padrão usando a tabela State...
    Main:CreateSection("⚡ FUSÃO & COLETA")
    Main:CreateToggle({
        Name = "🔗 Auto Fusão",
        CurrentValue = false,
        Flag = "Toggle1",
        Callback = function(Value)
            State.AutoMerge = Value
            while State.AutoMerge do
                local myBase = GetPlayerBase()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame) end
                
                if myBase and myBase:FindFirstChild("Nukes") then
                    local nukeCounts = {}
                    for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                        if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                            local nukeType = nuke.OverheadNuke.TextLabel.Text
                            if nukeType and nukeType ~= "" then
                                nukeCounts[nukeType] = nukeCounts[nukeType] or {}
                                table.insert(nukeCounts[nukeType], nuke)
                            end
                        end
                    end
                    for _, matches in pairs(nukeCounts) do
                        if #matches >= 2 then
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(matches[1])
                            task.wait(0.01)
                            ReplicatedStorage.NukeRemotes.MergeRequest:FireServer(matches[2])
                            break
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end
    })

    Main:CreateSection("🔒 BASE & UPGRADES")
    Main:CreateToggle({
        Name = "🔒 Auto Travar Base",
        CurrentValue = false,
        Flag = "Toggle3",
        Callback = function(Value)
            State.LockBase = Value -- Fix: Removido o Global Leak
            while State.LockBase do
                task.wait()
                ReplicatedStorage.NukeRemotes.RequestLockBase:FireServer()
            end
        end,
    })

    Main:CreateDropdown({
        Name = "🗂️ Selecionar Upgrades",
        Options = {"MAX", "TIER", "LOCKBASE"},
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "Dropdown1",
        Callback = function(Options)
            State.SelectedUpgrades = Options
        end,
    })

    Main:CreateToggle({
        Name = "🔄 Auto Upgrade",
        CurrentValue = false,
        Flag = "Toggle4",
        Callback = function(Value)
            State.AutoUpgrade = Value
            while State.AutoUpgrade do
                -- Fix: Checa se a tabela não está vazia para evitar crash
                if State.SelectedUpgrades and #State.SelectedUpgrades > 0 then
                    for _, upgradeType in ipairs(State.SelectedUpgrades) do
                        if not State.AutoUpgrade then break end
                        ReplicatedStorage.NukeRemotes.PurchaseUpgrade:FireServer(upgradeType)
                    end
                end
                task.wait()
            end
        end,
    })

    -- ================ ABA UNIVERSAL ================
    UniversalTab:CreateSection("✈️ MOVIMENTO AVANÇADO")
    local function HandleFlight()
        local Camera = Workspace.CurrentCamera
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
        if not Root or not Hum then return end
        
        local BVel = Root:FindFirstChild("RANOXFlyForce") or Instance.new("BodyVelocity")
        BVel.Name = "RANOXFlyForce"
        BVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BVel.Parent = Root
        
        local LGyro = Root:FindFirstChild("RANOXFlyGyro") or Instance.new("BodyGyro")
        LGyro.Name = "RANOXFlyGyro"
        LGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        LGyro.CFrame = Root.CFrame
        LGyro.Parent = Root
        
        Hum.PlatformStand = true
        
        local flyConnection
        flyConnection = RunService.RenderStepped:Connect(function()
            if not State.FlyEnabled or not Character or not Root.Parent then
                BVel:Destroy()
                LGyro:Destroy()
                if Hum then Hum.PlatformStand = false end
                flyConnection:Disconnect()
                return
            end
            local Dir = Vector3.zero
            local CamCFrame = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir += CamCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir -= CamCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir -= CamCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir += CamCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then Dir -= Vector3.new(0, 1, 0) end
            BVel.Velocity = Dir.Magnitude > 0 and Dir.Unit * State.FlySpeed or Vector3.zero
            LGyro.CFrame = CamCFrame
        end)
        table.insert(GuiConnections, flyConnection) -- Fix: Fly adicionado à limpeza
    end

    UniversalTab:CreateSlider({
        Name = "🕊️ Velocidade de Voo",
        Range = {10, 300},
        Increment = 5,
        Suffix = "Studs",
        CurrentValue = 50,
        Flag = "FlySpeedSlider",
        Callback = function(Value) State.FlySpeed = Value end,
    })

    UniversalTab:CreateToggle({
        Name = "🛸 Voar",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            State.FlyEnabled = Value
            if Value then
                HandleFlight()
            end
        end,
    })

    UniversalTab:CreateToggle({
        Name = "👻 Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            State.NoclipEnabled = Value
            if Value then
                local noclipConnection
                noclipConnection = RunService.Stepped:Connect(function()
                    if not State.NoclipEnabled then
                        noclipConnection:Disconnect()
                        return
                    end
                    if LocalPlayer.Character then
                        for _, Part in ipairs(LocalPlayer.Character:GetDescendants()) do
                            if Part:IsA("BasePart") and Part.CanCollide then
                                Part.CanCollide = false
                            end
                        end
                    end
                end)
                table.insert(GuiConnections, noclipConnection) -- Fix: Noclip adicionado à limpeza
            end
        end,
    })

    -- ================ ABA CONFIGURAÇÕES ================
    ConfigTab:CreateSection("🎨 TEMAS")
    ConfigTab:CreateDropdown({
        Name = "Selecionar Tema",
        Options = temas_disponiveis,
        CurrentOption = {tema},
        MultipleOptions = false,
        Flag = "ThemeDropdown",
        Callback = function(Option)
            if Option and Option[1] then
                pcall(function()
                    writefile("RANOXHubConfigs/theme.txt", Option[1])
                end)
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "🔄 Aplicar Tema Agora",
        Callback = function()
            local flag = Rayfield.Flags["ThemeDropdown"]
            local novoTema = tema
            if flag and flag.CurrentOption and flag.CurrentOption[1] then
                novoTema = flag.CurrentOption[1]
            end
            pcall(function() writefile("RANOXHubConfigs/theme.txt", novoTema) end)
            
            if Window then pcall(function() Window:Destroy() end) end
            ConstruirInterface(novoTema)
        end
    })
    
    -- Limpa Terrain
    ConfigTab:CreateButton({
        Name = "🧹 Limpar Terreno",
        Callback = function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    if v.Name:lower():find("grass") or v.Name:lower():find("rock") or v.Name:lower():find("tree") or v.Name:lower():find("bush") then
                        v:Destroy()
                    end
                end
            end
            Rayfield:Notify({Title = "🧹 RANOX", Content = "Terreno limpo!", Duration = 2})
        end
    })
end

-- Inicializa a interface com o tema salvo
local temaInicial = carregarTemaSalvo()
ConstruirInterface(temaInicial)