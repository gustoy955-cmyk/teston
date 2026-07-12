-- [[ ☠️ HAZE SEAS: HUNTER NINJA V5.1 (AUTO-QUEST ASSÍNCRONO & METRALHADORA) ☠️ ]] --

if getgenv().HunterNinjaExecutado then return end
getgenv().HunterNinjaExecutado = true
getgenv().AutoFarm = false
getgenv().AutoQuest = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. PAINEL DE CONTROLE DUPLO (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 130); MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(0, 255, 255); Stroke.Thickness = 2

local ToggleFarm = Instance.new("TextButton", MainFrame)
ToggleFarm.Size = UDim2.new(0.9, 0, 0, 40); ToggleFarm.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleFarm.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleFarm.Text = "FARM: OFF"
ToggleFarm.TextColor3 = Color3.new(1,1,1); ToggleFarm.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleFarm).CornerRadius = UDim.new(0, 6)

local ToggleQuest = Instance.new("TextButton", MainFrame)
ToggleQuest.Size = UDim2.new(0.9, 0, 0, 40); ToggleQuest.Position = UDim2.new(0.05, 0, 0.55, 0)
ToggleQuest.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleQuest.Text = "AUTO QUEST: OFF"
ToggleQuest.TextColor3 = Color3.new(1,1,1); ToggleQuest.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleQuest).CornerRadius = UDim.new(0, 6)

ToggleFarm.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    ToggleFarm.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleFarm.Text = getgenv().AutoFarm and "FARM: ON" or "FARM: OFF"
end)

ToggleQuest.MouseButton1Click:Connect(function()
    getgenv().AutoQuest = not getgenv().AutoQuest
    ToggleQuest.BackgroundColor3 = getgenv().AutoQuest and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleQuest.Text = getgenv().AutoQuest and "AUTO QUEST: ON" or "AUTO QUEST: OFF"
end)

-- ==========================================
-- 2. TENTATIVA DE MISSÃO EM SEGUNDO PLANO
-- ==========================================
local function PegarMissaoSegundoPlano(posicaoAlvo)
    if not getgenv().AutoQuest then return end
    
    -- Cria uma thread separada para não congelar o boneco NUNCA
    task.spawn(function()
        pcall(function()
            -- 1. Tenta forçar o ToggleAutoQuest do próprio jogo
            local toggleRemote = ReplicatedStorage:FindFirstChild("ToggleAutoQuest", true)
            if toggleRemote then toggleRemote:FireServer(true) end

            -- 2. Procura o NPC de missão da ilha
            local questGiversFolder = Workspace:FindFirstChild("Npc_Workspace") and Workspace.Npc_Workspace:FindFirstChild("QuestGivers")
            if questGiversFolder then
                local npcMaisPerto = nil
                local menorDist = math.huge
                for _, giver in pairs(questGiversFolder:GetChildren()) do
                    if giver:FindFirstChild("HumanoidRootPart") then
                        local dist = (giver.HumanoidRootPart.Position - posicaoAlvo).Magnitude
                        if dist < menorDist then
                            menorDist = dist
                            npcMaisPerto = giver
                        end
                    end
                end

                -- 3. Manda o remote pedindo a missão sem esperar resposta (FireServer)
                if npcMaisPerto then
                    local questUI = LocalPlayer.PlayerGui:FindFirstChild("QuestGui")
                    if questUI and questUI:FindFirstChild("QuestEvent") then
                        questUI.QuestEvent:FireServer(npcMaisPerto.Name)
                    end
                end
            end
        end)
    end)
end

-- ==========================================
-- 3. METRALHADORA DE DANO (IGUAL V4)
-- ==========================================
local function MetralhadoraDeDano(alvoHRP)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)

    local locaisDeAtaque = {
        LocalPlayer.Backpack,
        LocalPlayer.Character,
        LocalPlayer.PlayerGui:FindFirstChild("FruitPowers")
    }

    for _, pasta in pairs(locaisDeAtaque) do
        if pasta then
            for _, remote in pairs(pasta:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local nome = string.lower(remote.Name)
                    if not string.find(nome, "mouse") and not string.find(nome, "dash") and not string.find(nome, "geppo") then
                        pcall(function()
                            remote:FireServer()
                            remote:FireServer(alvoHRP.Position)
                        end)
                    end
                end
            end
        end
    end
end

-- ==========================================
-- 4. LÓGICA DE CAÇA
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().AutoFarm then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local raioBusca = 50
        local alvoEncontrado = nil

        while not alvoEncontrado and raioBusca < 3000 do
            local npcZones = Workspace:FindFirstChild("NPC Zones")
            if npcZones then
                for _, npc in pairs(npcZones:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                        if npc.Humanoid.Health > 0 then
                            if (npc.HumanoidRootPart.Position - hrp.Position).Magnitude < raioBusca then
                                alvoEncontrado = npc
                                break
                            end
                        end
                    end
                end
            end
            if not alvoEncontrado then raioBusca = raioBusca + 150 end
        end

        if alvoEncontrado then
            local monstroHRP = alvoEncontrado.HumanoidRootPart
            local monstroHum = alvoEncontrado.Humanoid
            
            -- Dispara a busca pela missão em segundo plano (Não trava o jogo)
            PegarMissaoSegundoPlano(monstroHRP.Position)
            
            hrp.Anchored = true
            
            while monstroHum.Health > 0 and getgenv().AutoFarm do
                hrp.CFrame = monstroHRP.CFrame * CFrame.new(0, 0, 3)
                MetralhadoraDeDano(monstroHRP)
                task.wait(0.05)
            end
            
            hrp.Anchored = false
        end
    end
end)