--[[
    Filename: Camera.lua
    Author(s): MagikTheWizard
    Description: Camera system for "Project BLAM!"
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CameraTypes = require(ReplicatedStorage.Client.Types.Camera)

local CharacterService = require(ReplicatedStorage.Client.Character)

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
    
        Camera.CFrame = Camera.CFrame:Lerp(currentCameraMode:Stepped(dt, if character then character:GetPivot() else lastRecordedCF), 1 / 3)
    end)    
end

function CustomCamera:Enable()
    if self.CurrentConnection then
        self.CurrentConnection:Disconnect()
    end

    self.Enabled = true
    self.CurrentConnection = spawnCustomCamera()
end

function CustomCamera:Disable()
    self.Enabled = false

    (self.CurrentConnection :: RBXScriptConnection):Disconnect()
    self.CurrentConnection = nil
end

-- will get removed and moved to its own module soon (just for testing)
UserInputService.InputBegan:Connect(function(input, proce)
    if proce then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        local cameraSettings = currentCameraMode:GetSettings()
        if cameraSettings.CanZoomIn == false then return end

        local zoomInFactor = cameraSettings.CameraZoomInFactor

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        currentCameraMode:UpdateOffset(cameraSettings.CameraOffset - Vector3.zAxis * zoomInFactor)

        currentCameraMode:SetRightClick(true)

        return
    end

    if input.KeyCode ~= Enum.KeyCode.Q then
        return
    end

    local cameraOffset = currentCameraMode:GetSettings().CameraOffset

    currentCameraMode:UpdateOffset(cameraOffset * Vector3.new(-1, 1, 1))
end)

UserInputService.InputChanged:Connect(function(input: InputObject)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if currentCameraMode:Scrolled(input.Position.Z) then
            currentCameraMode:ResetToDefault()

            if currentCameraMode.Name == "Third Person" then
                currentCameraMode = CameraModes.FirstPerson
            else
                currentCameraMode = CameraModes.ThirdPerson
            end

            currentCameraMode:ResetToDefault()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        local cameraSettings = currentCameraMode:GetSettings()
        if cameraSettings.CanZoomIn == false or cameraSettings.RightClicking == false then return end

        local zoomInFactor = cameraSettings.CameraZoomInFactor

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        currentCameraMode:UpdateOffset(cameraSettings.CameraOffset + Vector3.zAxis * zoomInFactor)

        currentCameraMode:SetRightClick(false)
    end
end)

return CustomCamera
