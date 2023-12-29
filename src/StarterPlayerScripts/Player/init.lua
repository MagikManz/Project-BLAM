--[[
    Filename: PlayerState.lua
    Author(s): MagikTheWizard
    Description: Player "system", used to manage the player's current state of the game.
                    Perhaps, should be updated to "PlayerState", and have a "Player" system

--]]

local Player = {
    State = require(script.State),
    Character = require(script.Character),
    Inputs = require(script.Inputs),
    Globals = require(script.Globals),
}

return Player
