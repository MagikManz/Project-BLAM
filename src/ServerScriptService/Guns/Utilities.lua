local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponTypes = require(ReplicatedStorage.Shared.Guns.Type)

local WeaponsStats = ReplicatedStorage.Shared.Guns.Stats

export type GunUtilities = {
    GetWeaponStatsByName: (self: GunUtilities, name: string) -> WeaponTypes.GunStats?
}

local Utilites: GunUtilities = { } :: GunUtilities

function Utilites:GetWeaponStatsByName(name: string): WeaponTypes.GunStats?
    local weaponStat = WeaponsStats:FindFirstChild(name) :: ModuleScript
    return if weaponStat then require(weaponStat) :: WeaponTypes.GunStats? else nil
end

return table.freeze(Utilites) :: GunUtilities