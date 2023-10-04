local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Client.Types.Camera)

local ZOOM_IN_TO_SWITCH = 4

local CAMERA_ANGLE_X = 0
local CAMERA_ANGLE_Y = 0

local CAMERA_OFFSET = Vector3.new(0, 1, -1.5)
local CAMERA_ZOOM_IN_FACTOR = 3

local Camera : Types.CameraMode = { 
    Name = "First Person",

    Settings = {
        CanZoomIn = false,
        RightClicking = false,

        CameraAngleX = CAMERA_ANGLE_X,
        CameraAngleY = CAMERA_ANGLE_Y,

        CameraOffset = CAMERA_OFFSET,
        CameraZoomInFactor = CAMERA_ZOOM_IN_FACTOR
    },

    UpdateOffset = function(_self: Types.CameraMode, _newOffset: Vector3) end,
    UpdateAngleX = function(_self: Types.CameraMode, _newAngle: number) end,
    UpdateAngleY = function(_self: Types.CameraMode, _newAngle: number) end,

    SetRightClick = function(_self: Types.CameraMode, _isClicking: boolean) end,

    GetSettings = function(_self: Types.CameraMode) return { CameraAngleX = 0, CameraAngleY = 0, CameraOffset = Vector3.zero, CameraZoomInFactor = 0, RightClicking = false, CanZoomIn = false } end,

    ResetToDefault = function(_self: Types.CameraMode) end,
    
    Scrolled = function(_self: Types.CameraMode, _direction: number) return true end,

    Stepped = function(_self: Types.CameraMode, _dt: number, _characterCFrame: CFrame) return CFrame.identity end
}

local zoomValue = 0

function Camera:UpdateOffset(newOffset: Vector3)
    self.Settings.CameraOffset = newOffset
end

function Camera:UpdateAngleX(newAngle: number)
    self.Settings.CameraAngleX = newAngle
end

function Camera:UpdateAngleY(newAngle: number)
    self.Settings.CameraAngleY = newAngle
end

function Camera:SetRightClick(_isClicking: boolean)

end

function Camera:GetSettings(): Types.CameraSettings
    return self.Settings
end

function Camera:ResetToDefault()
    self.Settings.CameraOffset = CAMERA_OFFSET
    self.Settings.CameraAngleX = CAMERA_ANGLE_X
    self.Settings.CameraAngleY = CAMERA_ANGLE_Y

    zoomValue = 0
end

function Camera:Scrolled(direction: number): boolean
    zoomValue = math.clamp(zoomValue - direction, 0, ZOOM_IN_TO_SWITCH)
    if zoomValue == ZOOM_IN_TO_SWITCH then
        zoomValue = 0
        return true
    end

    return false
end

function Camera:Stepped(_dt: number, characterCFrame: CFrame): CFrame
    return CFrame.new(characterCFrame.Position) * CFrame.new(self.Settings.CameraOffset)
end

return table.freeze(Camera) :: Types.CameraMode