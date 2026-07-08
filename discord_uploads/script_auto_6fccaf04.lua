--[[
    XUCRIA HUB - ÍMÃ DE BOMBAS + AUTO FUSÃO
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
    LoadingSubtitle = "O Ímã de Bombas 💣",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
    Theme = "Dark",
})

local MainTab = Window:CreateTab("🧲 Ímã e Fusão", 4483362458)

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

MainTab:CreateSection("CONTROLE MAGNÉTICO")

MainTab:CreateToggle({
    Name = "🧲 Puxar Todas + Fundir",
    CurrentValue = false,
    Callback = function(Value)
        _G.ImaDeBomba = Value
        
        if _G.ImaDeBomba then
            task.spawn(function()
                while _G.ImaDeBomba do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local myBase = GetPlayerBase()
                    
                    if root and myBase and myBase:FindFirstChild("Nukes") then
                        local meuPe = root.CFrame -- Salva a posição exata do seu pé
                        
                        -- Pega todas as bombas da base
                        local nukeList = {}
                        for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                            if nuke.Name == "Nuke" then
                                table.insert(nukeList, nuke)
                            end
                        end
                        
                        if #nukeList > 0 then
                            -- PASSO 1: O ÍMÃ (Teleporta todas pro seu pé)
                            for _, nuke in ipairs(nukeList) do
                                if not _G.ImaDeBomba then break end
                                
                                -- Se a bomba estiver longe, puxa ela
                                if (nuke:GetPivot().Position - meuPe.Position).Magnitude > 5 then
                                    ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                                    task.wait(0.1) -- Tempo pro servidor processar
                                    ReplicatedStorage.NukeRemotes.Drop:FireServer(meuPe)
                                    task.wait(0.1)
                                end
                            end
                            
                            -- PASSO 2: A FUSÃO (Pega 1 por 1 e segura)
                            for _, nuke in ipairs(nukeList) do
                                if not _G.ImaDeBomba then break end
                                
                                if nuke.Parent then -- Só interage se a bomba não foi destruída na fusão
                                    ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                                    task.wait(1.2) -- O tempo exato para o jogo fundir
                                    ReplicatedStorage.NukeRemotes.Drop:FireServer(meuPe)
                                    task.wait(0.1) -- Solta a nova bomba fundida
                                end
                            end
                        end
                    end
                    task.wait(0.5) -- Pausa antes de varrer o mapa de novo
                end
            end)
        end
    end
})