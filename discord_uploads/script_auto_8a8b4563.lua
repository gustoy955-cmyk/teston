--[[
    🔬 NPC ANALYZER (SCAN DE INIMIGOS)
    Objetivo: Varre o mapa procurando NPCs, descobre onde eles ficam salvos,
    a vida deles e gera um TXT para criarmos o Auto-Kill.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// GUI SETUP
local guiName = "NPCAnalyzer"
if game.CoreGui:FindFirstChild(guiName) then game.CoreGui[guiName]:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui); ScreenGui.Name = guiName

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
MainFrame.Active = true; MainFrame.Draggable = true
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(0, 255, 255); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "🔬 NPC ANALYZER"; Title.Font = Enum.Font.GothamBlack; Title.TextColor3 = Color3.fromRGB(0, 255, 255); Title.BackgroundTransparency = 1

local LogBox = Instance.new("ScrollingFrame", MainFrame)
LogBox.Size = UDim2.new(0.9, 0, 0.65, 0); LogBox.Position = UDim2.new(0.05, 0, 0.15, 0)
LogBox.BackgroundColor3 = Color3.fromRGB(20, 25, 30); LogBox.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LogText = Instance.new("TextLabel", LogBox)
LogText.Size = UDim2.new(1, 0, 0, 0); LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.TextColor3 = Color3.new(1, 1, 1); LogText.BackgroundTransparency = 1
LogText.TextXAlignment = Enum.TextXAlignment.Left; LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Font = Enum.Font.Code; LogText.TextSize = 12
LogText.Text = "Clique em SCAN para buscar NPCs..."

local ScanBtn = Instance.new("TextButton", MainFrame)
ScanBtn.Size = UDim2.new(0.4, 0, 0.12, 0); ScanBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); ScanBtn.Text = "ESCANEAR NPCs"; ScanBtn.TextColor3 = Color3.new(1,1,1); ScanBtn.Font = Enum.Font.GothamBold

local CopyBtn = Instance.new("TextButton", MainFrame)
CopyBtn.Size = UDim2.new(0.4, 0, 0.12, 0); CopyBtn.Position = UDim2.new(0.55, 0, 0.85, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100); CopyBtn.Text = "SALVAR / COPIAR"; CopyBtn.TextColor3 = Color3.new(1,1,1); CopyBtn.Font = Enum.Font.GothamBold

local reportData = ""

local function ScanNPCs()
    reportData = "--- RELATÓRIO DE NPCs NO MAPA ---\n"
    local count = 0
    
    -- Varre TUDO no mapa
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Se for um modelo, tiver um Humanoid e NÃO for o seu personagem
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= LocalPlayer.Name then
            
            -- Ignora outros jogadores reais
            if not Players:GetPlayerFromCharacter(obj) then
                count = count + 1
                reportData = reportData .. "NPC: " .. obj.Name .. "\n"
                reportData = reportData .. "   Caminho: " .. obj:GetFullName() .. "\n"
                reportData = reportData .. "   Vida Max: " .. tostring(obj.Humanoid.MaxHealth) .. "\n"
                reportData = reportData .. "----------------------------------\n"
            end
        end
    end
    
    if count == 0 then
        reportData = reportData .. "Nenhum NPC encontrado no mapa inteiro."
    else
        reportData = "Total de NPCs achados: " .. count .. "\n\n" .. reportData
    end
    
    LogText.Text = reportData
end

ScanBtn.MouseButton1Click:Connect(ScanNPCs)

CopyBtn.MouseButton1Click:Connect(function()
    -- Tenta copiar para o PC (se o MuMu estiver com sync ativado)
    if setclipboard then
        pcall(function() setclipboard(reportData) end)
    end
    
    -- Cria um arquivo de texto físico dentro do emulador
    if writefile then
        pcall(function() writefile("MeusNPCs.txt", reportData) end)
        CopyBtn.Text = "SALVO NO ARQUIVO!"
    else
        CopyBtn.Text = "ERRO: SEM WRITEFILE"
    end
    
    task.wait(2)
    CopyBtn.Text = "SALVAR / COPIAR"
end)