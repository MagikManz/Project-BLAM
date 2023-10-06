local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Client.Types.Camera)

local ZOOM_IN_TO_SWITCH = 4

local CAMERA_ANGLE_X = 0
local CAMERA_ANGLE_Y = 0

local CAMERA_OFFSET = Vector3.new(0, 1, -1.5)

local Camera : Types.CameraMode = { 
    Name = "First Person",

    Settings = {
        CanFlipCamera = false,
        CanZoomIn = false,
        RightClicking = false,

        CameraAngleX = CAMERA_ANGLE_X,
        CameraAngleY = CAMERA_ANGLE_Y,

        CameraOffset = CAMERA_OFFSET,
        CameraZoomInFactor = Vector3.zero
    },

    GetOffset = function(_self) return Vector3.zero end,

    UpdateOffset = function(_self, _newOffset) end,
    UpdateAngleX = function(_self, _newAngle) end,
    UpdateAngleY = function(_self, _newAngle) end,

    SetRightClick = function(_self, _isClicking) end,

    GetSettings = function(_self) return { CameraAngleX = 0, CameraAngleY = 0, CameraOffset = Vector3.zero, CameraZoomInFactor = Vector3.zero, RightClicking = false, CanZoomIn = false, CanFlipCamera = false, } end,

    ResetToDefault = function(_self) end,
    
    Scrolled = function(_self, _direction) return true end,

    Stepped = function(_self, _dt, _characterCFrame) return CFrame.identity end
}

local zoomValue = 0

function Camera:GetOffset(): Vector3
    return self.Settings.CameraOffset
end

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