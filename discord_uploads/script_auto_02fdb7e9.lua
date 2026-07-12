--[[
    🧲 HAZE SEAS: MAGNET GOD V41 (DUAL MODE + METRALHADORA) 🧲
    Adaptado do clássico para a estrutura do Haze Seas.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

getgenv().MagnetGodRunning = true

-- // CONFIGURAÇÕES //
local SETTINGS = {
    MagnetDist = 6,       -- Distância (Frente do player)
    HitboxSize = 5,       -- Tamanho da Hitbox
    KillRange = 2500,     -- Raio de busca
}

-- Variáveis de Estado
local IsRunning = false
local CurrentMode = "SINGLE" -- "SINGLE" ou "MASS"
local SingleTarget = nil
local MassTargets = {}       
local OriginalSizes = {}     

-- // GUI SETUP //
if CoreGui:FindFirstChild("RPGMagnetGod") then CoreGui.RPGMagnetGod:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RPGMagnetGod"
ScreenGui.Parent = CoreGui 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 170)
MainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Text = "🧲 HAZE MAGNET v41"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.2, 0)
Status.Text = "Status: Parado"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.BackgroundTransparency = 1

local ModeBtn = Instance.new("TextButton", MainFrame)
ModeBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
ModeBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
ModeBtn.Text = "MODO: 1v1 (SINGLE)"
ModeBtn.TextColor3 = Color3.fromRGB(100, 255, 255)
ModeBtn.Font = Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0.3, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
ToggleBtn.Text = "LIGAR MAGNETO"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold

-- // METRALHADORA DE DANO //
local function MetralhadoraDeDano(alvoHRP)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.01)
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

-- // LOOP DE ATAQUE (Para não bugar o Heartbeat) //
task.spawn(function()
    while task.wait(0.1) do
        if not IsRunning then continue end
        
        if CurrentMode == "SINGLE" and SingleTarget and SingleTarget:FindFirstChild("HumanoidRootPart") then
            MetralhadoraDeDano(SingleTarget.HumanoidRootPart)
        elseif CurrentMode == "MASS" then
            for mob, _ in pairs(MassTargets) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    MetralhadoraDeDano(mob.HumanoidRootPart)
                    break -- Foca o tiro no primeiro do bolo para não lagar
                end
            end
        end
    end
end)

-- // FUNÇÕES DE MAGNETO //
local function PrepareMob(mob)
    local root = mob:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if not OriginalSizes[mob] then OriginalSizes[mob] = root.Size end
    
    root.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
    root.Transparency = 0.6
    root.Color = (CurrentMode == "MASS") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    root.CanCollide = false
    root.Massless = true
end

local function RestoreMob(mob)
    if not mob then return end
    local root = mob:FindFirstChild("HumanoidRootPart")
    if root and OriginalSizes[mob] then
        root.Size = OriginalSizes[mob]
        root.Transparency = 1
        root.CanCollide = true
    end
    OriginalSizes[mob] = nil
end

local function RestoreAll()
    if SingleTarget then RestoreMob(SingleTarget) SingleTarget = nil end
    for mob, _ in pairs(MassTargets) do RestoreMob(mob) end
    MassTargets = {}
end

-- // INTERFACE CONTROLES //
ModeBtn.MouseButton1Click:Connect(function()
    RestoreAll()
    if CurrentMode == "SINGLE" then
        CurrentMode = "MASS"
        ModeBtn.Text = "MODO: BURACO NEGRO (MASS)"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    else
        CurrentMode = "SINGLE"
        ModeBtn.Text = "MODO: 1v1 (SINGLE)"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    IsRunning = not IsRunning
    if IsRunning then
        ToggleBtn.Text = "PARAR"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    else
        ToggleBtn.Text = "LIGAR MAGNETO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
        RestoreAll()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().MagnetGodRunning = false
    RestoreAll()
    ScreenGui:Destroy()
end)

-- // MOTOR DO MAGNETO (HEARTBEAT) //
RunService.Heartbeat:Connect(function()
    if not getgenv().MagnetGodRunning or not IsRunning then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local myRoot = char.HumanoidRootPart
    local pullPos = myRoot.CFrame * CFrame.new(0, 0, -SETTINGS.MagnetDist)
    
    local npcZones = Workspace:FindFirstChild("NPC Zones")
    if not npcZones then return end
    
    if CurrentMode == "SINGLE" then
        if SingleTarget then
            local hum = SingleTarget:FindFirstChild("Humanoid")
            local root = SingleTarget:FindFirstChild("HumanoidRootPart")
            
            if not hum or hum.Health <= 0 or not root or not SingleTarget.Parent then
                RestoreMob(SingleTarget)
                SingleTarget = nil
            else
                PrepareMob(SingleTarget)
                root.CFrame = pullPos
                root.Velocity = Vector3.new(0,0,0)
                Status.Text = "🧲 TRAVADO: " .. SingleTarget.Name
            end
        end
        
        if not SingleTarget then
            local closest = nil
            local minDist = 9999
            for _, mob in ipairs(npcZones:GetDescendants()) do
                if mob:IsA("Model") and mob ~= char then
                    local hum = mob:FindFirstChild("Humanoid")
                    local root = mob:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and root then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < minDist and dist < SETTINGS.KillRange then
                            minDist = dist
                            closest = mob
                        end
                    end
                end
            end
            if closest then SingleTarget = closest end
            Status.Text = "Procurando..."
        end
        
    elseif CurrentMode == "MASS" then
        local count = 0
        Status.Text = "🌌 PUXANDO TUDO..."
        
        for _, mob in ipairs(npcZones:GetDescendants()) do
            if mob:IsA("Model") and mob ~= char then
                local hum = mob:FindFirstChild("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Health > 0 and root then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist < SETTINGS.KillRange then
                        MassTargets[mob] = true
                        PrepareMob(mob)
                        root.CFrame = pullPos
                        root.Velocity = Vector3.new(0,0,0)
                        count = count + 1
                    end
                else
                    if MassTargets[mob] then
                        RestoreMob(mob)
                        MassTargets[mob] = nil
                    end
                end
            end
        end
        Status.Text = "🌌 ALVOS: " .. count
    end
end)