local ReplicatedStorage=  game:GetService("ReplicatedStorage")

local Weapon = require(ReplicatedStorage.Shared.Guns)
type GunAnimations = {
    [string]: AnimationTrack
}

type GlobalTypes = GunAnimations | Weapon.Weapon | nil

export type PlayerGlobals = {
    GunAnimations: GunAnimations,
    EquippedWeapon: Weapon.Weapon?,

    CurrentWeapons: { [Tool]: Weapon.Weapon },

    UpdateGlobal: (self: PlayerGlobals, globalName: string, globalValue: GlobalTypes) -> ()
}

local function updateGunAnimations(oldValue: GunAnimations)
    for _, animationTrack in pairs(oldValue) do
        animationTrack:Stop()
        animationTrack:Destroy()
    end
end

local Globals: PlayerGlobals = { 
    CurrentWeapons = { }
} :: PlayerGlobals

function Globals:UpdateGlobal(globalName: string, globalValue: GlobalTypes)
    if globalName == "GunAnimations" then
        updateGunAnimations(self[globalName])
    end

    if globalName ~= "EquippedWeapon" then
        if type(self[globalName]) == "table" then
            table.clear(self[globalName])
        end
    end

    self[globalName] = globalValue
end

return Globals