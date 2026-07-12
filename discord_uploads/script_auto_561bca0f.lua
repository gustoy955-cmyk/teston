-- [[ 🔬 HAZE SEAS: ULTIMATE DEEP SCANNER 🔬 ]] --

if getgenv().DeepScannerExecutado then return end
getgenv().DeepScannerExecutado = true

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ==========================================
-- 1. FAXINA AUTOMÁTICA (APAGA TUDO ANTIGO)
-- ==========================================
local function LimparTelasAntigas()
    local nomes = {"GhostAuraGUI", "AnomaliaGUI", "HazeFarmGUI", "DeepScannerGUI"}
    for _, gui in pairs(CoreGui:GetChildren()) do
        if table.find(nomes, gui.Name) then
            gui:Destroy()
        end
    end
end
LimparTelasAntigas()

-- ==========================================
-- 2. CRIAÇÃO DO PAINEL (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "DeepScannerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame); Stroke.Color = Color3.fromRGB(255, 150, 0); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔬 DEEP SCANNER"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.BackgroundTransparency = 1

local StatusText = Instance.new("TextLabel", MainFrame)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0.15, 0)
StatusText.Text = "Aguardando comando..."
StatusText.TextColor3 = Color3.new(1, 1, 1)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Code

local BtnScan = Instance.new("TextButton", MainFrame)
BtnScan.Size = UDim2.new(0.9, 0, 0, 35)
BtnScan.Position = UDim2.new(0.05, 0, 0.3, 0)
BtnScan.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BtnScan.Text = "INICIAR SCANNER"
BtnScan.TextColor3 = Color3.new(1, 1, 1)
BtnScan.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnScan).CornerRadius = UDim.new(0, 6)

local BtnSave = Instance.new("TextButton", MainFrame)
BtnSave.Size = UDim2.new(0.9, 0, 0, 35)
BtnSave.Position = UDim2.new(0.05, 0, 0.55, 0)
BtnSave.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
BtnSave.Text = "SALVAR EM .TXT"
BtnSave.TextColor3 = Color3.new(1, 1, 1)
BtnSave.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0, 6)

local BtnClose = Instance.new("TextButton", MainFrame)
BtnClose.Size = UDim2.new(0.9, 0, 0, 30)
BtnClose.Position = UDim2.new(0.05, 0, 0.8, 0)
BtnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnClose.Text = "FECHAR SCRIPT"
BtnClose.TextColor3 = Color3.new(1, 1, 1)
BtnClose.Font = Enum.Font.GothamBold
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 3. LÓGICA DO SCANNER
-- ==========================================
local scanData = ""
local itensEscaneados = 0

local function IniciarScan()
    StatusText.Text = "Escaneando... Aguarde."
    scanData = "=== 🔬 RELATÓRIO DE ESTRUTURA DO JOGO 🔬 ===\n\n"
    
    local locaisParaEscanear = {
        ["ReplicatedStorage"] = ReplicatedStorage,
        ["Workspace"] = Workspace,
        ["Players"] = Players
    }

    local remotes = "\n--- 📡 REMOTES ENCONTRADOS ---\n"
    local modulos = "\n--- ⚙️ MODULE SCRIPTS (Sistemas do Jogo) ---\n"
    local npcs = "\n--- 🧟 NPCs E INIMIGOS ---\n"

    -- Tabelas para evitar repetição
    local remotesSalvos = {}
    local modulosSalvos = {}
    local npcsSalvos = {}

    for nomeLocal, servico in pairs(locaisParaEscanear) do
        for _, obj in pairs(servico:GetDescendants()) do
            
            -- Pega Remotes
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                local caminho = obj:GetFullName()
                if not remotesSalvos[caminho] then
                    remotesSalvos[caminho] = true
                    remotes = remotes .. "[Tipo: " .. obj.ClassName .. "] " .. caminho .. "\n"
                    itensEscaneados = itensEscaneados + 1
                end
            end

            -- Pega Módulos
            if obj:IsA("ModuleScript") then
                local caminho = obj:GetFullName()
                if not modulosSalvos[caminho] then
                    modulosSalvos[caminho] = true
                    modulos = modulos .. caminho .. "\n"
                    itensEscaneados = itensEscaneados + 1
                end
            end

            -- Pega NPCs
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= Players.LocalPlayer.Name then
                local caminho = obj:GetFullName()
                if not npcsSalvos[caminho] then
                    npcsSalvos[caminho] = true
                    npcs = npcs .. "[Vida: " .. tostring(obj.Humanoid.MaxHealth) .. "] " .. caminho .. "\n"
                    itensEscaneados = itensEscaneados + 1
                end
            end
            
        end
    end

    scanData = scanData .. remotes .. modulos .. npcs
    StatusText.Text = "Itens mapeados: " .. tostring(itensEscaneados)
    BtnScan.Text = "SCAN FINALIZADO"
    BtnScan.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end

-- ==========================================
-- 4. CONTROLES DOS BOTÕES
-- ==========================================
BtnScan.MouseButton1Click:Connect(function()
    if itensEscaneados == 0 then
        IniciarScan()
    end
end)

BtnSave.MouseButton1Click:Connect(function()
    if itensEscaneados == 0 then
        StatusText.Text = "Erro: Faça o scan primeiro!"
        return
    end

    if writefile then
        local nomeArquivo = "HazeSeas_RaioX.txt"
        writefile(nomeArquivo, scanData)
        StatusText.Text = "Salvo como: " .. nomeArquivo
        BtnSave.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        BtnSave.Text = "SALVO COM SUCESSO!"
    else
        StatusText.Text = "Erro: Executor não suporta writefile."
    end
    
    task.wait(2)
    BtnSave.Text = "SALVAR EM .TXT"
    BtnSave.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
end)

BtnClose.MouseButton1Click:Connect(function()
    getgenv().DeepScannerExecutado = false
    ScreenGui:Destroy()
end)