-- [[ ☠️ HAZE SEAS AUTO-FARM AVANÇADO (DISTÂNCIA DINÂMICA) ☠️ ]] --

if getgenv().HazeFarmExecutado then return end
getgenv().HazeFarmExecutado = true
getgenv().AutoFarm = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager") -- Simulador de Teclado
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. FAXINA: LIMPAR SCRIPTS ANTIGOS
-- ==========================================
local function LimparTela()
    local nomesParaLimpar = {"NPCAnalyzer", "DeepAnalyzer", "FarmGUI", "HazeFarmGUI"}
    for _, gui in pairs(CoreGui:GetChildren()) do
        if table.find(nomesParaLimpar, gui.Name) then
            gui:Destroy()
        end
    end
end
LimparTela() -- Limpa assim que executa

-- ==========================================
-- 2. PAINEL DE CONTROLE (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "HazeFarmGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(150, 0, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "☠️ HAZE FARM ☠️"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(150, 0, 255)
Title.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Text = "FARM: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local ClearBtn = Instance.new("TextButton", MainFrame)
ClearBtn.Size = UDim2.new(0.9, 0, 0, 35)
ClearBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ClearBtn.Text = "LIMPAR TELA"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
CloseBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
CloseBtn.Text = "FECHAR SCRIPT"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. PLATAFORMA ANTI-QUEDA (FIM DO PULA-PULA)
-- ==========================================
local Plataforma = Instance.new("Part")
Plataforma.Size = Vector3.new(10, 1, 10)
Plataforma.Transparency = 1 -- Fica invisível
Plataforma.Anchored = true
Plataforma.CanCollide = true
Plataforma.Parent = Workspace

-- Mantém a plataforma sempre embaixo do jogador
RunService.Heartbeat:Connect(function()
    if getgenv().AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Plataforma.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
    else
        Plataforma.CFrame = CFrame.new(0, -5000, 0) -- Esconde se o farm estiver OFF
    end
end)

-- ==========================================
-- 4. SISTEMA DE ATAQUE E TECLAS
-- ==========================================
local function Atacar(alvoHRP)
    -- Vira o boneco de frente para o monstro (necessário para as skills acertarem)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(
            LocalPlayer.Character.HumanoidRootPart.Position,
            Vector3.new(alvoHRP.Position.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, alvoHRP.Position.Z)
        )
    end

    -- Simula o clique do Mouse (Soco M1)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- Simula as skills (Z, X, C, V, B)
    local teclas = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B}
    for _, tecla in ipairs(teclas) do
        VIM:SendKeyEvent(true, tecla, false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, tecla, false, game)
    end
end

-- ==========================================
-- 5. LÓGICA PRINCIPAL DO AUTO-FARM
-- ==========================================
task.spawn(function()
    while task.wait() do
        if not getgenv().AutoFarm then continue end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        local npcZones = Workspace:FindFirstChild("NPC Zones")
        if not npcZones then continue end

        for _, npc in pairs(npcZones:GetDescendants()) do
            if not getgenv().AutoFarm then break end

            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")

            if npc:IsA("Model") and humanoid and rootPart and humanoid.Health > 0 then
                
                -- DISTÂNCIA DINÂMICA
                local alturaIdeal = 35 -- Começa de bem alto
                local ultimaVida = humanoid.Health
                local tempoSemDano = tick()
                
                while humanoid.Health > 0 and getgenv().AutoFarm do
                    task.wait(0.1)
                    
                    char = LocalPlayer.Character
                    if not char or char.Humanoid.Health <= 0 then break end
                    hrp = char.HumanoidRootPart

                    -- Calcula se o monstro tomou dano
                    if humanoid.Health < ultimaVida then
                        -- Tomou dano! Trava nessa altura e reseta o relógio
                        ultimaVida = humanoid.Health
                        tempoSemDano = tick()
                    else
                        -- Se passou 1.5 segundos atacando e não deu dano, desce 5 studs
                        if tick() - tempoSemDano > 1.5 then
                            alturaIdeal = math.max(5, alturaIdeal - 5) -- Mínimo de 5 studs (costas do NPC)
                            tempoSemDano = tick()
                        end
                    end

                    local alvoCFrame = rootPart.CFrame * CFrame.new(0, alturaIdeal, 0)
                    local distancia = (hrp.Position - alvoCFrame.Position).Magnitude

                    -- Se o monstro fugir ou estiver longe, voa até ele
                    if distancia > 15 then
                        local tweenInfo = TweenInfo.new(distancia / 150, Enum.EasingStyle.Linear)
                        TweenService:Create(hrp, tweenInfo, {CFrame = alvoCFrame}):Play()
                        task.wait(distancia / 150) -- Espera chegar
                    else
                        -- Se já chegou, teleporta suave e ataca
                        hrp.CFrame = alvoCFrame
                        Atacar(rootPart)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 6. BOTÕES DA INTERFACE
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    if getgenv().AutoFarm then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        ToggleBtn.Text = "FARM: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = "FARM: OFF"
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    LimparTela()
    ScreenGui.Parent = CoreGui -- Mantém só esse painel
end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    getgenv().HazeFarmExecutado = false
    Plataforma:Destroy()
    ScreenGui:Destroy()
end)