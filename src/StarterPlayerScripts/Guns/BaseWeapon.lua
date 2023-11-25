export type PublicWeapon = {
    WeaponName: string
}

type BaseWeapon = {
    __index: BaseWeapon,

    new: (weaponName: string) -> Weapon
}

type Weapon = typeof(setmetatable({} :: PublicWeapon, {} :: BaseWeapon))

local BaseWeapon: BaseWeapon = { } :: BaseWeapon
BaseWeapon.__index = BaseWeapon

function BaseWeapon.new(weaponName: string): Weapon
    local weapon = {
        WeaponName = weaponName
    }


    return setmetatable(weapon, BaseWeapon) :: Weapon
end


return table.freeze(BaseWeapon) :: BaseWeapon
