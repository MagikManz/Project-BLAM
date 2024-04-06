local ReplicatedStorage = game:GetService("ReplicatedStorage")

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




return true