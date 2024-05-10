local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guns = require(ReplicatedStorage.Shared.Guns)
local PlayerHandler = require(script.Parent.PlayerHandler)

local Remotes = require(ReplicatedStorage.Shared.Remotes)


--[[
local lookAtEvent: Remotes.ServerListenerEvent = Remotes.Server:Get("Character.LookAt") :: Remotes.ServerListenerEvent
local syncLookAtEvent: Remotes.ServerSenderEvent = Remotes.Server:Get("Character.LookAt.Changed") :: Remotes.ServerSenderEvent
lookAtEvent:Connect(function(player: Player, lookAt: Vector3)
    if type(lookAt) ~= "vector" then
        return
    end

    if lookAt ~= lookAt then
        return
    end

    syncLookAtEvent:SendToAllPlayersExcept(player, player, lookAt)
end)
]]--

local shootEvent: Remotes.ServerListenerEvent = Remotes.Server:Get("Weapons.Player.Shoot") :: Remotes.ServerListenerEvent

shootEvent:Connect(function(player: Player, weaponId: string, lookAt: Vector3)
    warn(player, "Shot!")

    local weaponData = PlayerHandler:GetPlayerWeaponState(player, weaponId)
    if not weaponData then
        return
    end

    local data: Guns.WeaponStats = weaponData:get()
    if (data.Magazine.AmmoPerShot > data.Ammo) then
        return
    end
end)


return true