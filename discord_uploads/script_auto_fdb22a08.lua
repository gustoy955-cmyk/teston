-- [[ ☠️ HAZE SEAS AUTO-FARM V3 (MODO ÂNCORA & NINJA) ☠️ ]] --

if getgenv().HazeFarmExecutado then return end
getgenv().HazeFarmExecutado = true
getgenv().AutoFarm = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. FAXINA DA TELA
-- ==========================================
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "HazeFarmGUI" then gui:Destroy() end
end

-- ==========================================
-- 2. PAINEL DE CONTROLE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "HazeFarmGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 130)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 0, 0); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "☠️ HAZE V3 ☠️"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Text = "FARM: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseBtn.Text = "FECHAR SCRIPT"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. SISTEMA DE ATAQUE FRENÉTICO
-- ==========================================
local function SoltarSkills()
    -- Clica o mouse
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    -- Aperta Z, X, C, V, B
    local teclas = {"Z", "X", "C", "V", "B"}
    for _, tecla in pairs(teclas) do
        VIM:SendKeyEvent(true, Enum.KeyCode[tecla], false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode[tecla], false, game)
    end
end

-- ==========================================
-- 4. LÓGICA DO FARM
-- ==========================================
task.spawn(function()
    while task.wait() do
        if not getgenv().AutoFarm then
            -- Se desligar, solta o personagem para ele cair no chão normal
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
            continue 
        end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        local npcZones = Workspace:FindFirstChild("NPC Zones")
        if not npcZones then continue end

        for _, npc in pairs(npcZones:GetDescendants()) do
            if not getgenv().AutoFarm then break end

            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")

            -- Se for um monstro vivo e NÃO estiver caído no limbo (Y < -100)
            if npc:IsA("Model") and humanoid and rootPart and humanoid.Health > 0 and rootPart.Position.Y > -100 then
                
                while humanoid.Health > 0 and getgenv().AutoFarm do
                    task.wait()
                    
                    char = LocalPlayer.Character
                    if not char or char.Humanoid.Health <= 0 then break end
                    hrp = char.HumanoidRootPart

                    -- Posição: Nas COSTAS do NPC e um pouquinho acima (Para não apanhar)
                    local alvoCFrame = rootPart.CFrame * CFrame.new(0, 5, 5) 
                    local distancia = (hrp.Position - alvoCFrame.Position).Magnitude

                    if distancia > 10 then
                        -- Solta a âncora para poder voar até ele
                        hrp.Anchored = false
                        local tweenInfo = TweenInfo.new(distancia / 150, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = alvoCFrame})
                        tween:Play()
                        
                        -- Espera chegar perto para não bugar
                        repeat task.wait(0.1) until (hrp.Position - alvoCFrame.Position).Magnitude <= 10 or humanoid.Health <= 0 or not getgenv().AutoFarm
                        tween:Cancel()
                    else
                        -- Chegou no monstro? TRAVA A ÂNCORA E BATE!
                        hrp.Anchored = true 
                        
                        -- Vira o boneco olhando pra baixo na nuca do monstro
                        hrp.CFrame = CFrame.lookAt(alvoCFrame.Position, rootPart.Position)
                        
                        SoltarSkills()
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 5. BOTÕES
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    if getgenv().AutoFarm then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        ToggleBtn.Text = "FARM: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleBtn.Text = "FARM: OFF"
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    getgenv().HazeFarmExecutado = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
    ScreenGui:Destroy()
end)