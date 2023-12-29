--[[
    Filename: Guns.lua
    Author(s): MagikTheWizard
    Description: Client Gun System for handling of all weapons.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guns = ReplicatedStorage.Shared.Guns

local BaseWeapon = require(script.BaseWeapon)
local GunTypes = require(Guns.Type)

export type GunClientService = {
    GetWeaponAnimations: (self: GunClientService, weaponName: string) -> GunTypes.GunAnimations,

    GetWeaponConfig: (self: GunClientService, weaponName: string) -> GunTypes.Configuration,

    CreateWeapon: (self: GunClientService, weaponName: string) -> (BaseWeapon.Weapon, GunTypes.GunAnimations)
}

local GunClientService: GunClientService = { } :: GunClientService

function GunClientService:GetWeaponAnimations(weaponName: string): GunTypes.GunAnimations
    local weaponConfig = self:GetWeaponConfig(weaponName)

    return weaponConfig.Animations
end

function GunClientService:GetWeaponConfig(weaponName: string): GunTypes.Configuration
    local weapon = Guns:FindFirstChild(weaponName)
    assert(weapon, "Weapon " .. weaponName .. " does not exist!")

    local weaponConfig = require(weapon) :: GunTypes.Configuration
    assert(weaponConfig, "WeaponConfig for " .. weaponName .. " does not exist!")

    return weaponConfig
end

function GunClientService:CreateWeapon(weaponName: string): (BaseWeapon.Weapon, GunTypes.GunAnimations)
    local weaponConfig = self:GetWeaponConfig(weaponName)
    local weapon = BaseWeapon.new(weaponName, weaponConfig.Stats)

    return weapon, weaponConfig.Animations
end

return table.freeze(GunClientService) :: GunClientService
