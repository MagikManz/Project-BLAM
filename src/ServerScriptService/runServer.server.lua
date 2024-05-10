local Player = require(script.Parent.Shared.Player)
local Guns = require(script.Parent.Guns)

Player:OnCharacterAdded(function(player: Player, _character: Model)  
    Guns:GiveWeaponToPlayer(player, "M500")
end)