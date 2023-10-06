--[[
    Filename: Camera.lua
    Author(s): MagikTheWizard
    Description: Camera system for "Project BLAM!"
--]]

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Inputs = require(script.Inputs)
local CameraTypes = require(ReplicatedStorage.Client.Types.Camera)

local CharacterService = require(ReplicatedStorage.Client.Character)

local KeysResolver = require(ReplicatedStorage.Client.Inputs.Resolver)

local CameraInputs = require(script.Inputs)

local Camera = workspace.CurrentCamera

local CustomCamera = { 
    Enabled = false,
    CurrentConnection = nil,
}

local CameraModes = { }
do
    for _, mode in ipairs(script.Modes:GetChildren()) do
        CameraModes[mode.Name] = require(mode) :: CameraTypes.CameraMode
    end
end

local currentCameraMode = CameraModes.ThirdPerson
local lastRecordedCF = CFrame.identity

local function spawnCustomCamera()    
    currentCameraMode = CameraModes.ThirdPerson

    return RunService.PreRender:Connect(function(dt)
        if Camera.CameraType ~= Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
    
        local _humanoid, _root, character = CharacterService:GetCameraComponents()
        if character then
            lastRecordedCF = character:GetPivot() 
        end
    
        Camera.CFrame = currentCameraMode:Stepped(dt, if character then character:GetPivot() else lastRecordedCF)
    end)
end

function CustomCamera:Enable()
    if self.CurrentConnection then
        self.CurrentConnection:Disconnect()
    end

    self.Enabled = true
    self.CurrentConnection = spawnCustomCamera()
    
    Inputs.InputSettings.currentCameraMode = currentCameraMode
    Inputs.InputSettings.cameraModes = CameraModes
    
    ContextActionService:BindActionAtPriority("CameraActions",function(_actionName: string, inputState: Enum.UserInputState, inputObject: InputObject) 
        local resolvedInput = KeysResolver(inputObject)
        if resolvedInput == nil then
            return Enum.ContextActionResult.Pass
        end

        print("hey??? resolved??!", resolvedInput.Name)

        if inputState == Enum.UserInputState.Begin then
            CameraInputs.InputBegan(resolvedInput, inputObject, false)
        elseif inputState == Enum.UserInputState.Change then
            local newMode = CameraInputs.InputChanged(resolvedInput, inputObject)
            if newMode ~= nil then
                currentCameraMode = newMode :: CameraTypes.CameraMode
            end
        elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
            CameraInputs.InputEnded(resolvedInput, inputObject)
        end

        return Enum.ContextActionResult.Pass
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(CameraInputs.InputSettings.keysUsed))
end

function CustomCamera:Disable()
    self.Enabled = false

    (self.CurrentConnection :: RBXScriptConnection):Disconnect()
    self.CurrentConnection = nil

    ContextActionService:UnbindAction("CameraActions")
end

return CustomCamera
