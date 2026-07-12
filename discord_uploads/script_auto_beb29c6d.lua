-- [[ ☠️ HAZE SEAS: HUNTER NINJA (FARME GRADUAL & SEGURO) ]] --

if getgenv().HunterNinjaExecutado then return end
getgenv().HunterNinjaExecutado = true
getgenv().AutoFarm = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. PAINEL DE CONTROLE (GUI LIMPA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 80); MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0.8, 0); ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); ToggleBtn.Text = "NINJA: OFF"

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    ToggleBtn.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.Text = getgenv().AutoFarm and "NINJA: ON" or "NINJA: OFF"
end)

-- ==========================================
-- 2. FUNÇÕES DE ATAQUE
-- ==========================================
local function SoltarSkills()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1) -- Soco
    task.wait(0.05)
    for _, k in pairs({Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B}) do
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, k, false, game)
    end
end

-- ==========================================
-- 3. LÓGICA DE BUSCA GRADUAL E ATAQUE
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().AutoFarm then continue end
        
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local raioBusca = 50 -- Começa buscando perto
        local alvoEncontrado = nil

        -- Aumenta o raio gradualmente se não achar nada
        while not alvoEncontrado and raioBusca < 2000 do
            for _, npc in pairs(Workspace["NPC Zones"]:GetDescendants()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
                    if (npc.HumanoidRootPart.Position - hrp.Position).Magnitude < raioBusca then
                        alvoEncontrado = npc
                        break
                    end
                end
            end
            if not alvoEncontrado then raioBusca = raioBusca + 100 end
        end

        if alvoEncontrado then
            -- Teleporta suave para as costas
            local posCostas = alvoEncontrado.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            hrp.Anchored = true -- Ancorado para não quicar
            hrp.CFrame = posCostas
            
            -- Ataca enquanto o monstro estiver vivo
            while alvoEncontrado.Humanoid.Health > 0 and getgenv().AutoFarm do
                hrp.CFrame = alvoEncontrado.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                SoltarSkills()
                task.wait(0.2)
            end
            hrp.Anchored = false
        end
    end
end)