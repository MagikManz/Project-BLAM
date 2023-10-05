--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local InputType = require(ReplicatedStorage.Client.Types.Inputs)

local CameraInputs: InputType.InputSystem = { 
    InputSettings = { 
        currentCameraMode = nil,
        cameraModes = nil,
        keysUsed = { 
            Enum.KeyCode.Q, Enum.KeyCode.DPadLeft, Enum.KeyCode.ButtonL2, Enum.UserInputType.MouseButton2, 
            Enum.UserInputType.MouseButton3, Enum.KeyCode.Thumbstick2, Enum.UserInputType.MouseWheel, 
            Enum.KeyCode.ButtonR3
        }
    },

    InputBegan = function() end,
    InputChanged = function() return nil end,
    InputEnded = function() end
}


function CameraInputs.InputBegan(resolvedInput: InputType.ResolvedInput, _input: InputObject, processed: boolean)
    if processed then return end

    local currentCameraMode = CameraInputs.InputSettings.currentCameraMode
    if currentCameraMode == nil then return end

    print("hey??? resolved??!", resolvedInput.Name)

    if resolvedInput == Enum.UserInputType.MouseButton2 then
        local cameraSettings = currentCameraMode:GetSettings()
        if cameraSettings.CanZoomIn == false then return end

        local zoomInFactor = cameraSettings.CameraZoomInFactor

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        currentCameraMode:UpdateOffset(cameraSettings.CameraOffset - Vector3.zAxis * zoomInFactor)

        currentCameraMode:SetRightClick(true)

    elseif resolvedInput == Enum.KeyCode.Q then
        local cameraOffset = currentCameraMode:GetSettings().CameraOffset
        currentCameraMode:UpdateOffset(cameraOffset * Vector3.new(-1, 1, 1))
    end
end

function CameraInputs.InputChanged(resolvedInput: InputType.ResolvedInput, input: InputObject)
    if resolvedInput ~= Enum.UserInputType.MouseWheel then return end

    print("hey??? resolved??!", resolvedInput.Name)

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
    if resolvedInput ~= Enum.UserInputType.MouseButton2 or resolvedInput ~= Enum.KeyCode.ButtonY then return end

    print("hey??? resolved??!", resolvedInput.Name)

    local currentCameraMode = CameraInputs.InputSettings.currentCameraMode
    if currentCameraMode == nil then return end

    local cameraSettings = currentCameraMode:GetSettings()
    if cameraSettings.CanZoomIn == false or cameraSettings.RightClicking == false then return end

    local zoomInFactor = cameraSettings.CameraZoomInFactor

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    currentCameraMode:UpdateOffset(cameraSettings.CameraOffset + Vector3.zAxis * zoomInFactor)

    currentCameraMode:SetRightClick(false)
end

return table.freeze(CameraInputs) :: InputType.InputSystem
