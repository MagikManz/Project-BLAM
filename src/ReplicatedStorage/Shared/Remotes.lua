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

    ["Character.LookAt.Changed"] = Net.Definitions.ServerToClientEvent()
})
