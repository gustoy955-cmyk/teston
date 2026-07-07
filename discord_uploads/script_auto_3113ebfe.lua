-- [[ TESTE DE VIDA - OMNI SCANNER ]] --
print("Omni Scanner V6: Script Executado com Sucesso!")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer then
    print("Jogador detectado: " .. LocalPlayer.Name)
else
    print("Erro: LocalPlayer não encontrado!")
end

local Workspace = game:GetService("Workspace")
print("Workspace detectado. Numero de filhos: " .. #Workspace:GetChildren())

-- Teste de busca simples
local contador = 0
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("Model") then
        contador = contador + 1
    end
end
print("Total de modelos encontrados no mapa: " .. contador)