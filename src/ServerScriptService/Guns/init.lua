local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local GunTypes = require(ReplicatedStorage.Shared.Guns.Type)

local Utilities = require(script.Utilities)

export type GunService = {
    RegisterPlayerWeapon: (self: GunService, player: Player, name: string, weaponStats: GunTypes.GunStats?) -> ( )
}

local Guns: GunService = { } :: GunService

function Guns:RegisterPlayerWeapon(player: Player, name: string, weaponStats: GunTypes.GunStats?)
    weaponStats = weaponStats or Utilities:GetWeaponStatsByName(name)
    if weaponStats == nil then
        return
    end


end



return table.freeze(Guns) :: GunService
