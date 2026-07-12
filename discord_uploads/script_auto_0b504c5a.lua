-- [[ ☠️ HAZE SEAS: GHOST AURA V2 (TELA CONGELADA) ☠️ ]] --

if getgenv().GhostAuraHub then return end
getgenv().GhostAuraHub = true
getgenv().GhostAtivo = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera
local SafePosition = nil

-- ==========================================
-- 1. FAXINA DE TELA
-- ==========================================
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "GhostAuraGUI" then gui:Destroy() end
end

-- ==========================================
-- 2. PAINEL GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GhostAuraGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(0, 200, 255); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "👁️ TELA FANTASMA 👁️"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.BackgroundTransparency = 1

local BtnGhost = Instance.new("TextButton", MainFrame)
BtnGhost.Size = UDim2.new(0.9, 0, 0, 40)
BtnGhost.Position = UDim2.new(0.05, 0, 0.3, 0)
BtnGhost.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BtnGhost.Text = "FARM INVISÍVEL: OFF"
BtnGhost.TextColor3 = Color3.new(1, 1, 1)
BtnGhost.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnGhost).CornerRadius = UDim.new(0, 6)

local BtnClose = Instance.new("TextButton", MainFrame)
BtnClose.Size = UDim2.new(0.9, 0, 0, 30)
BtnClose.Position = UDim2.new(0.05, 0, 0.65, 0)
BtnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnClose.Text = "FECHAR SCRIPT"
BtnClose.TextColor3 = Color3.new(1, 1, 1)
BtnClose.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. LÓGICA DO FARM COM CÂMERA TRAVADA
-- ==========================================
local function SoltarAtaque()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    local teclas = {"Z", "X", "C"}
    for _, tecla in pairs(teclas) do
        VIM:SendKeyEvent(true, Enum.KeyCode[tecla], false, game)
        task.wait(0.01)
        VIM:SendKeyEvent(false, Enum.KeyCode[tecla], false, game)
    end
end

task.spawn(function()
    while task.wait() do
        if not getgenv().GhostAtivo then continue end

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        local npcZones = Workspace:FindFirstChild("NPC Zones")
        if not npcZones then continue end

        for _, npc in pairs(npcZones:GetDescendants()) do
            if not getgenv().GhostAtivo then break end

            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")

            if npc:IsA("Model") and humanoid and rootPart and humanoid.Health > 0 then
                
                while humanoid.Health > 0 and getgenv().GhostAtivo do
                    hrp.Anchored = true
                    hrp.CFrame = rootPart.CFrame * CFrame.new(0, 0, 4) 
                    hrp.CFrame = CFrame.lookAt(hrp.Position, rootPart.Position)
                    
                    SoltarAtaque()
                    task.wait(0.15) 
                    
                    if SafePosition then
                        hrp.CFrame = SafePosition
                    end
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- ==========================================
-- 4. CONTROLES (TRAVANDO A CÂMERA)
-- ==========================================
BtnGhost.MouseButton1Click:Connect(function()
    getgenv().GhostAtivo = not getgenv().GhostAtivo
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    if getgenv().GhostAtivo then
        -- LIGOU: Salva posição e Desgruda a Câmera
        SafePosition = char.HumanoidRootPart.CFrame
        Cam.CameraType = Enum.CameraType.Scriptable
        
        BtnGhost.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        BtnGhost.Text = "FARM INVISÍVEL: ON"
    else
        -- DESLIGOU: Devolve a Câmera pro Personagem
        BtnGhost.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        BtnGhost.Text = "FARM INVISÍVEL: OFF"
        
        char.HumanoidRootPart.Anchored = false
        if SafePosition then
            char.HumanoidRootPart.CFrame = SafePosition
        end
        
        Cam.CameraType = Enum.CameraType.Custom
        Cam.CameraSubject = char.Humanoid
    end
end)

BtnClose.MouseButton1Click:Connect(function()
    getgenv().GhostAtivo = false
    getgenv().GhostAuraHub = false
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
        Cam.CameraType = Enum.CameraType.Custom
        Cam.CameraSubject = LocalPlayer.Character.Humanoid
    end
    ScreenGui:Destroy()
end)