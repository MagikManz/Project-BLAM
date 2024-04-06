local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local t = require(ReplicatedStorage.Packages.t)

export type ServerListenerEvent = Net.ServerListenerEvent
export type ServerSenderEvent = Net.ServerSenderEvent

return Net.CreateDefinitions({
    ["Character.LookAt"] = Net.Definitions.ClientToServerEvent({
        Net.Middleware.TypeChecking(t.CFrame),
        Net.Middleware.RateLimit({
            MaxRequestsPerMinute = 140
        })
    }),

    ["Character.LookAt.Changed"] = Net.Definitions.ServerToClientEvent(),

    ["Weapons.Player.Shoot"] = Net.Definitions.ClientToServerEvent({
        Net.Middleware.TypeChecking(t.CFrame),
    }),

    ["Weapons.Player.Reload"] = Net.Definitions.ClientToServerEvent({
        Net.Middleware.TypeChecking(t.string), -- Weapon name
        Net.Middleware.TypeChecking(t.number) -- Reload tick
    }),

    ["Weapons.Server.Projectile"] = Net.Definitions.ServerToClientEvent()
})
