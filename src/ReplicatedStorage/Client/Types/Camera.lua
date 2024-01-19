export type CameraSettings = {
    CanFlipCamera: boolean,
    CanZoomIn: boolean,
    RightClicking: boolean,

    CameraAngleX: number,
    CameraAngleY: number,

    CameraOffset: Vector3,
    CameraZoomInFactor: Vector3
}

export type CameraMode = {
    Name: string,

    Settings: CameraSettings,

    GetOffset: (self: CameraMode) -> Vector3,
    
    UpdateOffset: (self: CameraMode, newOffset: Vector3) -> (),

    UpdateAngleX: (self: CameraMode, newAngle: number) -> (),
    UpdateAngleY: (self: CameraMode, newAngle: number) -> (),

    SetRightClick: (self: CameraMode, isClicking: boolean) -> (),

    GetSettings: (self: CameraMode) -> CameraSettings,

    ResetToDefault: (self: CameraMode) -> (),

    Scrolled: (self: CameraMode, direction: number) -> boolean,

    Stepped: (self: CameraMode, dt: number, characterCFrame: CFrame, angleX: CFrame, angleY: CFrame) -> CFrame,
}

return true