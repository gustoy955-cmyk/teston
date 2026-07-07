-- [[ AUTO CAÇADOR V1 (Focado no Mais Próximo) - Mobile Edition ]] --

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- SISTEMA DE LIMPEZA (Evita scripts duplicados)
-- ==========================================
local ScreenName = "HubCacadorEvomon"
if CoreGui:FindFirstChild(ScreenName) then 
    CoreGui[ScreenName]:Destroy() 
end
_G.Cacando = false -- Garante que o loop pare ao reiniciar

-- ==========================================
-- CRIAÇÃO DA INTERFACE (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenName
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
Title.Text = "🎯 AUTO CAÇADOR"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14

local NomeInput = Instance.new("TextBox", MainFrame)
NomeInput.Size = UDim2.new(0.9, 0, 0, 30)
NomeInput.Position = UDim2.new(0.05, 0, 0.25, 0)
NomeInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
NomeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NomeInput.PlaceholderText = "Digite o nome (Ex: Pet0_66)"
NomeInput.Font = Enum.Font.Gotham
NomeInput.TextSize = 12
NomeInput.ClearTextOnFocus = false
Instance.new("UICorner", NomeInput).CornerRadius = UDim.new(0, 4)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.42, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ToggleBtn.Text = "🟢 INICIAR"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0.42, 0, 0, 35)
CloseBtn.Position = UDim2.new(0.53, 0, 0.55, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "❌ FECHAR HUB"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.82, 0)
Status.BackgroundTransparency = 1
Status.Text = "Aguardando..."
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.TextSize = 10

-- ==========================================
-- LÓGICA DE CAÇA (O MAIS PRÓXIMO)
-- ==========================================
local function GetClosestPet(petName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local CreatureCache = Workspace:FindFirstChild("RuntimeCache")
    if not CreatureCache then return nil end
    local ServerCache = CreatureCache:FindFirstChild("RuntimeCacheServer")
    if not ServerCache then return nil end
    local CacheFolder = ServerCache:FindFirstChild("CreatureModelCache")
    if not CacheFolder then return nil end

    local closestPetPart = nil
    local shortestDistance = math.huge -- Começa com uma distância infinita

    -- Passa por todas as pastas procurando o monstro
    for _, folder in ipairs(CacheFolder:GetChildren()) do
        local pet = folder:FindFirstChild(petName)
        
        if pet then
            local targetPart = pet.PrimaryPart or pet:FindFirstChild("HumanoidRootPart")
            if targetPart then
                -- Calcula a distância exata entre você e o monstro
                local distance = (root.Position - targetPart.Position).Magnitude
                
                -- Se esse for o mais perto até agora, salva ele!
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPetPart = targetPart
                end
            end
        end
    end
    
    return closestPetPart
end

-- ==========================================
-- EVENTOS DOS BOTÕES
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    if NomeInput.Text == "" then
        Status.Text = "⚠️ Digite o nome do bicho primeiro!"
        return
    end

    _G.Cacando = not _G.Cacando

    if _G.Cacando then
        ToggleBtn.Text = "🔴 PARAR"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        Status.Text = "Procurando o alvo mais próximo..."
    else
        ToggleBtn.Text = "🟢 INICIAR"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        Status.Text = "Caçada pausada."
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.Cacando = false -- Desliga o loop
    ScreenGui:Destroy() -- Destrói a interface da tela
end)

-- ==========================================
-- LOOP DE MOVIMENTAÇÃO AUTOMÁTICA
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do -- Checa e atualiza a rota a cada meio segundo
        -- Se o cara fechou a interface enquanto o script rodava, quebra o loop de vez
        if not CoreGui:FindFirstChild(ScreenName) then break end 
        
        if _G.Cacando then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum then
                local alvo = GetClosestPet(NomeInput.Text)
                if alvo then
                    hum:MoveTo(alvo.Position)
                    Status.Text = "Correndo até o alvo!"
                else
                    Status.Text = "Alvo não encontrado na área."
                end
            end
        end
    end
end)