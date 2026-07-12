-- [[ ☠️ HAZE SEAS: HUNTER NINJA V4 (MAX DAMAGE & NO ANIMATIONS) ☠️ ]] --

if getgenv().HunterNinjaExecutado then return end
getgenv().HunterNinjaExecutado = true
getgenv().AutoFarm = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. PAINEL DE CONTROLE (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 80); MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 2

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0.8, 0); ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleBtn.Text = "NINJA V4: OFF"
ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    ToggleBtn.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.Text = getgenv().AutoFarm and "NINJA V4: ON" or "NINJA V4: OFF"
end)

-- ==========================================
-- 2. METRALHADORA DE DANO (BYPASS DE ANIMAÇÃO)
-- ==========================================
local function MetralhadoraDeDano(alvoHRP)
    -- Mantém o clique básico (Soco M1) simulado para combos normais
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)

    -- Mapeia as pastas onde o jogo guarda os ataques
    local locaisDeAtaque = {
        LocalPlayer.Backpack,
        LocalPlayer.Character,
        LocalPlayer.PlayerGui:FindFirstChild("FruitPowers")
    }

    -- Dispara todos os remotes de ataque diretamente no servidor de uma vez só!
    for _, pasta in pairs(locaisDeAtaque) do
        if pasta then
            for _, remote in pairs(pasta:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local nome = string.lower(remote.Name)
                    -- Ignora remotes de movimentação para não teleportar/bugar o boneco
                    if not string.find(nome, "mouse") and not string.find(nome, "dash") and not string.find(nome, "geppo") then
                        pcall(function()
                            -- Dispara duas vezes seguidas para tentar bugar o delay do servidor
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
-- 3. LÓGICA DE BUSCA GRADUAL E ATAQUE
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do -- Loop mais rápido para aumentar o fluxo
        if not getgenv().AutoFarm then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local raioBusca = 50
        local alvoEncontrado = nil

        -- Busca Inteligente: Começa perto e vai expandindo
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
            
            -- Teleporta e Trava (Modo Ninja)
            hrp.Anchored = true
            
            while monstroHum.Health > 0 and getgenv().AutoFarm do
                -- Fica sempre 3 studs atrás do monstro
                hrp.CFrame = monstroHRP.CFrame * CFrame.new(0, 0, 3)
                
                -- Descarrega todo o dano possível
                MetralhadoraDeDano(monstroHRP)
                
                task.wait(0.05) -- Pausa mínima para o jogo não dar Crash
            end
            
            hrp.Anchored = false
        end
    end
end)