-- [[ RADAR SCANNER V5 (Detector de Proximidade) - Mobile Edition ]] --

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenName = "RadarScannerV5"
if CoreGui:FindFirstChild(ScreenName) then CoreGui[ScreenName]:Destroy() end

-- ==========================================
-- UI SETUP (Mobile Compacto)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenName
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 230)
MainFrame.Position = UDim2.new(0.5, -190, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100) -- Verde Radar
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(0, 40, 20)
Title.Text = "📡 RADAR SCANNER (PROXIMIDADE)"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.Position = UDim2.new(0, 0, 0.12, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Pronto para rastrear..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 11

-- Lista
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(0.96, 0, 0.60, 0)
ScrollList.Position = UDim2.new(0.02, 0, 0.20, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollList.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", ScrollList)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Variáveis do Radar
local LogHistory = {}    
local SeenPaths = {}     
local IsScanning = false
local RaioDeBusca = 150 -- Só pega monstros a menos de 150 metros de você

-- ==========================================
-- LÓGICA DO RADAR
-- ==========================================
local function ScanNearby()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Olha tudo que existe no mapa
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Anti-crash: pausa minúscula a cada 100 itens para não travar o celular
        if math.random(1, 100) == 1 then task.wait() end 

        if obj:IsA("Model") then
            -- Ignora você mesmo e outros jogadores
            if obj == char or Players:GetPlayerFromCharacter(obj) then
                continue
            end

            local targetPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                
                -- Se estiver perto o suficiente
                if dist <= RaioDeBusca then
                    local fullPath = obj:GetFullName()
                    
                    -- Se já achou esse bicho, ignora
                    if not SeenPaths[fullPath] then
                        SeenPaths[fullPath] = true
                        
                        local textoTela = string.format("[%.1fm] %s", dist, obj.Name)
                        local textoTXT = string.format("DISTANCIA: %.1f | NOME: %s | PATH: %s", dist, obj.Name, fullPath)
                        
                        table.insert(LogHistory, textoTXT)
                        
                        -- Cria o item na lista visual
                        local lbl = Instance.new("TextLabel", ScrollList)
                        lbl.Size = UDim2.new(1, 0, 0, 16)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = textoTela
                        lbl.TextColor3 = Color3.fromRGB(200, 255, 200)
                        lbl.Font = Enum.Font.Code
                        lbl.TextSize = 11
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                    end
                end
            end
        end
    end
    StatusLabel.Text = "Capturados: " .. #LogHistory
end

-- Loop automático quando ativado
task.spawn(function()
    while task.wait(1) do
        if not CoreGui:FindFirstChild(ScreenName) then break end
        if IsScanning then
            ScanNearby()
        end
    end
end)

-- ==========================================
-- FUNÇÕES DOS BOTÕES
-- ==========================================
local function ToggleScan()
    IsScanning = not IsScanning
    if IsScanning then
        StatusLabel.Text = "🟢 RASTREANDO AO REDOR..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "🔴 PAUSADO"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

local function SaveToFile()
    if #LogHistory == 0 then return end
    local fileName = "RADAR_LOG_" .. os.date("%H%M%S") .. ".txt"
    local content = table.concat(LogHistory, "\n")
    
    local success, err = pcall(function() writefile(fileName, content) end)
    
    if success then
        StatusLabel.Text = "✅ SALVO: " .. fileName
        MainFrame.BorderColor3 = Color3.new(0,1,0)
        task.wait(0.5)
        MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
    else
        StatusLabel.Text = "❌ ERRO AO SALVAR"
    end
end

local function ClearLogs()
    LogHistory = {}
    SeenPaths = {}
    for _, v in pairs(ScrollList:GetChildren()) do 
        if v:IsA("TextLabel") then v:Destroy() end 
    end
    StatusLabel.Text = "🗑️ LIMPADO"
end

-- ==========================================
-- BOTÕES NA TELA
-- ==========================================
local BtnContainer = Instance.new("Frame", MainFrame)
BtnContainer.Size = UDim2.new(1, -10, 0.15, 0)
BtnContainer.Position = UDim2.new(0, 5, 0.83, 0)
BtnContainer.BackgroundTransparency = 1

local function CreateBtn(text, order, color, func)
    local btn = Instance.new("TextButton", BtnContainer)
    btn.Size = UDim2.new(0.3, 0, 0.8, 0)
    btn.Position = UDim2.new((order-1)*0.33, 0, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(func)
end

CreateBtn("🟢 LIGAR/DESLIGAR", 1, Color3.fromRGB(50, 150, 50), ToggleScan)
CreateBtn("💾 SALVAR TXT", 2, Color3.fromRGB(0, 150, 200), SaveToFile)
CreateBtn("🗑️ LIMPAR", 3, Color3.fromRGB(200, 50, 50), ClearLogs)