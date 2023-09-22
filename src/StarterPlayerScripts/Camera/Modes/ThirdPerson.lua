local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Client.Types.Camera)

local CAMERA_ANGLE = 15
local CAMERA_OFFSET = Vector3.new(3, 5, 10)

local Camera : Types.CameraMode = { 
    Name = "Third Person",

    CameraAngle = CAMERA_ANGLE,
    CameraOffset = CAMERA_OFFSET,

    UpdateOffset = function(_self: Types.CameraMode, _newOffset: Vector3) end,
    UpdateAngle = function(_self: Types.CameraMode, _newAngle: number) end,

    ResetToDefault = function(_self: Types.CameraMode) end,
    
    Stepped = function(_self: Types.CameraMode, _dt: number, _characterCFrame: CFrame) return CFrame.identity end
}

function Camera:UpdateOffset(newOffset: Vector3)
    self.CameraOffset = newOffset
end

function Camera:UpdateAngle(newAngle: number)
    self.CameraAngle = newAngle
end

function Camera:ResetToDefault()
    self.CameraOffset = CAMERA_OFFSET
    self.CameraAngle = CAMERA_ANGLE
end

function Camera:Stepped(_dt: number, characterCFrame: CFrame): CFrame
    return CFrame.new(characterCFrame.Position) * CFrame.new(self.CameraOffset) * CFrame.fromAxisAngle(-Vector3.yAxis, math.rad(self.CameraAngle))
end

return table.freeze(Camera) :: Types.CameraMode