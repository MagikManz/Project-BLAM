--[[
    Filename: PlayerState.lua
    Author(s): MagikTheWizard
    Description: Player "system", used to manage the player's current state of the game.
                    Perhaps, should be updated to "PlayerState", and have a "Player" system

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local StateCache = require(ReplicatedStorage.Shared.StateCache)

type Weapon = {
    Name: string,
}

export type PlayerStateService = {
    _ref: {
        player: Player
    },

    InventoryState: {
        Primary: Weapon,
        Secondary: Weapon,
        Melee: Weapon,
        Throwable: Weapon
    },

    CharacterState: {
        HoldingWeapon: StateCache.State,

        Sprinting: StateCache.State,
        Jumping: StateCache.State,
        
        Crouching: StateCache.State,
        Swimming: StateCache.State
    },

    Values: {
        Health: StateCache.State,
        MaxHealth: number,

        Stamina: StateCache.State,
        Oxygen: number,

        Jumps: StateCache.State
    },

    Data: {
        SprintSpeed: number,
        WalkSpeed: number
    },

    WeaponState: {
        EquippedSlot: number?
    },

    GetPlayer: (self: PlayerStateService) -> Player,

    CanJump: (self: PlayerStateService) -> boolean,
    CanSprint: (self: PlayerStateService) -> boolean,
    CanCrouch: (self: PlayerStateService) -> boolean,

    Sprint: (self: PlayerStateService, sprinting: boolean) -> nil,

    ResetState: (self: PlayerStateService) -> nil
}

local DEFAULT_STATE = {
    _ref = {
        player = Players.LocalPlayer
    },

    CharacterState = {
        HoldingWeapon = StateCache:CreateState("Player.HoldingWeapon", false),

        Sprinting = StateCache:CreateState("Player.Sprinting", false),
        Jumping = StateCache:CreateState("Player.Jumping", false),
        
        Crouching = StateCache:CreateState("Player.Crouching", false),
        Swimming = StateCache:CreateState("Player.Swimming", false)
    },

    Values = {
        Health = StateCache:CreateState("Player.Health", 100, 0),
        MaxHealth = 100,

        Stamina = StateCache:CreateState("Player.Stamina", 100, 0),
        Oxygen = 100,
    
        Jumps = StateCache:CreateState("Player.Jumps", 1, 0, 1),
    },

    Data = {
        SprintSpeed = 24,
        WalkSpeed = 14
    },

    WeaponState = {
        EquippedSlot = nil
    }
}

local PlayerState: PlayerStateService = { } :: PlayerStateService

function PlayerState:GetPlayer(): Player
    return self._ref.player
end

function PlayerState:CanJump(): boolean
    return self.Values.Jumps:get() :: number > 0
end

function PlayerState:CanSprint(): boolean
    return self.Values.Stamina:get() :: number > 0
end

function PlayerState:CanCrouch(): boolean
    return true
end

function PlayerState:ResetState(): nil
    for key, value in pairs(DEFAULT_STATE) do
        for k, v in pairs(value) do
            self[key][k] = v
        end
    end

    return nil
end

local __init = (function()
    for key, value in pairs(DEFAULT_STATE) do
        PlayerState[key] = value
    end

    return nil
end)()

return PlayerState :: PlayerStateService
