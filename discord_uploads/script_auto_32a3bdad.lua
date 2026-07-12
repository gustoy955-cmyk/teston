-- [[ AUTO-FARM HOVER (HAZE SEAS) ]] --

-- Variável global para não abrir o script duas vezes
if getgenv().AutoFarmExecutado then return end
getgenv().AutoFarmExecutado = true
getgenv().AutoFarm = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. GUI (BOTÃO DE LIGAR/DESLIGAR)
-- ==========================================
local guiName = "FarmGUI"
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = guiName

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 150, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -75, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local UICorner = Instance.new("UICorner", ToggleBtn)
UICorner.CornerRadius = UDim.new(0, 8)

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    if getgenv().AutoFarm then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        ToggleBtn.Text = "AUTO FARM: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = "AUTO FARM: OFF"
    end
end)

-- ==========================================
-- 2. FUNÇÃO DE BUSCAR E ATIRAR O ATAQUE
-- ==========================================
local cachedRemote = nil
local function FireAttack()
    -- Se já achamos o remote antes, usa ele para não dar lag
    if cachedRemote and cachedRemote.Parent then
        cachedRemote:FireServer()
        return
    end
    
    -- Se não achou, procura no ReplicatedStorage (Padrão de jogos)
    local rsRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Smoke Punch", true)
    if rsRemote and rsRemote:IsA("RemoteEvent") then
        cachedRemote = rsRemote
        rsRemote:FireServer()
        return
    end
    
    -- Se não estiver lá, procura no próprio personagem (Skills)
    if LocalPlayer.Character then
        local charRemote = LocalPlayer.Character:FindFirstChild("Smoke Punch", true)
        if charRemote and charRemote:IsA("RemoteEvent") then
            cachedRemote = charRemote
            charRemote:FireServer()
        end
    end
end

-- ==========================================
-- 3. LOOP PRINCIPAL DO AUTO-FARM
-- ==========================================
task.spawn(function()
    while task.wait() do
        if not getgenv().AutoFarm then continue end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        local npcZones = Workspace:FindFirstChild("NPC Zones")
        if not npcZones then continue end

        -- Procura o primeiro NPC vivo
        for _, npc in pairs(npcZones:GetDescendants()) do
            if not getgenv().AutoFarm then break end -- Se desligar, para a busca

            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")

            -- Verifica se é um monstro válido e se está vivo
            if npc:IsA("Model") and humanoid and rootPart and humanoid.Health > 0 then
                
                -- Loop de combate: Continua enquanto o monstro estiver vivo
                while humanoid.Health > 0 and getgenv().AutoFarm do
                    task.wait() -- Pausa vital para não crashar o jogo
                    
                    -- Atualiza o personagem caso o jogador morra durante o farm
                    char = LocalPlayer.Character
                    if not char or char.Humanoid.Health <= 0 or not char:FindFirstChild("HumanoidRootPart") then break end
                    hrp = char.HumanoidRootPart

                    -- Posição Alvo: 15 studs exatos ACIMA da cabeça do monstro
                    local alvoCFrame = rootPart.CFrame * CFrame.new(0, 15, 0)
                    local distancia = (hrp.Position - alvoCFrame.Position).Magnitude

                    -- Se estiver muito longe (> 20 studs), vai voando (Tween)
                    if distancia > 20 then
                        -- Velocidade do voo (150 studs por segundo, seguro contra ban)
                        local tempoVoo = distancia / 150 
                        local tweenInfo = TweenInfo.new(tempoVoo, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = alvoCFrame})
                        tween:Play()
                        
                        -- Espera o voo terminar para começar a bater
                        tween.Completed:Wait()
                    else
                        -- Se já estiver perto/em cima, gruda na posição e ataca
                        hrp.CFrame = alvoCFrame
                        FireAttack()
                        task.wait(0.1) -- Tempo de recarga entre os socos
                    end
                end
            end
        end
    end
end)