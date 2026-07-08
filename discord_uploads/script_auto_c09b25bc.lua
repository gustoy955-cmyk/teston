-- [[ XUCRIA HUB: AUTO-MESCLAR BOMBAS V1 ]] --
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Encontra a base do jogador pelo ID
local function GetPlayerBase()
    local BasesFolder = Workspace:FindFirstChild("Bases")
    if BasesFolder then
        for _, folder in ipairs(BasesFolder:GetChildren()) do
            if folder:GetAttribute("OwnerUserId") == PlayerId then return folder end
        end
    end
    return nil
end

-- Lógica de Fusão
_G.AutoMerge = false
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoMerge then
            local myBase = GetPlayerBase()
            if myBase and myBase:FindFirstChild("Nukes") then
                local nukesByType = {}
                
                -- Agrupa bombas pelo "tipo" (provavelmente pelo texto na label)
                for _, nuke in ipairs(myBase.Nukes:GetChildren()) do
                    if nuke.Name == "Nuke" and nuke:FindFirstChild("OverheadNuke") then
                        local label = nuke.OverheadNuke:FindFirstChild("TextLabel")
                        if label then
                            local nukeType = label.Text
                            nukesByType[nukeType] = nukesByType[nukeType] or {}
                            table.insert(nukesByType[nukeType], nuke)
                        end
                    end
                end

                -- Se achar duas iguais, mescla
                for _, group in pairs(nukesByType) do
                    if #group >= 2 then
                        -- Pega a primeira e mescla na segunda
                        ReplicatedStorage.NukeRemotes.PickUp:FireServer(group[1])
                        task.wait(0.1)
                        ReplicatedStorage.NukeRemotes.MergeRequest:FireServer(group[2])
                        break -- Faz uma por uma para não dar erro
                    end
                end
            end
        end
    end
end)