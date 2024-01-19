type Animation = {
    AnimationId: string,
    Looped: boolean,
    Priority: Enum.AnimationPriority
}

export type GunAnimations = {
    Equip: Animation,
    Rest: Animation,
    Hip: Animation,
    HipFire: Animation,
    Aim: Animation,
    AimFire: Animation,
    Empty: Animation,
    ReloadTactical: Animation,
    ReloadEmpty: Animation,

    -- For the pump
    AimPump: Animation?,
    HipPump: Animation?,
    Reload: Animation?,
    ReloadStartTactical: Animation?,
    ReloadStartEmpty: Animation?,
    ReloadEnd: Animation?
}

--[[
export type GunStats = {
    Damage: {
        MaxDamage: number,
        MinDamage: number,
    },

    DamageFalloff: {
        MaxFallOff: number,
        MinFallOff: number,
    },

    FallOffModifier: number,

    FireRate: number,

    FireModes: {
        Auto: boolean,
        Semi: boolean,
        Burst: boolean
    },

    Magazine: {
        MagazineSize: number,
        SpareMagazines: number,
        AmmoPerShot: number
    },

    DamageMultiplier: {
        Head: number?,
        UpperTorso: number?,
        LowerTorso: number?,
        Limb: number?
    },

    Projectile: {
        ProjectilePerShot: number,
        Penetration: {
            Humanoid: {
                Modifier: number,
                MaxPenetration: number
            },

            Material: {
                Modifier: number,
                MaxPenetration: number
            },

            MaxPenetrations: number
        }
    },

    Spread: {
        Aiming: {
            MinSpread: number,
            MaxSpread: number
        },

        Hip: {
            MinSpread: number,
            MaxSpread: number
        },
    },

    BulletType: string
}
]]

export type GunStats = {
    Damage: {
        MaxDamage: number,
        MinDamage: number,
    },

    FireModes: { 
        "Auto" | "Semi" | "Burst"
    },

    Magazine: {
        MagazineSize: number,
        SpareMagazines: number,
        AmmoPerShot: number
    },

    FireRate: number,

    Range: number,

    BarrelOffset: CFrame
}

export type Configuration = {
    Animations: GunAnimations,

    Stats: GunStats
}

return true