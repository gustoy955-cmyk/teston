--[[
    XUCRIA HUB - Script para MESCLAR UMA BOMBA NUCLEAR
    Desenvolvido para Xucria
    Interface com tema salvável e aplicação imediata via botão
]]

-- Lista de temas disponíveis
local temas_disponiveis = {
    "Default",
    "Amethyst",
    "Ocean",
    "Serenity",
    "Mocha",
    "Sunset",
    "Midnight",
    "Dark",
    "Light"
}

-- Função para carregar o tema salvo manualmente
local function carregarTemaSalvo()
    local caminho = "XucriaHubConfigs/theme.txt"
    local sucesso, tema = pcall(function()
        return readfile(caminho)
    end)
    if sucesso and tema then
        tema = tema:gsub("%s+", "") -- remove espaços em branco
        for _, t in ipairs(temas_disponiveis) do
            if t:lower() == tema:lower() then
                return t
            end
        end
    end
    -- Se não encontrou ou inválido, tenta carregar do JSON da Rayfield (caso exista)
    local jsonPath = "XucriaHubConfigs/XucriaHub.json"
    local ok, data = pcall(function()
        return readfile(jsonPath)
    end)
    if ok and data then
        local ok2, config = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if ok2 and config and config.Flags and config.Flags.ThemeDropdown then
            local temaSalvo = config.Flags.ThemeDropdown
            if type(temaSalvo) == "table" then temaSalvo = temaSalvo[1] end
            for _, t in ipairs(temas_disponiveis) do
                if t == temaSalvo then
                    return t
                end
            end
        end
    end
    return "Default"
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)

-- Variáveis globais da interface
local Window, Rayfield
local Main, UniversalTab, ConfigTab, CreditsTab
local GuiConnections = {}  -- Para armazenar conexões a serem desfeitas

-- Função principal para construir toda a interface com um tema específico
local function ConstruirInterface(tema)
    -- Limpa conexões anteriores se existirem
    for _, conn in ipairs(GuiConnections) do
        pcall(function() conn:Disconnect() end)
    end
    GuiConnections = {}

    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "🔥 XUCRIA HUB",
        LoadingTitle = "XUCRIA Hub",
        LoadingSubtitle = "by Xucria 💣",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "XucriaHubConfigs",
            FileName = "XucriaHub"
        },
        KeySystem = false,
        Theme = tema,
        ToggleUIKeybind = Enum.KeyCode.RightAlt
    })

    -- Notificação informando o tema atual
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
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
            if _G.GuerraCooldown then
                Rayfield:Notify({
                    Title = "⏳ Aguarde",
                    Content = "Aguarde 5 segundos para usar novamente.",
                    Duration = 3,
                    Image = 4483362458,
                })
                return
            end
            _G.GuerraCooldown = true
            local sucesso, erro = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/SAMUCARARONOB/Inf/refs/heads/main/RANOXv2.lua"))()
            end)
            if not sucesso then
                Rayfield:Notify({
                    Title = "❌ Erro",
                    Content = "Falha ao carregar script de guerra.",
                    Duration = 3,
                    Image = 4483362458,
                })
                warn("Erro no script de guerra:", erro)
            else
                Rayfield:Notify({
                    Title = "✅ Sucesso",
                    Content = "Interface de guerra carregada!",
                    Duration = 3,
                    Image = 4483362458,
                })
            end
            task.delay(5, function()
                _G.GuerraCooldown = false
            end)
        end
    })

    Main:CreateSection("🎯 ATAQUE A COORDENADA")
    Main:CreateButton({
        Name = "📍 Marcar Posição",
        Callback = function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                _G.MarkedCoord = root.Position
                Rayfield:Notify({
                    Title = "📍 Posição Marcada",
                    Content = string.format("%.1f, %.1f, %.1f", _G.MarkedCoord.X, _G.MarkedCoord.Y, _G.MarkedCoord.Z),
                    Duration = 2,
                    Image = 4483362458,
                })
            else
                Rayfield:Notify({
                    Title = "❌ Erro",
                    Content = "Personagem não encontrado.",
                    Duration = 2,
                    Image = 4483362458,
                })
            end
        end
    })

    Main:CreateToggle({
        Name = "🚀 Lançar Nuke na Coordenada",
        CurrentValue = false,
        Flag = "ToggleLaunchAtCoord",
        Callback = function(Value)
            _G.LaunchAtCoord = Value
            if not Value then return end
            task.spawn(function()
                while _G.LaunchAtCoord do
                    if not _G.MarkedCoord then
                        Rayfield:Notify({
                            Title = "🎯 Ataque Coordenada",
                            Content = "Defina uma coordenada primeiro!",
                            Duration = 3,
                            Image = 4483362458,
                        })
                        task.wait(2)
                    else
                        local myBase = GetPlayerBase()
                        if myBase and myBase:FindFirstChild("Nukes") then
                            local nukes = {}
                            for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                                if nuke.Name == "Nuke" and nuke.Parent then
                                    table.insert(nukes, nuke)
                                end
                            end
                            if #nukes > 0 then
                                local char = LocalPlayer.Character
                                local root = char and char:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local chosenNuke = nukes[math.random(1, #nukes)]
                                    local oldPos = root.CFrame
                                    TeleportTo(chosenNuke)
                                    task.wait(0.05)
                                    ReplicatedStorage.NukeRemotes.PickUp:FireServer(chosenNuke)
                                    task.wait(0.05)
                                    ReplicatedStorage.NukeRemotes.LaunchConfirm:FireServer(_G.MarkedCoord)
                                    if oldPos then root.CFrame = oldPos end
                                end
                            else
                                Rayfield:Notify({
                                    Title = "❌ Sem Nukes",
                                    Content = "Sua base não tem nukes!",
                                    Duration = 2,
                                    Image = 4483362458,
                                })
                                task.wait(2)
                            end
                        end
                        task.wait(0.5)
                    end
                end
            end)
        end
    })

    Main:CreateSection("⚡ FUSÃO & COLETA")
    Main:CreateToggle({
        Name = "🔗 Auto Fusão",
        CurrentValue = false,
        Flag = "Toggle1",
        Callback = function(Value)
            _G.AutoMerge = Value
            while _G.AutoMerge do
                local myBase = GetPlayerBase()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)
                end
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

    Main:CreateToggle({
        Name = "⚡ Auto Fusão Ultra (Teleporte)",
        CurrentValue = false,
        Flag = "ToggleUltraMerge",
        Callback = function(Value)
            _G.AutoMergeUltra = Value
            while _G.AutoMergeUltra do
                local myBase = GetPlayerBase()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not myBase or not root then task.wait(0.1) continue end
                ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)
                if myBase:FindFirstChild("Nukes") then
                    local typeMap = {}
                    for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                        if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                            local nukeType = nuke.OverheadNuke.TextLabel.Text
                            if nukeType and nukeType ~= "" then
                                typeMap[nukeType] = typeMap[nukeType] or {}
                                table.insert(typeMap[nukeType], nuke)
                            end
                        end
                    end
                    local originalCFrame = root.CFrame
                    for _, nukeList in pairs(typeMap) do
                        if not _G.AutoMergeUltra then break end
                        if #nukeList >= 2 then
                            TeleportTo(nukeList[1])
                            task.wait(0.02)
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(nukeList[1])
                            task.wait(0.02)
                            ReplicatedStorage.NukeRemotes.MergeRequest:FireServer(nukeList[2])
                            task.wait(0.02)
                        end
                    end
                    if originalCFrame then root.CFrame = originalCFrame; task.wait(0.05) end
                end
                task.wait(0.1)
            end
        end
    })

    Main:CreateToggle({
        Name = "🎒 Auto Pegar Tudo (Teleporte)",
        CurrentValue = false,
        Flag = "Toggle2",
        Callback = function(Value)
            _G.AutoPickUp = Value
            while _G.AutoPickUp do
                local myBase = GetPlayerBase()
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
                    for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                        if not _G.AutoPickUp then break end
                        if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                            local nukeType = nuke.OverheadNuke.TextLabel.Text
                            local matchCount = nukeCounts[nukeType] and #nukeCounts[nukeType] or 0
                            local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local originalCFrame = rootPart and rootPart.CFrame
                            TeleportTo(nuke)
                            task.wait()
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                            task.wait()
                            if matchCount < 2 then
                                if rootPart then
                                    ReplicatedStorage.NukeRemotes.Drop:FireServer(rootPart.CFrame)
                                else
                                    ReplicatedStorage.NukeRemotes.Drop:FireServer(CFrame.new(290.03, 17.20, 249.74))
                                end
                                task.wait()
                            end
                            if rootPart and originalCFrame then rootPart.CFrame = originalCFrame end
                        end
                    end
                end
                task.wait()
            end
        end
    })

    local walkPickUpSpeed = 50
    Main:CreateSection("🚶 AUTO ANDAR E PEGAR")
    Main:CreateToggle({
        Name = "🏃 Auto Andar e Pegar",
        CurrentValue = false,
        Flag = "Toggle5",
        Callback = function(Value)
            _G.AutoWalkPickUp = Value
            if not Value then return end
            task.spawn(function()
                local lastPos, idleTime = nil, 0
                local dropCFrame = CFrame.new(293.773, 18.536, 268.088, 0.763, -2.840e-08, 0.646, 3.596e-08, 1, 1.479e-09, -0.646, 2.211e-08, 0.763)
                while _G.AutoWalkPickUp do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local currentPos = root.Position
                        if lastPos and (currentPos - lastPos).Magnitude <= 1 then
                            idleTime += task.wait()
                        else
                            idleTime = 0
                        end
                        lastPos = currentPos
                        if idleTime >= 3 then
                            ReplicatedStorage.NukeRemotes.Drop:FireServer(dropCFrame)
                            idleTime = 0
                        end
                    end
                    task.wait(0.5)
                end
            end)
            while _G.AutoWalkPickUp do
                local myBase = GetPlayerBase()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not myBase or not hum or not root then task.wait(0.5) continue end
                local nukeCounts, nukeList = {}, {}
                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                        local nukeType = nuke.OverheadNuke.TextLabel.Text
                        if nukeType and nukeType ~= "" then
                            nukeCounts[nukeType] = nukeCounts[nukeType] or {}
                            table.insert(nukeCounts[nukeType], nuke)
                            table.insert(nukeList, nuke)
                        end
                    end
                end
                for _, nuke in ipairs(nukeList) do
                    if not _G.AutoWalkPickUp or not nuke.Parent then break end
                    local nukeType = nuke.OverheadNuke.TextLabel.Text
                    local matchCount = nukeCounts[nukeType] and #nukeCounts[nukeType] or 0
                    local targetPos = nuke:GetPivot().Position
                    hum.WalkSpeed = walkPickUpSpeed
                    while _G.AutoWalkPickUp and nuke.Parent and root.Parent do
                        hum:MoveTo(targetPos)
                        if (root.Position - targetPos).Magnitude < 5 then
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                            task.wait(0.1)
                            if matchCount < 2 then
                                ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)
                                task.wait(0.1)
                            end
                            break
                        end
                        task.wait()
                    end
                    if not _G.AutoWalkPickUp then break end
                end
                task.wait(0.5)
            end
        end
    })

    Main:CreateSlider({
        Name = "Velocidade de Caminhada",
        Range = {16, 160},
        Increment = 1,
        Suffix = "studs/s",
        CurrentValue = 50,
        Flag = "WalkPickUpSpeedSlider",
        Callback = function(Value)
            walkPickUpSpeed = Value
        end
    })

    Main:CreateSection("⚡ PEGAR INSTANTÂNEO")
    Main:CreateToggle({
        Name = "⚡ Pegar Instantâneo",
        CurrentValue = false,
        Flag = "InstantPickUp",
        Callback = function(Value)
            _G.InstantPickUp = Value
            task.spawn(function()
                while _G.InstantPickUp do
                    local myBase = GetPlayerBase()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        ReplicatedStorage.NukeRemotes.Drop:FireServer(root.CFrame)
                    end
                    if myBase and myBase:FindFirstChild("Nukes") then
                        local lista = {}
                        for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                            if nuke.Name == "Nuke" and nuke.Parent then
                                table.insert(lista, nuke)
                            end
                        end
                        for i = #lista, 2, -1 do
                            local j = math.random(i)
                            lista[i], lista[j] = lista[j], lista[i]
                        end
                        for _, nuke in ipairs(lista) do
                            if not _G.InstantPickUp then break end
                            if nuke and nuke.Parent then
                                ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                                task.wait(0.01)
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    })

    Main:CreateSection("🔒 BASE & UPGRADES")
    Main:CreateToggle({
        Name = "🔒 Auto Travar Base",
        CurrentValue = false,
        Flag = "Toggle3",
        Callback = function(Value)
            _G.AutoLockBase = Value
            while _G.AutoLockBase do
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
            _G.SelectedUpgrades = Options
        end,
    })

    Main:CreateToggle({
        Name = "🔄 Auto Upgrade",
        CurrentValue = false,
        Flag = "Toggle4",
        Callback = function(Value)
            _G.AutoUpgrade = Value
            while _G.AutoUpgrade do
                for _, upgradeType in ipairs(_G.SelectedUpgrades or {}) do
                    if not _G.AutoUpgrade then break end
                    ReplicatedStorage.NukeRemotes.PurchaseUpgrade:FireServer(upgradeType)
                end
                task.wait()
            end
        end,
    })

    -- ================ ABA UNIVERSAL ================
    UniversalTab:CreateSection("🏃 MODIFICAÇÕES DE MOVIMENTO")
    UniversalTab:CreateSlider({
        Name = "⚡ Velocidade",
        Range = {16, 250},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            shared.TargetWalkSpeed = Value
            if shared.WalkSpeedEnabled then
                local Char = LocalPlayer.Character
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if Hum then Hum.WalkSpeed = Value end
            end
        end,
    })

    UniversalTab:CreateToggle({
        Name = "Ativar Velocidade",
        CurrentValue = false,
        Flag = "WalkSpeedToggle",
        Callback = function(Value)
            shared.WalkSpeedEnabled = Value
            if not Value then
                local Char = LocalPlayer.Character
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if Hum then Hum.WalkSpeed = 16 end
            end
        end,
    })

    UniversalTab:CreateSlider({
        Name = "🦘 Pulo",
        Range = {50, 500},
        Increment = 1,
        Suffix = "Power",
        CurrentValue = 50,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            shared.TargetJumpPower = Value
            if shared.JumpPowerEnabled then
                local Char = LocalPlayer.Character
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if Hum then
                    Hum.UseJumpPower = true
                    Hum.JumpPower = Value
                end
            end
        end,
    })

    UniversalTab:CreateToggle({
        Name = "Ativar Pulo",
        CurrentValue = false,
        Flag = "JumpPowerToggle",
        Callback = function(Value)
            shared.JumpPowerEnabled = Value
            if not Value then
                local Char = LocalPlayer.Character
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if Hum then Hum.JumpPower = 50 end
            end
        end,
    })

    local movementConnection = RunService.RenderStepped:Connect(function()
        local Char = LocalPlayer.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        if not Hum then return end
        if shared.WalkSpeedEnabled and Hum.WalkSpeed ~= shared.TargetWalkSpeed then
            Hum.WalkSpeed = shared.TargetWalkSpeed
        end
        if shared.JumpPowerEnabled then
            if not Hum.UseJumpPower then Hum.UseJumpPower = true end
            if Hum.JumpPower ~= shared.TargetJumpPower then Hum.JumpPower = shared.TargetJumpPower end
        end
    end)
    table.insert(GuiConnections, movementConnection)

    UniversalTab:CreateToggle({
        Name = "♾️ Pulo Infinito",
        CurrentValue = false,
        Flag = "InfJumpToggle",
        Callback = function(Value)
            shared.InfJumpEnabled = Value
        end,
    })

    local jumpConnection = UserInputService.JumpRequest:Connect(function()
        if shared.InfJumpEnabled then
            local Char = LocalPlayer.Character
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
            if Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    table.insert(GuiConnections, jumpConnection)

    UniversalTab:CreateSection("✈️ MOVIMENTO AVANÇADO")
    UniversalTab:CreateSlider({
        Name = "🕊️ Velocidade de Voo",
        Range = {10, 300},
        Increment = 5,
        Suffix = "Studs",
        CurrentValue = 50,
        Flag = "FlySpeedSlider",
        Callback = function(Value)
            shared.FlySpeed = Value
        end,
    })

    shared.HandleFlight = function()
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
        shared.FlyConnection = RunService.RenderStepped:Connect(function()
            if not shared.FlyEnabled or not Character or not Root.Parent then
                BVel:Destroy()
                LGyro:Destroy()
                if Hum then Hum.PlatformStand = false end
                if shared.FlyConnection then shared.FlyConnection:Disconnect() end
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
            BVel.Velocity = Dir.Magnitude > 0 and Dir.Unit * shared.FlySpeed or Vector3.zero
            LGyro.CFrame = CamCFrame
        end)
    end

    UniversalTab:CreateToggle({
        Name = "🛸 Voar",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            shared.FlyEnabled = Value
            if shared.FlyEnabled then
                shared.HandleFlight()
            else
                if shared.FlyConnection then shared.FlyConnection:Disconnect() end
                local Char = LocalPlayer.Character
                local Root = Char and Char:FindFirstChild("HumanoidRootPart")
                local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
                if Root then
                    if Root:FindFirstChild("RANOXFlyForce") then Root.RANOXFlyForce:Destroy() end
                    if Root:FindFirstChild("RANOXFlyGyro") then Root.RANOXFlyGyro:Destroy() end
                end
                if Hum then Hum.PlatformStand = false end
            end
        end,
    })

    UniversalTab:CreateToggle({
        Name = "👻 Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            shared.NoclipEnabled = Value
            if shared.NoclipEnabled then
                shared.NoclipConnection = RunService.Stepped:Connect(function()
                    if not shared.NoclipEnabled then
                        if shared.NoclipConnection then shared.NoclipConnection:Disconnect() end
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
            else
                if shared.NoclipConnection then shared.NoclipConnection:Disconnect() end
            end
        end,
    })

    UniversalTab:CreateSection("👁️ VISUAIS")
    local function CleanUpPlayerESP(Player)
        if shared.EspConnections[Player] then
            for _, Connection in ipairs(shared.EspConnections[Player]) do
                Connection:Disconnect()
            end
            shared.EspConnections[Player] = nil
        end
        if shared.EspFolder then
            local Container = shared.EspFolder:FindFirstChild(Player.Name)
            if Container then Container:Destroy() end
        end
    end

    local function ConstructFullESP(Player)
        if Player == LocalPlayer then return end
        CleanUpPlayerESP(Player)
        shared.EspConnections[Player] = {}
        if not shared.EspFolder then return end
        local Container = Instance.new("Folder")
        Container.Name = Player.Name
        Container.Parent = shared.EspFolder
        local function CreateNameTag(Char)
            if not Char then return end
            local Root = Char:WaitForChild("HumanoidRootPart", 5)
            if not Root then return end
            local BbGui = Instance.new("BillboardGui")
            BbGui.Name = "EspNameTag"
            BbGui.AlwaysOnTop = true
            BbGui.Size = UDim2.new(0, 200, 0, 50)
            BbGui.StudsOffset = Vector3.new(0, 3, 0)
            BbGui.Adornee = Root
            BbGui.Parent = Container
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Text = Player.Name
            TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            TextLabel.TextSize = 14
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.Parent = BbGui
        end
        if Player.Character then CreateNameTag(Player.Character) end
        local CharAdded = Player.CharacterAdded:Connect(function(Char)
            task.wait(0.5)
            CreateNameTag(Char)
        end)
        table.insert(shared.EspConnections[Player], CharAdded)
    end

    UniversalTab:CreateToggle({
        Name = "🕵️ ESP dos Jogadores",
        CurrentValue = false,
        Flag = "EspToggle",
        Callback = function(Value)
            shared.EspEnabled = Value
            if shared.EspEnabled then
                for _, Player in ipairs(Players:GetPlayers()) do
                    ConstructFullESP(Player)
                end
                shared.PlayerAddedConn = Players.PlayerAdded:Connect(ConstructFullESP)
                shared.PlayerRemovingConn = Players.PlayerRemoving:Connect(CleanUpPlayerESP)
            else
                if shared.PlayerAddedConn then shared.PlayerAddedConn:Disconnect() end
                if shared.PlayerRemovingConn then shared.PlayerRemovingConn:Disconnect() end
                for _, Player in ipairs(Players:GetPlayers()) do
                    CleanUpPlayerESP(Player)
                end
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
                -- Salva imediatamente em arquivo
                local caminho = "XucriaHubConfigs/theme.txt"
                pcall(function()
                    writefile(caminho, Option[1])
                end)
                Rayfield:Notify({
                    Title = "💾 Tema Salvo",
                    Content = "Tema '" .. Option[1] .. "' salvo. Use o botão 'Aplicar Tema Agora'.",
                    Duration = 4,
                    Image = 4483362458,
                })
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
            -- Salva novamente por garantia
            pcall(function()
                writefile("XucriaHubConfigs/theme.txt", novoTema)
            end)
            -- Destroi a janela atual
            if Window then
                pcall(function() Window:Destroy() end)
            end
            -- Limpa conexões extras
            for _, conn in ipairs(GuiConnections) do
                pcall(function() conn:Disconnect() end)
            end
            -- Recria a interface com o novo tema
            ConstruirInterface(novoTema)
        end
    })

    ConfigTab:CreateSection("🛠️ UTILITÁRIOS GERAIS")
    ConfigTab:CreateToggle({
        Name = "🛡️ Anti-AFK",
        CurrentValue = false,
        Flag = "AntiAFK",
        Callback = function(Value)
            if Value then
                local VirtualUser = game:GetService("VirtualUser")
                local idleConn = LocalPlayer.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
                end)
                table.insert(GuiConnections, idleConn)
            end
        end
    })

    ConfigTab:CreateToggle({
        Name = "🌿 Modo Leve (FPS Boost)",
        CurrentValue = false,
        Flag = "LowGraphics",
        Callback = function(Value)
            if Value then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("Bloom") or v:IsA("SunRays") or v:IsA("ColorCorrection") then
                        v.Enabled = false
                    end
                end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
                workspace.Terrain.TextureGrid = Enum.TerrainTextureGrid.NoTexture
            else
                Lighting.GlobalShadows = true
                Lighting.FogEnd = 500
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("Bloom") or v:IsA("SunRays") or v:IsA("ColorCorrection") then
                        v.Enabled = true
                    end
                end
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = true
                    end
                end
                workspace.Terrain.TextureGrid = Enum.TerrainTextureGrid.Default
            end
        end
    })

    ConfigTab:CreateToggle({
        Name = "📊 Mostrar FPS",
        CurrentValue = false,
        Flag = "FPSDisplay",
        Callback = function(Value)
            if Value then
                local fpsGui = Instance.new("ScreenGui")
                fpsGui.Name = "XUCRIA_FPS"
                fpsGui.Parent = LocalPlayer.PlayerGui
                local fpsLabel = Instance.new("TextLabel")
                fpsLabel.AnchorPoint = Vector2.new(1, 0)
                fpsLabel.Position = UDim2.new(1, -10, 0, 10)
                fpsLabel.Size = UDim2.new(0, 100, 0, 20)
                fpsLabel.BackgroundTransparency = 1
                fpsLabel.TextColor3 = Color3.new(1, 1, 1)
                fpsLabel.TextStrokeTransparency = 0
                fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                fpsLabel.Text = "FPS: ..."
                fpsLabel.Parent = fpsGui
                local lastUpdate, frameCount = 0, 0
                local fpsConnection = RunService.RenderStepped:Connect(function()
                    frameCount += 1
                    if tick() - lastUpdate >= 0.5 then
                        fpsLabel.Text = "FPS: " .. math.round(frameCount / (tick() - lastUpdate))
                        lastUpdate = tick()
                        frameCount = 0
                    end
                end)
                table.insert(GuiConnections, fpsConnection)
            else
                local gui = LocalPlayer.PlayerGui:FindFirstChild("XUCRIA_FPS")
                if gui then gui:Destroy() end
            end
        end
    })

    ConfigTab:CreateToggle({
        Name = "📶 Mostrar Ping",
        CurrentValue = false,
        Flag = "PingDisplay",
        Callback = function(Value)
            if Value then
                local pingGui = Instance.new("ScreenGui")
                pingGui.Name = "XUCRIA_PING"
                pingGui.Parent = LocalPlayer.PlayerGui
                local pingLabel = Instance.new("TextLabel")
                pingLabel.AnchorPoint = Vector2.new(1, 0)
                pingLabel.Position = UDim2.new(1, -10, 0, 35)
                pingLabel.Size = UDim2.new(0, 100, 0, 20)
                pingLabel.BackgroundTransparency = 1
                pingLabel.TextColor3 = Color3.new(1, 1, 1)
                pingLabel.TextStrokeTransparency = 0
                pingLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                pingLabel.Text = "Ping: ..."
                pingLabel.Parent = pingGui
                task.spawn(function()
                    while LocalPlayer.PlayerGui:FindFirstChild("XUCRIA_PING") do
                        local ping = Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("Ping")
                        if ping then
                            pingLabel.Text = "Ping: " .. ping:GetValue() .. " ms"
                        end
                        task.wait(1)
                    end
                end)
            else
                local gui = LocalPlayer.PlayerGui:FindFirstChild("XUCRIA_PING")
                if gui then gui:Destroy() end
            end
        end
    })

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
            Rayfield:Notify({
                Title = "🧹 XUCRIA",
                Content = "Terreno limpo!",
                Duration = 2,
                Image = 4483362458,
            })
        end
    })

    -- ================ CRÉDITOS ================
    CreditsTab:CreateSection("🌟 COMUNIDADE")
    CreditsTab:CreateLabel("Desenvolvido por Xucria")
    CreditsTab:CreateLabel("YouTube: @Xucria")
    CreditsTab:CreateButton({
        Name = "📋 Copiar YouTube",
        Callback = function()
            setclipboard("https://youtube.com/@Xucria")
            Rayfield:Notify({
                Title = "✅ Sucesso",
                Content = "Link copiado!",
                Duration = 3,
                Image = 4483362458,
            })
        end
    })

    -- ================ MANTER AJUSTES APÓS RESPAWN ================
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.5)
        if Rayfield.Flags["WalkSpeedSlider"] then
            Humanoid.WalkSpeed = Rayfield.Flags["WalkSpeedSlider"].CurrentValue
        end
        if Rayfield.Flags["JumpPowerSlider"] then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Rayfield.Flags["JumpPowerSlider"].CurrentValue
        end
        if shared.FlyEnabled then
            shared.HandleFlight()
        end
    end)
    table.insert(GuiConnections, charAddedConn)
end

-- Inicializa a interface com o tema salvo
local temaInicial = carregarTemaSalvo()
ConstruirInterface(temaInicial)