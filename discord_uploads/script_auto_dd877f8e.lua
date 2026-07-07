--[[
    XUCRIA HUB - Central de Operações
    Modificado para: XUCRIA
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 XUCRIA HUB",
    LoadingTitle = "XUCRIA Hub",
    LoadingSubtitle = "by Xucria",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XucriaHubConfigs",
        FileName = "XucriaHub"
    },
    KeySystem = false,
    Theme = "Dark", -- Tema fixo para evitar erro de carregamento
    ToggleUIKeybind = Enum.KeyCode.RightAlt
})

-- Abas Principais
local Main = Window:CreateTab("⚔️ Principal", 4483362458)
local UniversalTab = Window:CreateTab("🌀 Universal", 4483362458)
local CreditsTab = Window:CreateTab("📜 Créditos", 4483362458)

-- Aba de Créditos Customizada
CreditsTab:CreateSection("🌟 XUCRIA HUB")
CreditsTab:CreateLabel("Desenvolvido para: Xucria")
CreditsTab:CreateLabel("Script by: Equipe Xucria")

-- Exemplo de onde você vai colocar sua função de caça futuramente
Main:CreateSection("🎯 ÁREA DE CAÇA")
Main:CreateButton({
    Name = "Ativar Caçador Xucria",
    Callback = function()
        Rayfield:Notify({Title = "Status", Content = "Caçador Iniciado!", Duration = 2})
        -- Aqui você poderá chamar a função de caçar que desenvolvemos
    end
})

Rayfield:Notify({
    Title = "Bem-vindo, Xucria!",
    Content = "A Hub está pronta para uso.",
    Duration = 5,
    Image = 4483362458,
})