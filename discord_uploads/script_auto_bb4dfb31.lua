-- [[ AUTO CAÇADOR V5.1 (Focado em Subpastas do Servidor) ]] --

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.Cacando = false

-- [[ LÓGICA REVISADA: Busca em subpastas numeradas ]] --
local function GetClosestPet(petName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    -- Caminho exato identificado no seu log
    local CreatureCache = Workspace:FindFirstChild("RuntimeCache")
        and Workspace.RuntimeCache:FindFirstChild("RuntimeCacheServer")
        and Workspace.RuntimeCache.RuntimeCacheServer:FindFirstChild("CreatureModelCache")

    if not CreatureCache then return nil, nil end

    local closestPetPart = nil
    local nomeAlvoEncontrado = ""
    local shortestDistance = math.huge 

    -- Varrer todas as pastas numeradas (ex: 1312, 1236...)
    for _, subPasta in ipairs(CreatureCache:GetChildren()) do
        for _, pet in ipairs(subPasta:GetChildren()) do
            
            -- Filtro de nome (Ignora maiúsculas/minúsculas)
            if petName ~= "" and string.lower(pet.Name) ~= string.lower(petName) then
                continue
            end
            
            -- Ignora jogadores (pelo log, eles aparecem como o nome do usuário)
            if Players:FindFirstChild(pet.Name) then continue end
            
            -- Procura qualquer parte física para ser o alvo
            local targetPart = pet:FindFirstChild("Collision") 
                or pet.PrimaryPart 
                or pet:FindFirstChildWhichIsA("BasePart")
            
            if targetPart then
                local distance = (root.Position - targetPart.Position).Magnitude
                
                if distance < shortestDistance and distance < 200 then
                    shortestDistance = distance
                    closestPetPart = targetPart
                    nomeAlvoEncontrado = pet.Name
                end
            end
        end
    end
    
    return closestPetPart, nomeAlvoEncontrado
end

-- [[ LOOP DE MOVIMENTAÇÃO (Idêntico ao anterior) ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Cacando then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local alvoPart, alvoNome = GetClosestPet(NomeInput.Text) -- NomeInput deve vir da sua UI
                if alvoPart then
                    hum:MoveTo(alvoPart.Position)
                end
            end
        end
    end
end)