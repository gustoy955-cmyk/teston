-- [[ ☠️ HAZE SEAS: GHOST KILLER (AURA DE DANO) ☠️ ]] --

if getgenv().GhostKillerExecutado then return end
getgenv().GhostKillerExecutado = true
getgenv().AutoFarm = false

local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Limpa telas anteriores
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "GhostKillerGUI" then gui:Destroy() end
end

-- ==========================================
-- PAINEL DE CONTROLE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "GhostKillerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Text = "AURA: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold

-- ==========================================
-- LÓGICA DO ATAQUE (SEM MOVIMENTO)
-- ==========================================
local remote = ReplicatedStorage:FindFirstChild("Smoke Punch", true) or 
               game:GetService("Players").LocalPlayer.Character:FindFirstChild("Smoke Punch", true)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoFarm then
            local npcZones = Workspace:FindFirstChild("NPC Zones")
            if npcZones then
                for _, npc in pairs(npcZones:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        -- Tenta disparar o evento de ataque
                        if remote then
                            -- O servidor processa o dano se o evento for validado
                            pcall(function() remote:FireServer() end)
                        end
                    end
                end
            end
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    ToggleBtn.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    ToggleBtn.Text = getgenv().AutoFarm and "AURA: ON" or "AURA: OFF"
end)