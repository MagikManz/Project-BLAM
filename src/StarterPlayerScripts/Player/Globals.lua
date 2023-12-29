local ReplicatedStorage=  game:GetService("ReplicatedStorage")

type GunAnimations = {
    [string]: AnimationTrack
}

type GlobalTypes = GunAnimations

local Weapon = require(ReplicatedStorage.Shared.Guns.System.BaseWeapon)

export type PlayerGlobals = {
    GunAnimations: GunAnimations,
    EquippedWeapon: Weapon.Weapon?,

    UpdateGlobal: (self: PlayerGlobals, globalName: string, globalValue: GlobalTypes) -> ()
}

local function updateGunAnimations(oldValue: GunAnimations)
    for _, animationTrack in pairs(oldValue) do
        animationTrack:Stop()
    end
end

local Globals: PlayerGlobals = { 

} :: PlayerGlobals

function Globals:UpdateGlobal(globalName: string, globalValue: GlobalTypes)
    if globalName == "GunAnimations" then
        updateGunAnimations(self[globalName])
    end


    self[globalName] = globalValue
end

return Globals