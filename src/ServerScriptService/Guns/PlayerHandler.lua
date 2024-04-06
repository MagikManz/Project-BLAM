local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GunTypes = require(ReplicatedStorage.Shared.Guns.Type)

local Player = require(ServerScriptService.Shared.Player)

export type PlayerWeaponService = {
    ActiveWeapons: {
        [Player]: {
            [string]: GunTypes.GunStats
        }
    },

    RegisterWeapon: (self: PlayerWeaponService, player: Player, weapon: string, data: GunTypes.GunStats) -> string,
    RemoveWeapon: (self: PlayerWeaponService, player: Player, weaponId: string) -> ( )
}

local PlayerWeapon: PlayerWeaponService = { } :: PlayerWeaponService

function PlayerWeapon:RegisterWeapon(player: Player, weapon: string, data: GunTypes.GunStats): string
    local weaponID = HttpService:GenerateGUID(false)

    self.ActiveWeapons[player][weaponID] = data

    -- give the player the weapon by name

    return weaponID
end

function PlayerWeapon:RemoveWeapon(player: Player, weaponID: string): nil
    -- remove from character/inventory/send command to destroy/etc
    if self.ActiveWeapons[player][weaponID] then
        self.ActiveWeapons[player][weaponID] = nil
    end

    return nil
end

local __init = (function()
    Player:OnPlayerAdded(function(player)
        PlayerWeapon.ActiveWeapons[player] = {}
    end)

    Player:OnPlayerRemoving(function(player)
        table.clear(PlayerWeapon.ActiveWeapons[player])
        PlayerWeapon.ActiveWeapons[player] = nil
    end)

    return nil
end)()


return table.freeze(PlayerWeapon) :: PlayerWeaponService
