--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local InputType = require(ReplicatedStorage.Client.Types.Inputs)

local CameraInputs: InputType.InputSystem = { 
    InputSettings = { 
        keysUsed = { 
            Enum.KeyCode.Q, Enum.KeyCode.DPadLeft, Enum.KeyCode.ButtonL2, Enum.UserInputType.MouseButton2, 
            Enum.UserInputType.MouseButton3, Enum.KeyCode.Thumbstick2, Enum.UserInputType.MouseWheel, 
            Enum.KeyCode.ButtonR3, Enum.KeyCode.ButtonY
        }
    }
} :: InputType.InputSystem

function CameraInputs.InputBegan(resolvedInput: InputType.ResolvedInput, _input: InputObject, processed: boolean)
    if processed then return end

    local currentCameraMode = CameraInputs.InputSettings.currentCameraMode
    if currentCameraMode == nil then return end

    local cameraSettings = currentCameraMode:GetSettings()

    if resolvedInput == Enum.UserInputType.MouseButton2 and cameraSettings.CanZoomIn == true then
        local zoomInFactor = cameraSettings.CameraZoomInFactor

        currentCameraMode:UpdateOffset(zoomInFactor)

        currentCameraMode:SetRightClick(true)

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    elseif resolvedInput == Enum.KeyCode.Q and cameraSettings.CanFlipCamera == true then
        currentCameraMode:UpdateOffset(currentCameraMode:GetOffset() * Vector3.new(-1, 1, 1))
    end
end

function CameraInputs.InputChanged(resolvedInput: InputType.ResolvedInput, input: InputObject)
    if resolvedInput ~= Enum.UserInputType.MouseWheel then return end

    local currentCameraMode = CameraInputs.InputSettings.currentCameraMode
    if currentCameraMode == nil then return end

    local CameraModes = CameraInputs.InputSettings.cameraModes
    if CameraModes == nil then return end

    if input.KeyCode == Enum.KeyCode.Thumbstick2 then
        if UserInputService:IsKeyDown(Enum.KeyCode.ButtonR3) == false then
            return
        end
    end

    if not currentCameraMode:Scrolled(input.Position.Z) then return end

    currentCameraMode:ResetToDefault()

    if currentCameraMode.Name == "Third Person" then
        CameraInputs.InputSettings.currentCameraMode = CameraModes.FirstPerson
    else
        CameraInputs.InputSettings.currentCameraMode = CameraModes.ThirdPerson
    end

    CameraInputs.InputSettings.currentCameraMode:ResetToDefault()

    return CameraInputs.InputSettings.currentCameraMode
end

function CameraInputs.InputEnded(resolvedInput: InputType.ResolvedInput, _input: InputObject)
    if resolvedInput ~= Enum.UserInputType.MouseButton2 and resolvedInput ~= Enum.KeyCode.ButtonY then return end

    local currentCameraMode = CameraInputs.InputSettings.currentCameraMode
    if currentCameraMode == nil then return end

    local cameraSettings = currentCameraMode:GetSettings()
    if cameraSettings.CanZoomIn == false or cameraSettings.RightClicking == false then return end

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    currentCameraMode:UpdateOffset(cameraSettings.CameraOffset)

    currentCameraMode:SetRightClick(false)
end

return table.freeze(CameraInputs) :: InputType.InputSystem
