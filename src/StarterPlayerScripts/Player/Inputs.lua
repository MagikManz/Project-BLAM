--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputType = require(ReplicatedStorage.Client.Types.Inputs)

local PlayerGlobals = require(script.Parent.Globals)
local PlayerState = require(script.Parent.State)

local ReloadKeys = { Enum.KeyCode.R, Enum.KeyCode.ButtonY }
local ShootKeys = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 }
local AimKeys = { Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2 }
local SwitchModeKeys = { Enum.UserInputType.MouseButton3, Enum.KeyCode.ButtonR3 }

local SprintKeys = { Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3 }

local PlayerInputs: InputType.InputSystem = { 
    InputSettings = { 
        keysUsed = { 
            table.unpack(ReloadKeys), table.unpack(AimKeys), table.unpack(ShootKeys),
            table.unpack(SwitchModeKeys), table.unpack(SprintKeys)
        }
    }
} :: InputType.InputSystem

local function wepaonInputBegan(resolvedInput: InputType.ResolvedInput, _processed: boolean)
    local equippedWeapon = PlayerGlobals.EquippedWeapon
    if equippedWeapon == nil then return end

    if table.find(ReloadKeys, resolvedInput) then
        equippedWeapon:Reload()

    elseif table.find(ShootKeys, resolvedInput) then
        equippedWeapon:Shoot()

    elseif table.find(AimKeys, resolvedInput) then
        equippedWeapon:ADS(true)

    elseif table.find(SwitchModeKeys, resolvedInput) then
        equippedWeapon:SwitchMode()

    end
end

function PlayerInputs.InputBegan(resolvedInput: InputType.ResolvedInput, _input: InputObject, processed: boolean)
    if processed then return end

    wepaonInputBegan(resolvedInput, processed)

    if table.find(SprintKeys, resolvedInput) then
        PlayerState:Sprint(true)
    end
end

function PlayerInputs.InputEnded(resolvedInput: InputType.ResolvedInput, _input: InputObject)
    if table.find(SprintKeys, resolvedInput) then
        PlayerState:Sprint(false)
    end

    local equippedWeapon = PlayerGlobals.EquippedWeapon
    if equippedWeapon == nil then return end

    if table.find(AimKeys, resolvedInput) then
        equippedWeapon:ADS(false)
    end
end

return table.freeze(PlayerInputs) :: InputType.InputSystem
