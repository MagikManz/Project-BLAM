--[[
    Filename: Camera.lua
    Author(s): MagikTheWizard
    Description: Camera system for "Project BLAM!"
--]]

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

type CameraController =  { 
    Enabled: boolean, 
    CurrentConnection: RBXScriptConnection?,
    RotationConnection: RBXScriptConnection?,

    Enable: (self: CameraController) -> ( ),
    Disable: (self: CameraController) -> ( )
}

local Inputs = require(script.Inputs)
local CameraTypes = require(ReplicatedStorage.Client.Types.Camera)

local CharacterService = require(ReplicatedStorage.Client.Character)

local KeysResolver = require(ReplicatedStorage.Client.Inputs.Resolver)

local CameraInputs = require(script.Inputs)

local Camera = workspace.CurrentCamera

local CustomCamera: CameraController = { 
    Enabled = false
} :: CameraController

local CameraModes = { }
do
    for _, mode in ipairs(script.Modes:GetChildren()) do
        CameraModes[mode.Name] = require(mode) :: CameraTypes.CameraMode
    end
end

local currentCameraMode = CameraModes.ThirdPerson
local lastRecordedCF = CFrame.identity

local pitch, yaw = 0, 0

local function spawnCustomCamera(): RBXScriptConnection
    currentCameraMode = CameraModes.ThirdPerson

    return RunService.PreRender:Connect(function(dt)
        if Camera.CameraType ~= Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
    
        local _humanoid, _root, character = CharacterService:GetCameraComponents()
        if character then
            lastRecordedCF = character:GetPivot() 
        end

        Camera.CFrame = currentCameraMode:Stepped(dt, lastRecordedCF, CFrame.Angles(0, yaw, 0), CFrame.Angles(pitch, 0, 0))

        if character and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            local lookVector = Vector3.new(Camera.CFrame.LookVector.X,0, Camera.CFrame.LookVector.Z)
            character:PivotTo(CFrame.new(lastRecordedCF.Position, lastRecordedCF.Position + lookVector))
        end
    end)
end

local function makeCharacterInvisible()
    local character = CharacterService:GetCharacter()
    if character == nil then return end

    for _, child in ipairs(character:GetDescendants()) do
        if child:FindFirstAncestorWhichIsA("Tool") or (child.Name:match("Hand") and child.Name ~= "Handle") or child.Name:match("Arm") then
            continue
        end

        if child:IsA("BasePart") then
            child.LocalTransparencyModifier = 1
        end
    end
end

local function makeCharacterVisible()
    local character = CharacterService:GetCharacter()
    if character == nil then return end

    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") then
            child.LocalTransparencyModifier = 0
        end            
    end
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

        if inputState == Enum.UserInputState.Begin then
            CameraInputs.InputBegan(resolvedInput, inputObject, false)
        elseif inputState == Enum.UserInputState.Change then
            local newMode = CameraInputs.InputChanged(resolvedInput, inputObject)
            if newMode ~= nil then
                currentCameraMode = newMode :: CameraTypes.CameraMode
                local viewModel = CharacterService:GetViewModel()
                if viewModel then
                    if currentCameraMode.Name == "First Person" then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                        makeCharacterInvisible()
                    else
                        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                        makeCharacterVisible()
                    end
                end
            end
        elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
            CameraInputs.InputEnded(resolvedInput, inputObject)
        end

        return Enum.ContextActionResult.Pass
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(CameraInputs.InputSettings.keysUsed))
end

function CustomCamera:Disable()
    self.Enabled = false

    if self.CurrentConnection then
        self.CurrentConnection:Disconnect()
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    self.CurrentConnection = nil

    ContextActionService:UnbindAction("CameraActions")

    Camera.CameraType = Enum.CameraType.Custom
end

local __init = (function()
    local mouseSensitivity = 1 / 600

    ContextActionService:BindActionAtPriority("CameraRotation",function(_actionName: string, inputState: Enum.UserInputState, inputObject: InputObject) 
        if inputState == Enum.UserInputState.Change then
            local mouseDelta = inputObject.Delta * mouseSensitivity

            pitch = math.clamp(pitch - mouseDelta.Y, -math.pi / 4, math.pi / 4)
            yaw = yaw - mouseDelta.X
        end

        return Enum.ContextActionResult.Pass
    end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseMovement)

    return nil
end)()

return CustomCamera
