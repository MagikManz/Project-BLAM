--[[

    Equip = {"rbxassetid://12170637028", false, Enum.AnimationPriority.Action},
	Rest = {"rbxassetid://12170610184", true, Enum.AnimationPriority.Movement},
	Hip = {"rbxassetid://12170640034", true, Enum.AnimationPriority.Idle},
	Hipfire = {"rbxassetid://12170641974", false, Enum.AnimationPriority.Action2},
	Aim = {"rbxassetid://12170647771", true, Enum.AnimationPriority.Idle},
	Aimfire = {"rbxassetid://12170648641", true, Enum.AnimationPriority.Action2},    
	Empty = {"rbxassetid://", false, Enum.AnimationPriority.Action},
	ReloadTactical = {"rbxassetid://12170653708", false, Enum.AnimationPriority.Action3},
	ReloadEmpty = {"rbxassetid://12170652374", false, Enum.AnimationPriority.Action3},

	-- Pump Specific Animations
	AimPump = {"rbxassetid://12170649548", false, Enum.AnimationPriority.Action2},
	HipPump = {"rbxassetid://12170643299", false, Enum.AnimationPriority.Action2},
	Reload = {"rbxassetid://12170654334", false, Enum.AnimationPriority.Action3},
	ReloadStartTactical = {"rbxassetid://12170653708", false, Enum.AnimationPriority.Action3},
	ReloadStartEmpty = {"rbxassetid://12170652374", false, Enum.AnimationPriority.Action3},
	ReloadEnd = {"rbxassetid://12170655921", false, Enum.AnimationPriority.Action3},
]]

local Type = require(script.Parent.Parent.Type)

local Animations = {
    Equip = {
        AnimationId = "rbxassetid://12170637028", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action
    },

    Rest = {
        AnimationId = "rbxassetid://12170610184", 
        Looped = true,
        Priority = Enum.AnimationPriority.Movement
    },

    Hip = {
        AnimationId = "rbxassetid://12170640034", 
        Looped = true,
        Priority = Enum.AnimationPriority.Idle
    },

    HipFire = {
        AnimationId = "rbxassetid://12170641974", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action2
    },

    Aim = {
        AnimationId = "rbxassetid://12170647771", 
        Looped = true,
        Priority = Enum.AnimationPriority.Idle
    },

    AimFire = {
        AnimationId = "rbxassetid://12170648641", 
        Looped = true,
        Priority = Enum.AnimationPriority.Action2
    },

    Empty = {
        AnimationId = "rbxassetid://", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action
    },

    ReloadTactical = {
        AnimationId = "rbxassetid://12170653708", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    },

    ReloadEmpty = {
        AnimationId = "rbxassetid://12170652374", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    },

    AimPump = {
        AnimationId = "rbxassetid://12170649548", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action2
    },

    HipPump = {
        AnimationId = "rbxassetid://12170643299", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action2
    },

    Reload = {
        AnimationId = "rbxassetid://12170654334", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    },

    ReloadStartTactical = {
        AnimationId = "rbxassetid://12170653708", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    },

    ReloadStartEmpty = {
        AnimationId = "rbxassetid://12170652374", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    },

    ReloadEnd = {
        AnimationId = "rbxassetid://12170655921", 
        Looped = false,
        Priority = Enum.AnimationPriority.Action3
    }
}

local Config: Type.Configuration = { 
    Animations = Animations
} :: Type.Configuration

return table.freeze(Config) :: Type.Configuration