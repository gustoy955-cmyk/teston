-- [[ ☠️ HAZE SEAS: HUNTER NINJA V5 (AUTO-QUEST & MAX DAMAGE) ☠️ ]] --

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
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 215, 0); Stroke.Thickness = 2

-- Botão de Farm
local ToggleFarm = Instance.new("TextButton", MainFrame)
ToggleFarm.Size = UDim2.new(0.9, 0, 0, 40); ToggleFarm.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleFarm.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleFarm.Text = "NINJA V5: OFF"
ToggleFarm.TextColor3 = Color3.new(1,1,1); ToggleFarm.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleFarm).CornerRadius = UDim.new(0, 6)

-- Botão de Quest
local ToggleQuest = Instance.new("TextButton", MainFrame)
ToggleQuest.Size = UDim2.new(0.9, 0, 0, 40); ToggleQuest.Position = UDim2.new(0.05, 0, 0.5, 0)
ToggleQuest.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleQuest.Text = "AUTO QUEST: OFF"
ToggleQuest.TextColor3 = Color3.new(1,1,1); ToggleQuest.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleQuest).CornerRadius = UDim.new(0, 6)

ToggleFarm.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    ToggleFarm.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleFarm.Text = getgenv().AutoFarm and "NINJA V5: ON" or "NINJA V5: OFF"
end)

ToggleQuest.MouseButton1Click:Connect(function()
    getgenv().AutoQuest = not getgenv().AutoQuest
    ToggleQuest.BackgroundColor3 = getgenv().AutoQuest and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleQuest.Text = getgenv().AutoQuest and "AUTO QUEST: ON" or "AUTO QUEST: OFF"
    
    -- Tenta ativar o Auto-Quest nativo do jogo (Gamepass/Feature)
    if getgenv().AutoQuest then
        pcall(function()
            ReplicatedStorage.Replication.ClientEvents.ToggleAutoQuest:FireServer(true)
        end)
    end
end)

-- ==========================================
-- 2. SISTEMAS DE DANO E MISSÃO
-- ==========================================
local function PegarMissaoMaisProxima(posicaoMonstro)
    if not getgenv().AutoQuest then return end
    
    local questGiversFolder = Workspace:FindFirstChild("Npc_Workspace") and Workspace.Npc_Workspace:FindFirstChild("QuestGivers")
    if not questGiversFolder then return end

    local npcMaisPerto = nil
    local menorDistancia = math.huge

    -- Acha o NPC de missão que está na mesma ilha (mais próximo do monstro)
    for _, giver in pairs(questGiversFolder:GetChildren()) do
        if giver:FindFirstChild("HumanoidRootPart") then
            local dist = (giver.HumanoidRootPart.Position - posicaoMonstro).Magnitude
            if dist < menorDistancia then
                menorDistancia = dist
                npcMaisPerto = giver
            end
        end
    end

    -- Bombardeia os Remotes pedindo a missão daquele NPC
    if npcMaisPerto then
        pcall(function()
            -- Tenta via PlayerGui QuestEvent
            local questUI = LocalPlayer.PlayerGui:FindFirstChild("QuestGui")
            if questUI and questUI:FindFirstChild("QuestEvent") then
                questUI.QuestEvent:FireServer(npcMaisPerto.Name)
            end
            
            -- Tenta via NPC remoto genérico
            ReplicatedStorage.Replication.ClientEvents.NPCFunction:InvokeServer(npcMaisPerto)
        end)
    end
end

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
-- 3. LÓGICA PRINCIPAL (CAÇADA)
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
            
            -- Tenta pegar a missão do NPC mais próximo ANTES de matar
            PegarMissaoMaisProxima(monstroHRP.Position)
            
            hrp.Anchored = true
            
            while monstroHum.Health > 0 and getgenv().AutoFarm do
                hrp.CFrame = monstroHRP.CFrame * CFrame.new(0, 0, 3)
                MetralhadoraDeDano(monstroHRP)
                task.wait(0.05) 
            end
            
            hrp.Anchored = false
            task.wait(0.5) -- Pausa para o jogo registrar a morte e a missão completar
        end
    end
end)