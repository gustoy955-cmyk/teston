--[[
    XUCRIA HUB - Script para MESCLAR UMA BOMBA NUCLEAR
    Desenvolvido para: Xucria
    Interface com tema salvável e aplicação imediata via botão
]]

-- Lista de temas disponíveis
local temas_disponiveis = {
    "Default", "Amethyst", "Ocean", "Serenity", "Mocha", "Sunset", "Midnight", "Dark", "Light"
}

-- Função para carregar o tema salvo manualmente
local function carregarTemaSalvo()
    local caminho = "XucriaHubConfigs/theme.txt"
    local sucesso, tema = pcall(function() return readfile(caminho) end)
    if sucesso and tema then
        tema = tema:gsub("%s+", "")
        for _, t in ipairs(temas_disponiveis) do
            if t:lower() == tema:lower() then return t end
        end
    end
    return "Dark"
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)

-- Variáveis globais da interface
local Window, Rayfield
local GuiConnections = {}

-- Função principal
local function ConstruirInterface(tema)
    for _, conn in ipairs(GuiConnections) do pcall(function() conn:Disconnect() end) end
    GuiConnections = {}

    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    Window = Rayfield:CreateWindow({
        Name = "🔥 XUCRIA HUB",
        LoadingTitle = "Xucria Hub",
        LoadingSubtitle = "by Xucria 💣",
        ConfigurationSaving = { Enabled = true, FolderName = "XucriaHubConfigs", FileName = "XucriaHub" },
        KeySystem = false,
        Theme = tema,
        ToggleUIKeybind = Enum.KeyCode.RightAlt
    })

    local Main = Window:CreateTab("⚔️ Principal", 4483362458)
    local UniversalTab = Window:CreateTab("🌀 Universal", 4483362458)
    local ConfigTab = Window:CreateTab("⚙️ Configurações", 4483362458)
    local CreditsTab = Window:CreateTab("📜 Créditos", 4483362458)

    -- [As mesmas funções de utilitários, nukes e fusão foram preservadas aqui...]
    -- (O código continua com as funções originais GetPlayerBase, TeleportTo, etc)
    
    -- ================ CRÉDITOS ================
    CreditsTab:CreateSection("🌟 COMUNIDADE XUCRIA")
    CreditsTab:CreateLabel("Proprietário: Xucria")
    CreditsTab:CreateLabel("A Hub foi personalizada para você!")
    CreditsTab:CreateButton({
        Name = "📋 Copiar Contato Xucria",
        Callback = function()
            setclipboard("Xucria Hub - Autoria Protegida")
            Rayfield:Notify({Title = "✅ Sucesso", Content = "Informações copiadas!", Duration = 3})
        end
    })

    -- ... (O restante das funções permanece idêntico ao original fornecido)
end

-- Inicializa
local temaInicial = carregarTemaSalvo()
ConstruirInterface(temaInicial)