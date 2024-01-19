local System = require(script.System)
local Types = require(script.Type)

export type WeaponStats = Types.GunStats
export type WeaponType = Types.GunAnimations
export type WeaponConfig = Types.Configuration

export type Weapon = System.Weapon

local WeaponsStats = { }

for _, weapon in ipairs(script.Stats:GetChildren()) do
    WeaponsStats[weapon.Name] = require(weapon) :: Types.Configuration
end

return {
    System = System,

    Types = Types,
    WeaponsStats = WeaponsStats
}