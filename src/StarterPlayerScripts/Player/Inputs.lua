--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InputType = require(ReplicatedStorage.Client.Types.Inputs)

local PlayerGlobals = require(script.Parent.Globals)
local PlayerState = require(script.Parent.State)

local ReloadKeys = { Enum.KeyCode.R, Enum.KeyCode.ButtonY }
local ShootKeys = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 }
local AimKeys = { Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2 }
local SwitchModeKeys = { Enum.UserInputType.MouseButton3, Enum.KeyCode.ButtonR3 }

local PlayerInputs: InputType.InputSystem = { 
    InputSettings = { 
        keysUsed = { 
            table.unpack(ReloadKeys), table.unpack(AimKeys), table.unpack(ShootKeys),
            table.unpack(SwitchModeKeys)
        }
    }
} :: InputType.InputSystem

local function wepaonInputBegan(resolvedInput: InputType.ResolvedInput, processed: boolean)
    local equippedWeapon = PlayerGlobals.EquippedWeapon
    if equippedWeapon == nil then return end

    local keyCode = resolvedInput.KeyCode
    local userInputType = resolvedInput.UserInputType

    if table.find(ReloadKeys, keyCode) then
        equippedWeapon:Reload()
    elseif table.find(ShootKeys, userInputType) or table.find(ShootKeys, keyCode) then
        equippedWeapon:Shoot()
    elseif table.find(AimKeys, userInputType) or table.find(AimKeys, keyCode) then
        equippedWeapon:ADS(true)
    elseif table.find(SwitchModeKeys, userInputType) or table.find(SwitchModeKeys, keyCode) then
        equippedWeapon:SwitchMode()
    end
end

function PlayerInputs.InputBegan(resolvedInput: InputType.ResolvedInput, _input: InputObject, processed: boolean)
    if processed then return end

    if PlayerState.WeaponState.EquippedSlot ~= nil then
        wepaonInputBegan(resolvedInput, processed)
    end
end

function PlayerInputs.InputEnded(resolvedInput: InputType.ResolvedInput, _input: InputObject)

end

return table.freeze(PlayerInputs) :: InputType.InputSystem
