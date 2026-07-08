--[[
    XUCRIA HUB - AUTO FORJA DE BOMBAS (Andando)
    Desenvolvido para: Xucria
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)

-- Carrega a Interface
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 XUCRIA HUB",
    LoadingTitle = "XUCRIA Hub",
    LoadingSubtitle = "Fábrica de Bombas 💣",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
    Theme = "Dark",
})

local MainTab = Window:CreateTab("🤖 Auto Forja", 4483362458)

-- ==========================================
-- FUNÇÕES ÚTEIS
-- ==========================================
local function GetPlayerBase()
    local BasesFolder = Workspace:FindFirstChild("Bases")
    if BasesFolder then
        for _, folder in ipairs(BasesFolder:GetChildren()) do
            if folder:GetAttribute("OwnerUserId") == PlayerId then
                return folder
            end
        end
    end
    return nil
end

-- Função inteligente para andar até um ponto e não bugar
local function WalkTo(targetPos)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end
    
    hum:MoveTo(targetPos)
    
    -- Espera o boneco chegar (com um limite de tempo pra não travar caso ele enganche numa parede)
    local timeout = 0
    while (root.Position - targetPos).Magnitude > 5 and timeout < 50 do
        if not _G.AutoForjaAndando then break end -- Se o jogador desligar, para de andar
        task.wait(0.1)
        timeout = timeout + 1
    end
end

-- ==========================================
-- LÓGICA PRINCIPAL
-- ==========================================
MainTab:CreateSection("CONTROLE DA FÁBRICA")

MainTab:CreateToggle({
    Name = "🏃 Auto Juntar e Fundir",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoForjaAndando = Value
        
        if _G.AutoForjaAndando then
            task.spawn(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- Onde você estiver quando ligar, vira o centro do monte!
                local mergeSpot = root.Position 
                Rayfield:Notify({Title = "Forja Definida!", Content = "O monte será feito onde você ativou.", Duration = 3})

                while _G.AutoForjaAndando do
                    local myBase = GetPlayerBase()
                    if not myBase or not myBase:FindFirstChild("Nukes") then 
                        task.wait(1) 
                        continue 
                    end
                    
                    -- Lista as bombas
                    local nukeList = {}
                    for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                        if nuke.Name == "Nuke" and nuke.Parent then
                            table.insert(nukeList, nuke)
                        end
                    end
                    
                    local temBombaEspalhada = false
                    
                    -- ETAPA 1: O Arrastão (Buscar bombas longe do centro)
                    for _, nuke in ipairs(nukeList) do
                        if not _G.AutoForjaAndando then break end
                        
                        local nukePos = nuke:GetPivot().Position
                        -- Se a bomba estiver a mais de 10 metros do monte
                        if (nukePos - mergeSpot).Magnitude > 10 then
                            temBombaEspalhada = true
                            
                            -- Vai até ela
                            WalkTo(nukePos)
                            task.wait(0.1)
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                            task.wait(0.1)
                            
                            -- Volta pro centro
                            WalkTo(mergeSpot)
                            task.wait(0.1)
                            ReplicatedStorage.NukeRemotes.Drop:FireServer(CFrame.new(mergeSpot))
                            task.wait(0.1)
                        end
                    end
                    
                    -- ETAPA 2: A Forja (Se não tem bomba espalhada, fica no centro fundindo)
                    if not temBombaEspalhada and _G.AutoForjaAndando then
                        -- Fica parado no centro
                        WalkTo(mergeSpot)
                        task.wait(0.2)
                        
                        for _, nuke in ipairs(nukeList) do
                            if not _G.AutoForjaAndando then break end
                            
                            -- Confirma se a bomba ainda existe e se está no centro
                            if nuke.Parent and (nuke:GetPivot().Position - mergeSpot).Magnitude <= 10 then
                                ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                                task.wait(1.2) -- O tempo de segurar pra fundir
                                ReplicatedStorage.NukeRemotes.Drop:FireServer(CFrame.new(mergeSpot))
                                task.wait(0.1)
                            end
                        end
                    end
                    
                    task.wait(0.5) -- Respiro antes do próximo ciclo
                end
            end)
        end
    end
})

-- Um botão extra só por precaução pra você andar mais rápido e não perder tempo
MainTab:CreateSlider({
    Name = "Velocidade de Caminhada",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 30,
    Callback = function(Value)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})