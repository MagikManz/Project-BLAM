--[[
    Filename: PlayerState.lua
    Author(s): MagikTheWizard
    Description: Player "system", used to manage the player's current state of the game.
                    Perhaps, should be updated to "PlayerState", and have a "Player" system

--]]

local Players = game:GetService("Players")

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
        HoldingWeapon: boolean,

        Sprinting: boolean,
        Jumping: boolean,
        
        Crouching: boolean,
        Swimming: boolean
    },

    Values : {
        Health: number,
        MaxHealth: number,

        Stamina: number,
        Oxygen: number,
    
        Jumps: number
    },

    WeaponState: {
        EquippedSlot: number?
    },

    GetPlayer: (self: PlayerStateService) -> Player,

    CanJump: (self: PlayerStateService) -> boolean,
    CanSprint: (self: PlayerStateService) -> boolean,
    CanCrouch: (self: PlayerStateService) -> boolean,

    ResetState: (self: PlayerStateService) -> nil
}

local DEFAULT_STATE = {
    _ref = {
        player = Players.LocalPlayer
    },

    CharacterState = {
        HoldingWeapon = false,

        Sprinting = false,
        Jumping = false,
        
        Crouching = false,
        Swimming = false
    },

    Values = {
        Health = 100,
        MaxHealth = 100,

        Stamina = 100,
        Oxygen = 100,
    
        Jumps = 1
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
    return self.Values.Jumps > 0
end

function PlayerState:CanSprint(): boolean
    return self.Values.Stamina > 0
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

return table.freeze(PlayerState) :: PlayerStateService
