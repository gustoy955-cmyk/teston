--[[
    XUCRIA HUB - Script para MESCLAR UMA BOMBA NUCLEAR
    Desenvolvido para: Xucria
    Interface com tema salvável e aplicação imediata via botão
]]

local temas_disponiveis = {"Default", "Amethyst", "Ocean", "Serenity", "Mocha", "Sunset", "Midnight", "Dark", "Light"}

local function carregarTemaSalvo()
    local caminho = "XucriaHubConfigs/theme.txt"
    local sucesso, tema = pcall(function() return readfile(caminho) end)
    if sucesso and tema then
        tema = tema:gsub("%s+", "")
        for _, t in ipairs(temas_disponiveis) do if t:lower() == tema:lower() then return t end end
    end
    return "Default"
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerId = tonumber(LocalPlayer.UserId)
local GuiConnections = {}

local function ConstruirInterface(tema)
    for _, conn in ipairs(GuiConnections) do pcall(function() conn:Disconnect() end) end
    GuiConnections = {}

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
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

    local function GetPlayerBase()
        local BasesFolder = Workspace:FindFirstChild("Bases")
        if BasesFolder then
            for _, folder in ipairs(BasesFolder:GetChildren()) do
                local attributeValue = folder:GetAttribute("OwnerUserId")
                if attributeValue and tonumber(attributeValue) == PlayerId then return folder end
            end
        end
        return nil
    end

    local function TeleportTo(object)
        if not object or not LocalPlayer.Character then return end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local pos = object:IsA("Model") and object:GetPivot().Position or (object:IsA("BasePart") and object.Position)
        if root and pos then root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) end
    end

    -- [Funções Principais]
    Main:CreateSection("💣 FUNÇÕES DE GUERRA")
    Main:CreateButton({Name = "🧨 Interface de Guerra", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/SAMUCARARONOB/Inf/refs/heads/main/RANOXv2.lua"))() end})

    Main:CreateSection("🎯 ATAQUE A COORDENADA")
    Main:CreateButton({Name = "📍 Marcar Posição", Callback = function() _G.MarkedCoord = LocalPlayer.Character.HumanoidRootPart.Position end})
    Main:CreateToggle({Name = "🚀 Lançar Nuke na Coordenada", Callback = function(V) _G.LaunchAtCoord = V end})

    Main:CreateSection("⚡ FUSÃO & COLETA")
    Main:CreateToggle({Name = "🔗 Auto Fusão", Callback = function(V) _G.AutoMerge = V end})
    Main:CreateToggle({Name = "⚡ Auto Fusão Ultra", Callback = function(V) _G.AutoMergeUltra = V end})
    Main:CreateToggle({Name = "🎒 Auto Pegar Tudo", Callback = function(V) _G.AutoPickUp = V end})

    -- [Configurações / Universal / Créditos]
    UniversalTab:CreateSection("🏃 MOVIMENTO")
    UniversalTab:CreateToggle({Name = "🛸 Voar", Callback = function(V) shared.FlyEnabled = V end})
    UniversalTab:CreateToggle({Name = "👻 Noclip", Callback = function(V) shared.NoclipEnabled = V end})

    CreditsTab:CreateSection("🌟 CRÉDITOS XUCRIA")
    CreditsTab:CreateLabel("Proprietário: Xucria")
    CreditsTab:CreateLabel("Versão Otimizada para Você")
end

ConstruirInterface(carregarTemaSalvo())