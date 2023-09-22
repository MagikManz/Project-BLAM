--[[
    Filename: Camera.lua
    Author(s): MagikTheWizard
    Description: Camera system for "Project BLAM!"
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CameraTypes = require(ReplicatedStorage.Client.Types.Camera)

local CharacterService = require(ReplicatedStorage.Client.Character)

local Camera = workspace.CurrentCamera

local CameraModes = { }
do
    for _, mode in ipairs(script.Modes:GetChildren()) do
        CameraModes[mode.Name] = require(mode) :: CameraTypes.CameraMode
    end
end

local currentCameraMode = CameraModes.ThirdPerson
local lastRecordedCF = CFrame.identity

RunService.PreRender:Connect(function(dt)
    if Camera.CameraType ~= Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Scriptable
    end

    local _humanoid, _root, character = CharacterService:GetCameraComponents()
    if character then
        lastRecordedCF = character:GetPivot() 
    end

    

    Camera.CFrame = currentCameraMode:Stepped(dt, if character then character:GetPivot() else lastRecordedCF)
end)
