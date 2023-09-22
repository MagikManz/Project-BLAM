export type CameraMode = {
    Name: string,

    CameraAngle: number,
    CameraOffset: Vector3,

    UpdateOffset: (self: CameraMode, newOffset: Vector3) -> (),
    UpdateAngle: (self: CameraMode, newAngle: number) -> (),

    ResetToDefault: (self: CameraMode) -> (),

    Stepped: (self: CameraMode, dt: number, characterCFrame: CFrame) -> CFrame,
}

return true