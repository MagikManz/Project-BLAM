--[[
    Filename: GUI.lua
    Author(s): MagikTheWizard
    Description: Player "system", for GUI.

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterService = require(ReplicatedStorage.Client.Character)

local Helpers = require(ReplicatedStorage.Shared.UIHelpers)

local LocalPlayer = Players.LocalPlayer
local State = require(script.Parent.State)

local PlayerGui

local GUI = { }

CharacterService:AddCallback("Health.UI", function(characterService)
    local humanoid = characterService:GetHumanoid()
    if humanoid == nil then return end

    local healthText: TextLabel = Helpers.WaitForTaggedObject("UI_CLIENT_HEALTH_TEXT", PlayerGui) :: TextLabel
    local healthBar: Frame = Helpers.WaitForTaggedObject("UI_CLIENT_HEALTH_BAR", PlayerGui) :: Frame

    local function onHealthChanged(playerHealth: number)
        local maxHealth = humanoid.MaxHealth

        local healthPercentage = playerHealth / maxHealth

        healthText.Text = tostring(playerHealth)

        healthBar:TweenSize(UDim2.fromScale(healthPercentage, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
    end

    humanoid.HealthChanged:Connect(onHealthChanged)
    onHealthChanged(humanoid.Health)
end)

State.Values.Stamina:connect("Sprint.UI", function(stamina: number)
    local staminaText: TextLabel = Helpers.WaitForTaggedObject("UI_CLIENT_STAMINA_TEXT", PlayerGui) :: TextLabel
    local staminaBar: Frame = Helpers.WaitForTaggedObject("UI_CLIENT_STAMINA_BAR", PlayerGui) :: Frame

    stamina = math.floor(stamina)
    
    staminaText.Text = tostring(stamina)

    staminaBar:TweenSize(UDim2.fromScale(stamina / 100, 1), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0, true)
end)

local __init = (function()
    PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    return nil
end)()

return GUI
