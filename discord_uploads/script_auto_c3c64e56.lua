-- [[ ☠️ HUB DE ANOMALIAS: HAZE SEAS ☠️ ]] --

if getgenv().AnomaliaHub then return end
getgenv().AnomaliaHub = true

getgenv().MagnetAtivo = false
getgenv().HitboxAtivo = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. LIMPEZA DE TELA
-- ==========================================
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "AnomaliaGUI" or gui.Name == "HazeFarmGUI" then gui:Destroy() end
end

-- ==========================================
-- 2. CRIAÇÃO DO PAINEL (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AnomaliaGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(0, 255, 150); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔬 ANOMALIA HUB"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.BackgroundTransparency = 1

-- Botão Magnet
local BtnMagnet = Instance.new("TextButton", MainFrame)
BtnMagnet.Size = UDim2.new(0.9, 0, 0, 35)
BtnMagnet.Position = UDim2.new(0.05, 0, 0.25, 0)
BtnMagnet.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BtnMagnet.Text = "PUXAR MOBS: OFF"
BtnMagnet.TextColor3 = Color3.new(1, 1, 1)
BtnMagnet.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnMagnet).CornerRadius = UDim.new(0, 6)

-- Botão Hitbox
local BtnHitbox = Instance.new("TextButton", MainFrame)
BtnHitbox.Size = UDim2.new(0.9, 0, 0, 35)
BtnHitbox.Position = UDim2.new(0.05, 0, 0.50, 0)
BtnHitbox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BtnHitbox.Text = "HITBOX GIGANTE: OFF"
BtnHitbox.TextColor3 = Color3.new(1, 1, 1)
BtnHitbox.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnHitbox).CornerRadius = UDim.new(0, 6)

-- Botão Fechar
local BtnClose = Instance.new("TextButton", MainFrame)
BtnClose.Size = UDim2.new(0.9, 0, 0, 30)
BtnClose.Position = UDim2.new(0.05, 0, 0.75, 0)
BtnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnClose.Text = "FECHAR TUDO"
BtnClose.TextColor3 = Color3.new(1, 1, 1)
BtnClose.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. LÓGICA DAS ANOMALIAS
-- ==========================================

-- Loop ultra-rápido do jogo
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myHrp = char.HumanoidRootPart
    local npcZones = Workspace:FindFirstChild("NPC Zones")

    if not npcZones then return end

    for _, npc in pairs(npcZones:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local hum = npc.Humanoid

            if hum.Health > 0 then
                
                -- [ TÉCNICA 1: MAGNET ] --
                -- Teleporta o monstro para 5 studs na sua frente
                if getgenv().MagnetAtivo then
                    -- Calculamos a posição da frente do jogador
                    local frente = myHrp.CFrame * CFrame.new(0, 0, -5)
                    hrp.CFrame = frente
                    hrp.CanCollide = false
                    hrp.Size = Vector3.new(4, 4, 4) -- Tamanho normal
                    hrp.Transparency = 1
                end

                -- [ TÉCNICA 2: HITBOX EXPANDER ] --
                -- Aumenta o tamanho físico do monstro para você acertar de longe
                if getgenv().HitboxAtivo and not getgenv().MagnetAtivo then
                    hrp.Size = Vector3.new(60, 60, 60)
                    hrp.Transparency = 0.6 -- Fica meio transparente pra você ver a caixa
                    hrp.Color = Color3.fromRGB(0, 255, 0)
                    hrp.CanCollide = false -- Para não te bugar
                elseif not getgenv().HitboxAtivo and not getgenv().MagnetAtivo then
                    -- Devolve ao normal se estiver tudo desligado
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end

            end
        end
    end
end)

-- ==========================================
-- 4. CONTROLES DOS BOTÕES
-- ==========================================
BtnMagnet.MouseButton1Click:Connect(function()
    getgenv().MagnetAtivo = not getgenv().MagnetAtivo
    if getgenv().MagnetAtivo then
        BtnMagnet.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        BtnMagnet.Text = "PUXAR MOBS: ON"
        -- Desliga o Hitbox por segurança
        getgenv().HitboxAtivo = false
        BtnHitbox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BtnHitbox.Text = "HITBOX GIGANTE: OFF"
    else
        BtnMagnet.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BtnMagnet.Text = "PUXAR MOBS: OFF"
    end
end)

BtnHitbox.MouseButton1Click:Connect(function()
    getgenv().HitboxAtivo = not getgenv().HitboxAtivo
    if getgenv().HitboxAtivo then
        BtnHitbox.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        BtnHitbox.Text = "HITBOX GIGANTE: ON"
        -- Desliga o Magnet por segurança
        getgenv().MagnetAtivo = false
        BtnMagnet.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BtnMagnet.Text = "PUXAR MOBS: OFF"
    else
        BtnHitbox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BtnHitbox.Text = "HITBOX GIGANTE: OFF"
    end
end)

BtnClose.MouseButton1Click:Connect(function()
    getgenv().MagnetAtivo = false
    getgenv().HitboxAtivo = false
    getgenv().AnomaliaHub = false
    ScreenGui:Destroy()
end)