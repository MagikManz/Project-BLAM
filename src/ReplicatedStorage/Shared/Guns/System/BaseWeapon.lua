local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunStatTypes = require(ReplicatedStorage.Shared.Guns.Type)

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

    Shooting: boolean,
    Reloading: boolean,
    Equipped: boolean,

    Animations: { [string]: AnimationTrack }
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

function BaseWeapon.new(weaponName: string, wepaonStats: GunStatTypes.GunStats): Weapon
    local weapon: PublicWeapon = {
        WeaponName = weaponName,

        Magazine = table.clone(wepaonStats.Magazine),

        Ammo = wepaonStats.Magazine.MagazineSize,
        Magazines = wepaonStats.Magazine.SpareMagazines,

        FireRate = wepaonStats.FireRate,
        FireModes = table.clone(wepaonStats.FireModes),

        FireMode = 1,

        Shooting = false,
        Reloading = false,
        Equipped = false
    } :: PublicWeapon

    return setmetatable(weapon, BaseWeapon) :: Weapon
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
    print("shooting", shots)

    return (currentFireMode == "Auto" or currentFireMode == "Burst" and shots < 3)
end

function BaseWeapon:Shoot()
    if self.Ammo <= 0 then
        -- play empty sound
        return
    end

    if self.Reloading or self.Shooting or self.Equipped == false then
        return
    end

    self.Shooting = true

    local shots = 1
    while shoot(self, shots) do
        shots += 1
        task.wait(self.FireRate)
    end

    self.Shooting = false

    return nil
end

function BaseWeapon:Reload()
    if self.Equipped == false then
        return
    elseif self.Magazines <= 0 then
        -- play empty sound
        return
    end

    self.Reloading = true
    -- play reload sound too!
    -- wait reload time

    if self.Reloading == false then
        -- reload was interrupted.
        return
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

    return nil
end

function BaseWeapon:Unequip()
    self.Equipped = false
    self.Shooting = false
    self.Reloading = false

    return nil
end

function BaseWeapon:ADS(sightDown: boolean)
    if self.Equipped == false then
        return
    end

    return nil
end

function BaseWeapon:SwitchMode()
    self.FireMode = self.FireMode % #self.FireModes + 1

    return nil
end

return table.freeze(BaseWeapon) :: BaseWeapon
