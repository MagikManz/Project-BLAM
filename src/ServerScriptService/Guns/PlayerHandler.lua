local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GunTypes = require(ReplicatedStorage.Shared.Guns.Type)
local StateCache = require(ReplicatedStorage.Shared.StateCache)
local State = require(ReplicatedStorage.Shared.StateCache)

local Player = require(ServerScriptService.Shared.Player)


local Weapons = ReplicatedStorage.Models.Guns

export type PlayerWeaponService = {
    ActiveWeapons: {
        [Player]: {
            [string]: {
                Stats: StateCache.State,
                Tool: Tool
            }
        }
    },

    RegisterWeapon: (self: PlayerWeaponService, player: Player, weapon: string, data: GunTypes.GunStats) -> (string?, Tool?),
    RemoveWeapon: (self: PlayerWeaponService, player: Player, weaponId: string) -> ( ),
    GetPlayerWeaponState: (self: PlayerWeaponService, player: Player, weaponId: string) -> StateCache.State
}

local PlayerWeapon: PlayerWeaponService = {
    ActiveWeapons = { }
} :: PlayerWeaponService

function PlayerWeapon:RegisterWeapon(player: Player, weapon: string, data: GunTypes.GunStats): (string?, Tool?)
    local weaponID = HttpService:GenerateGUID(false)

    local tool: Tool? = Weapons:FindFirstChild(weapon) :: Tool
    if not tool then
        return nil, nil
    end

    tool = tool:Clone()
    tool:SetAttribute("ID", weaponID)

    self.ActiveWeapons[player][weaponID] = {
        Stats = State:CreateState(weaponID, data),
        Tool = tool
    }

    return weaponID, tool
end

function PlayerWeapon:RemoveWeapon(player: Player, weaponID: string): nil
    if self.ActiveWeapons[player][weaponID] == nil then
        return nil
    end

    local tool = self.ActiveWeapons[player][weaponID].Tool

    table.clear(self.ActiveWeapons[player][weaponID])
    self.ActiveWeapons[player][weaponID] = nil

    if tool and tool.Parent then
        tool:Destroy()
    end

    return nil
end

function PlayerWeapon:GetPlayerWeaponState(player: Player, weaponId: string): StateCache.State
    return self.ActiveWeapons[player][weaponId].Stats
end

local __init = (function()
    Player:OnPlayerAdded(function(player)
        PlayerWeapon.ActiveWeapons[player] = {}
    end)

    Player:OnPlayerRemoving(function(player)
        for _, weapon in pairs(PlayerWeapon.ActiveWeapons[player]) do
            if weapon.Tool and weapon.Tool.Parent then
                weapon.Tool:Destroy()
            end
        end

        table.clear(PlayerWeapon.ActiveWeapons[player])
        PlayerWeapon.ActiveWeapons[player] = nil
    end)

    return nil
end)()


return table.freeze(PlayerWeapon) :: PlayerWeaponService
