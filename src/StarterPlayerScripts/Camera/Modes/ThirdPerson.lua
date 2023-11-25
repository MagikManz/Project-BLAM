local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Springs = require(ReplicatedStorage.Client.Spring)

local Types = require(ReplicatedStorage.Client.Types.Camera)

local ZOOM_IN_TO_SWITCH = 4

local CAMERA_ANGLE_X = 12
local CAMERA_ANGLE_Y = 12

local CAMERA_OFFSET = Vector3.new(3, 5, 10)
local CAMERA_OFFSET_ZOOM = CAMERA_OFFSET - Vector3.zAxis * 3

local offsetSpring = Springs.new(CAMERA_OFFSET, 15, 0.9)
local angleSpring = Springs.new(CAMERA_ANGLE_X, 15, 0.9)

local Camera: Types.CameraMode = { 
    Name = "Third Person",

    Settings = {
        CanFlipCamera = true,
        CanZoomIn = true,
        RightClicking = false,

        CameraAngleX = CAMERA_ANGLE_X,
        CameraAngleY = CAMERA_ANGLE_Y,

        CameraOffset = CAMERA_OFFSET,
        CameraZoomInFactor = CAMERA_OFFSET_ZOOM
    }
} :: Types.CameraMode

local zoomValue = 0
local cameraOffset = CAMERA_OFFSET
local cameraAngleX = CAMERA_ANGLE_X

function Camera:GetOffset(): Vector3
    return offsetSpring:GetGoal() or cameraOffset
end

function Camera:UpdateOffset(newOffset: Vector3)
    offsetSpring:SetGoal(newOffset)

    if offsetSpring:Playing() == false then
        offsetSpring:Run(nil, function(value)
            cameraOffset = value
        end)
    end
end

function Camera:UpdateAngleX(newAngle: number)
    angleSpring:SetGoal(newAngle)

    if angleSpring:Playing() == false then
        angleSpring:Run(nil, function(value)
            cameraAngleX = value
        end)
    end
end

function Camera:UpdateAngleY(newAngle: number)
    self.Settings.CameraAngleY = newAngle
end

function Camera:SetRightClick(isClicking: boolean)
    self.Settings.RightClicking = isClicking
end

function Camera:GetSettings(): Types.CameraSettings
    return self.Settings
end

function Camera:ResetToDefault()
    self.Settings.CameraOffset = CAMERA_OFFSET
    self.Settings.CameraAngleX = CAMERA_ANGLE_X
    self.Settings.CameraAngleY = CAMERA_ANGLE_Y

    self.Settings.RightClicking = false

    zoomValue = 0

    cameraOffset = CAMERA_OFFSET
    cameraAngleX = CAMERA_ANGLE_X
end

function Camera:Scrolled(direction: number): boolean
    zoomValue = math.clamp(zoomValue + direction, 0, ZOOM_IN_TO_SWITCH)
    if zoomValue == ZOOM_IN_TO_SWITCH then
        zoomValue = 0
        return true
    end

    return false
end

function Camera:Stepped(_dt: number, characterCFrame: CFrame): CFrame
    return CFrame.new(characterCFrame.Position) * CFrame.new(cameraOffset) * CFrame.fromAxisAngle(-Vector3.xAxis, math.rad(cameraAngleX))
end

return table.freeze(Camera) :: Types.CameraMode