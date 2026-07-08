--[[
    XUCRIA HUB - FORJA TELEPORTADA (Método Blindado)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)

-- Acha a base
local function GetPlayerBase()
    local BasesFolder = Workspace:FindFirstChild("Bases")
    if BasesFolder then
        for _, folder in ipairs(BasesFolder:GetChildren()) do
            if folder:GetAttribute("OwnerUserId") == PlayerId then return folder end
        end
    end
    return nil
end

-- Teleporta o boneco com segurança
local function TeleportTo(object)
    if not object or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = object:GetPivot() + Vector3.new(0, 2, 0)
    end
end

-- LÓGICA DE FUSÃO TELEPORTADA
_G.AutoForjaTele = false
task.spawn(function()
    while task.wait(1) do
        if _G.AutoForjaTele then
            local myBase = GetPlayerBase()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myBase and root then
                local centro = root.CFrame
                local nukes = myBase:FindFirstChild("Nukes")
                
                if nukes then
                    for _, nuke in ipairs(nukes:GetChildren()) do
                        if nuke.Name == "Nuke" and nuke.Parent then
                            -- Teleporta até a bomba
                            TeleportTo(nuke)
                            task.wait(0.2)
                            
                            -- Pega a bomba
                            ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                            task.wait(0.2)
                            
                            -- Volta pro centro
                            root.CFrame = centro
                            task.wait(0.2)
                            
                            -- Solta
                            ReplicatedStorage.NukeRemotes.Drop:FireServer(centro)
                            task.wait(1.2) -- Tempo de fusão
                        end
                    end
                end
            end
        end
    end
end)