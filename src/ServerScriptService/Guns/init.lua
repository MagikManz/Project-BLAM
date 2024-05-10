local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunTypes = require(ReplicatedStorage.Shared.Guns.Type)

local PlayerHandler = require(script.PlayerHandler)
local Utilities = require(script.Utilities)

require(script.Events)

export type GunService = {
    _registerPlayerWeapon: (self: GunService, player: Player, name: string, weaponStats: GunTypes.GunStats?) -> (string?, Tool?),
    GiveWeaponToPlayer: (self: GunService, player: Player, name: string, weaponStats: GunTypes.GunStats?) -> ( )
}

local Guns: GunService = { } :: GunService

function Guns:_registerPlayerWeapon(player: Player, name: string, weaponStats: GunTypes.GunStats?): (string?, Tool?)
    if weaponStats == nil then
        return nil, nil
    end

    return PlayerHandler:RegisterWeapon(player, name, weaponStats)
end

function Guns:GiveWeaponToPlayer(player: Player, name: string, weaponStats: GunTypes.GunStats?)
    if weaponStats == nil then
        weaponStats = Utilities:GetWeaponStatsByName(name)
    end

    local weaponId, tool = self:_registerPlayerWeapon(player, name, weaponStats)
    if not (weaponId and tool) then
        return
    end

    local playerCharacter: Model? = player.Character :: Model
    if playerCharacter == nil then 
        PlayerHandler:RemoveWeapon(player, weaponId)
        return
    end

    local equipMotor: Motor6D = tool:WaitForChild("EquipMotor") :: Motor6D
    local characterWeldPart: BasePart? = playerCharacter:WaitForChild(equipMotor:GetAttribute("Part_Name"), 50) :: BasePart?
    if characterWeldPart == nil then 
        PlayerHandler:RemoveWeapon(player, weaponId)
        return
    end

    equipMotor.Part0 = characterWeldPart

    tool.Parent = player.Backpack
end


return table.freeze(Guns) :: GunService
