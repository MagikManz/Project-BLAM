--[[
    Filename: runClient.lua
    Author(s):  MagikTheWizard
    Description: Runs the client-side of the game.
--]]


local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerController = require(script.Parent.Player)

local Camera = require(script.Parent.Camera)


local function runClient()
    PlayerController.State:ResetState()
    Camera:Disable()
end

local function initClient()
    local KeysResolver = require(ReplicatedStorage.Client.Inputs.Resolver)

    local PlayerInputs = require(script.Parent.Player.Inputs)

    ContextActionService:BindActionAtPriority("PlayerActions",function(_actionName: string, inputState: Enum.UserInputState, inputObject: InputObject) 
        local resolvedInput = KeysResolver(inputObject)
        if resolvedInput == nil then
            return Enum.ContextActionResult.Pass
        end

        if inputState == Enum.UserInputState.Begin then
            PlayerInputs.InputBegan(resolvedInput, inputObject, false)
        elseif inputState == Enum.UserInputState.Change then
            return Enum.ContextActionResult.Pass
        elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
            PlayerInputs.InputEnded(resolvedInput,  inputObject)
        end

        return Enum.ContextActionResult.Pass
    end, false, Enum.ContextActionPriority.High.Value, table.unpack(PlayerInputs.InputSettings.keysUsed))

end


initClient()
runClient()
