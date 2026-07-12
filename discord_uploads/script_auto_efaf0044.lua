--[[
    🧲 IRON SOUL: MAGNET GOD V1 (BURACO NEGRO + AUTO-KILL) 🧲
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

getgenv().IronMagnetRunning = true

-- // CONFIGURAÇÕES //
local SETTINGS = {
    MagnetDist = 8,       -- Fica 8 studs na sua frente para não te bugar
    HitboxSize = 5,       -- Tamanho da Hitbox fantasma
    KillRange = 3000,     -- Raio absurdo para puxar o mapa todo
}

local IsRunning = false
local MassTargets = {}       
local OriginalSizes = {}     

-- // GUI SETUP //
if CoreGui:FindFirstChild("IronMagnetGUI") then CoreGui.IronMagnetGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IronMagnetGUI"
ScreenGui.Parent = CoreGui 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Text = "🧲 IRON MAGNET 🧲"
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.Font = Enum.Font.GothamBlack
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleBtn.Text = "BURACO NEGRO: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- // METRALHADORA DE DANO (IRON SOUL) //
local actionRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PlayerActionRE")

local function MetralhadoraDeDano()
    -- Simula clique frenético
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)

    -- Dispara o Remote de Ação encontrado no Raio-X
    if actionRemote then
        pcall(function()
            actionRemote:FireServer()
            -- Tenta forçar as skills numéricas (1, 2, 3)
            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            VIM:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
        end)
    end
end

-- // LOOP DE ATAQUE //
task.spawn(function()
    while task.wait(0.1) do
        if not IsRunning then continue end
        MetralhadoraDeDano()
    end
end)

-- // FUNÇÕES DE MAGNETO //
local function PrepareMob(mob)
    local root = mob:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not OriginalSizes[mob] then OriginalSizes[mob] = root.Size end
    
    root.Size = Vector3.new(SETTINGS.HitboxSize, SETTINGS.HitboxSize, SETTINGS.HitboxSize)
    root.Transparency = 0.6
    root.Color = Color3.fromRGB(255, 0, 0)
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
    for mob, _ in pairs(MassTargets) do RestoreMob(mob) end
    MassTargets = {}
end

-- // INTERFACE CONTROLES //
ToggleBtn.MouseButton1Click:Connect(function()
    IsRunning = not IsRunning
    if IsRunning then
        ToggleBtn.Text = "BURACO NEGRO: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
    else
        ToggleBtn.Text = "BURACO NEGRO: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        RestoreAll()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().IronMagnetRunning = false
    RestoreAll()
    ScreenGui:Destroy()
end)

-- // MOTOR DO MAGNETO (HEARTBEAT) //
RunService.Heartbeat:Connect(function()
    if not getgenv().IronMagnetRunning or not IsRunning then return end
    
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local myRoot = char.HumanoidRootPart
    local pullPos = myRoot.CFrame * CFrame.new(0, 0, -SETTINGS.MagnetDist)
    
    local enemiesFolder = Workspace:FindFirstChild("EnemyNpc")
    if not enemiesFolder then return end
    
    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if mob:IsA("Model") then
            local hum = mob:FindFirstChild("Humanoid")
            local root = mob:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and root then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < SETTINGS.KillRange then
                    MassTargets[mob] = true
                    PrepareMob(mob)
                    -- Puxa todo mundo para o mesmo ponto
                    root.CFrame = pullPos
                    root.Velocity = Vector3.new(0,0,0)
                end
            else
                if MassTargets[mob] then
                    RestoreMob(mob)
                    MassTargets[mob] = nil
                end
            end
        end
    end
end)