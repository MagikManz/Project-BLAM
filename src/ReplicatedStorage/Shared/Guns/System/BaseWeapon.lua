local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local GunStatTypes = require(ReplicatedStorage.Shared.Guns.Type)

local Projectile = require(ReplicatedStorage.Client.Projectile)

type Animations = {
    Equip: AnimationTrack,
    Rest: AnimationTrack,
    Hip: AnimationTrack,
    HipFire: AnimationTrack,
    Aim: AnimationTrack,
    AimFire: AnimationTrack,
    Empty: AnimationTrack,
    ReloadTactical: AnimationTrack,
    ReloadEmpty: AnimationTrack,

    -- For the pump
    AimPump: AnimationTrack?,
    HipPump: AnimationTrack?,
    Reload: AnimationTrack?,
    ReloadStartTactical: AnimationTrack?,
    ReloadStartEmpty: AnimationTrack?,
    ReloadEnd: AnimationTrack?
}

type PublicWeapon = {
    WeaponName: string,

    Magazine: {
        MagazineSize: number,
        SpareMagazines: number,
        AmmoPerShot: number
    },

    Ammo: number,
    Magazines: number,

    FireModes: {
        "Auto" | "Semi" | "Burst"
    },

    FireMode: number,

    FireRate: number,
    LastShot: number,

    BarrelOffset: CFrame,

    Shooting: boolean,
    Reloading: boolean,
    Equipped: boolean,
    Aiming: boolean,

    Animations: Animations
}

type BaseWeapon = {
    __index: BaseWeapon,

    new: (weaponName: string, weaponStats: GunStatTypes.GunStats ) -> Weapon,

    Shoot: (self: Weapon) -> nil,
    Reload: (self: Weapon) -> nil,
    CancelReload: (self: Weapon) -> nil,
    Equip: (self: Weapon) -> nil,
    Unequip: (self: Weapon) -> nil,
    SwitchMode: (self: Weapon) -> nil,

    ADS: (self: Weapon, sightDown: boolean) -> nil,
}

export type Weapon = typeof(setmetatable({} :: PublicWeapon, {} :: BaseWeapon))

local BaseWeapon: BaseWeapon = { } :: BaseWeapon
BaseWeapon.__index = BaseWeapon

local camera = workspace.CurrentCamera

function BaseWeapon.new(weaponName: string, wepaonStats: GunStatTypes.GunStats): Weapon
    local weapon: PublicWeapon = {
        WeaponName = weaponName,

        Magazine = table.clone(wepaonStats.Magazine),

        Ammo = wepaonStats.Magazine.MagazineSize,
        Magazines = wepaonStats.Magazine.SpareMagazines,

        FireRate = wepaonStats.FireRate,
        FireModes = table.clone(wepaonStats.FireModes),

        FireMode = 1,
        LastShot = 0,

        BarrelOffset = wepaonStats.BarrelOffset,

        Shooting = false,
        Reloading = false,
        Equipped = false,
        Aiming = false
    } :: PublicWeapon

    return setmetatable(weapon, BaseWeapon) :: Weapon
end

local function getOriginAndDirection(): (Vector3, Vector3)
    local mouseLocation = UserInputService:GetMouseLocation()
    
    local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true   

    return ray.Origin, ray.Direction
end

local function getInaccurateDirection(direction: Vector3, spread: number, shotIdx: number): Vector3
    local random = Random.new(tick() + shotIdx)
    local spreadX = random:NextNumber(-spread, spread)
    local spreadY = random:NextNumber(-spread, spread)

    local spreadDirection = Vector3.new(spreadX, spreadY, 0)

    return direction + spreadDirection
end

local function shoot(weapon: Weapon, shots: number): boolean
    if weapon.Ammo <= 0 then
        -- play empty sound
        return false
    end

    if weapon.Reloading or weapon.Shooting == false or weapon.Equipped == false then
        return false
    end

    local currentFireMode = weapon.FireModes[weapon.FireMode]

    if weapon.Aiming then
        weapon.Animations.AimFire:Play()
    else
        weapon.Animations.HipFire:Play()
        weapon.Animations.Hip:Play()
    end

    weapon.Ammo -= weapon.Magazine.AmmoPerShot

    local _origin, direction = getOriginAndDirection()
    for i = 1, weapon.Magazine.AmmoPerShot do
        local newDirection = getInaccurateDirection(direction, 1 / 10, i)
        
        local projectileData: Projectile.Projectile = {
            Origin = weapon.BarrelOffset.Position + newDirection,
            Direction = newDirection,
    
            Acceleration = newDirection * 25_000,
    
            MaxDistance = 5000,
    
            MassMultiplier = 1,
            CurrentPosition = Vector3.zero,
    
            Owner = Players.LocalPlayer
        } :: Projectile.Projectile

        Projectile.new(projectileData)
    end

    return (currentFireMode == "Auto" or currentFireMode == "Burst" and shots < 3)
end

function BaseWeapon:Shoot()
    if self.Ammo <= 0 or os.time() < self.LastShot then
        -- play empty sound
        return
    end

    if self.Reloading or self.Shooting or self.Equipped == false then
        return
    end

    self.LastShot = os.time() + self.FireRate

    self.Shooting = true

    local shots = 1
    while shoot(self, shots) do
        shots += 1
        task.wait(self.FireRate)
    end

    self.Shooting = false

    if self.Animations.HipFire.IsPlaying then
        local currentLastShot = self.LastShot

        task.delay(self.Animations.HipFire.Length + self.FireRate + 0.5, function()
            if self.Shooting or self.LastShot ~= currentLastShot then return end

            self.Animations.Hip:Stop()
        end)
    end

    return nil
end

function BaseWeapon:Reload()
    local selectedStartTrack: AnimationTrack = nil
    if self.Equipped == false or self.Ammo == self.Magazine.MagazineSize then
        return
    elseif self.Ammo <= 0 then
        selectedStartTrack = self.Animations.ReloadStartEmpty or self.Animations.ReloadEmpty
    else
        selectedStartTrack = self.Animations.ReloadStartTactical or self.Animations.ReloadTactical
    end

    selectedStartTrack:Play()
    task.wait(selectedStartTrack.Length)

    self.Reloading = true

    if self.Animations.Reload then
        local reloadedShots = self.Magazine.AmmoPerShot

        while reloadedShots < self.Magazine.MagazineSize do
            reloadedShots +=  self.Magazine.AmmoPerShot

            self.Animations.Reload:Play()

            task.wait(self.Animations.Reload.Length)
        end
    end

    if self.Reloading == false then
        -- reload was interrupted.
        return
    end

    if self.Animations.ReloadEnd then
        self.Animations.ReloadEnd:Play()
    end

    self.Ammo = self.Magazine.MagazineSize
    self.Magazines -= 1

    self.Reloading = false

    return nil
end

function BaseWeapon:CancelReload()
    if self.Reloading == false then
        return
    end

    -- stop reload animation

    self.Reloading = false

    return nil
end

function BaseWeapon:Equip()
    self.Equipped = true

    self.Animations.Equip:Play()
    task.delay(self.Animations.Equip.Length, function()
        if self.Equipped == false then return end

        self.Animations.Rest:Play()
    end)

    return nil
end

function BaseWeapon:Unequip()
    self.Equipped = false
    self.Shooting = false
    self.Reloading = false

    for _, animation in pairs(self.Animations) do
        animation:Stop()
    end

    return nil
end

function BaseWeapon:ADS(sightDown: boolean)
    if self.Equipped == false then
        return
    end

    self.Aiming = sightDown
    if sightDown then
        self.Animations.Aim:Play()
    else
        self.Animations.Aim:Stop()
    end

    return nil
end

function BaseWeapon:SwitchMode()
    self.FireMode = self.FireMode % #self.FireModes + 1

    return nil
end

return table.freeze(BaseWeapon) :: BaseWeapon
