local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- COLOQUE O NOME DO PET QUE VOCÊ QUER AQUI:
local PetDesejado = "Pet0_66" 
-- ==========================================

local function CacarPet()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end

    -- Navegando exatamente pelo caminho que o seu scanner descobriu!
    local RuntimeCache = Workspace:FindFirstChild("RuntimeCache")
    if not RuntimeCache then return end
    
    local ServerCache = RuntimeCache:FindFirstChild("RuntimeCacheServer")
    if not ServerCache then return end
    
    local CreatureCache = ServerCache:FindFirstChild("CreatureModelCache")
    if not CreatureCache then return end

    -- Procura dentro das pastas numeradas (ex: 1294, 1297)
    local petEncontrado = false
    
    for _, pastaID in ipairs(CreatureCache:GetChildren()) do
        local pet = pastaID:FindFirstChild(PetDesejado)
        
        if pet then
            -- Acha a parte central do corpo do pet para o personagem ir até lá
            local alvoPos = nil
            if pet.PrimaryPart then
                alvoPos = pet.PrimaryPart.Position
            elseif pet:FindFirstChild("HumanoidRootPart") then
                alvoPos = pet.HumanoidRootPart.Position
            end

            if alvoPos then
                -- Manda o seu personagem andar até a coordenada do Pet
                hum:MoveTo(alvoPos)
                petEncontrado = true
                -- print("🐾 Indo caçar o " .. PetDesejado)
                break -- Para de procurar e vai no primeiro que achou
            end
        end
    end
    
    if not petEncontrado then
        -- print("Pet não está no mapa no momento.")
    end
end

-- Cria um loop infinito que manda o personagem andar a cada 1 segundo
_G.Cacando = true
task.spawn(function()
    while _G.Cacando do
        CacarPet()
        task.wait(1)
    end
end)

-- Para parar o script depois, você pode rodar outro script apenas com: _G.Cacando = false