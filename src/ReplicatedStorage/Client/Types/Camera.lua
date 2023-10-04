export type CameraSettings = {
    CanZoomIn: boolean,
    RightClicking: boolean,

    CameraAngleX: number,
    CameraAngleY: number,

    CameraOffset: Vector3,
    CameraZoomInFactor: number
}

export type CameraMode = {
    Name: string,

    Settings: CameraSettings,

    UpdateOffset: (self: CameraMode, newOffset: Vector3) -> (),

    UpdateAngleX: (self: CameraMode, newAngle: number) -> (),
    UpdateAngleY: (self: CameraMode, newAngle: number) -> (),

    SetRightClick: (self: CameraMode, isClicking: boolean) -> (),

    GetSettings: (self: CameraMode) -> CameraSettings,

    ResetToDefault: (self: CameraMode) -> (),

    Scrolled: (self: CameraMode, direction: number) -> boolean,

    Stepped: (self: CameraMode, dt: number, characterCFrame: CFrame) -> CFrame,
}

return true