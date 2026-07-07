-- [[ TESTE DE CAÇADOR (Modo Depuração) ]] --
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function DebugCaca()
    print("--- INICIANDO BUSCA ---")
    local CreatureCache = Workspace:FindFirstChild("RuntimeCache")
        and Workspace.RuntimeCache:FindFirstChild("RuntimeCacheServer")
        and Workspace.RuntimeCache.RuntimeCacheServer:FindFirstChild("CreatureModelCache")

    if not CreatureCache then
        print("❌ Erro: Não encontrei a pasta CreatureModelCache!")
        return
    end

    local encontrado = false
    for _, subPasta in ipairs(CreatureCache:GetChildren()) do
        for _, pet in ipairs(subPasta:GetChildren()) do
            -- Imprime o nome de TUDO que ele está vendo nas pastas
            print("👁️ Vi: " .. pet.Name)
            
            if pet.Name:find("Pet0") then -- Tenta achar qualquer bicho que comece com Pet0
                local part = pet:FindFirstChild("Collision") or pet.PrimaryPart
                if part then
                    print("✅ ALVO ENCONTRADO: " .. pet.Name .. " a " .. (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude .. " metros")
                    LocalPlayer.Character.Humanoid:MoveTo(part.Position)
                    encontrado = true
                    break
                end
            end
        end
        if encontrado then break end
    end
    
    if not encontrado then print("❌ Nenhum bicho encontrado nesta varredura.") end
end

-- Roda a busca a cada 2 segundos
task.spawn(function()
    while task.wait(2) do
        DebugCaca()
    end
end)