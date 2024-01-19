--[[
    Filename: PlayerState.lua
    Author(s): MagikTheWizard
    Description: Player "system", used to manage the player's current state of the game.
                    Perhaps, should be updated to "PlayerState", and have a "Player" system

--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local CharacterService = require(ReplicatedStorage.Client.Character)
local WeaponService = require(ReplicatedStorage.Shared.Guns)

local Globals = require(script.Globals)
local Camera = require(script.Parent.Camera)

local Player = {
    State = require(script.State),
    Character = require(script.Character),
    Inputs = require(script.Inputs),
    GUI = require(script.GUI),
    Globals = Globals
}

local function loadWeaponAnimations(tool: Tool, weapon: WeaponService.Weapon)
    local weaponAnimations = WeaponService.WeaponsStats[tool.Name].Animations

    local humanoid = CharacterService:GetHumanoid()
    if humanoid then
        local animator: Animator = humanoid:WaitForChild("Animator") :: Animator
        local animations = { }
        for animationName, animationData in pairs(weaponAnimations) do
            local animation = Instance.new("Animation")
            animation.AnimationId = animationData.AnimationId

            local track = animator:LoadAnimation(animation)
            track.Looped = animationData.Looped
            track.Priority = animationData.Priority

            animations[animationName] = track
        end

        weapon.Animations = animations :: any -- hacky but i cba to type again lmao
    end
end

local function connectWeaponEvents(tool: Tool, weapon: WeaponService.Weapon)
    loadWeaponAnimations(tool, weapon)

    local equipMotor: Motor6D = tool:WaitForChild("EquipMotor") :: Motor6D

    local playerCharacter = CharacterService:GetCharacter()
    if playerCharacter == nil then return end

    local characterWeldPart: BasePart? = playerCharacter:WaitForChild(equipMotor:GetAttribute("Part_Name"), 50) :: BasePart?
    if characterWeldPart == nil then return end

    equipMotor.Part0 = characterWeldPart

    tool.Equipped:Connect(function()
        Globals:UpdateGlobal("EquippedWeapon", weapon)

        weapon:Equip()

        Camera:Enable()
    end)

    tool.Unequipped:Connect(function()
        Globals:UpdateGlobal("EquippedWeapon", nil)
        
        weapon:Unequip()

        Camera:Disable()
    end)
end

local function onBackpackChildAdded(newWeapon: Instance)
    if newWeapon:IsA("Tool") == false then return end
        
    if Globals.CurrentWeapons[newWeapon :: Tool] then
        return
    end

    local weapon = WeaponService.System:CreateWeapon(newWeapon.Name)
    Globals.CurrentWeapons[newWeapon :: Tool] = weapon

    connectWeaponEvents(newWeapon :: Tool, weapon)

    print("Loaded", weapon)
end

CharacterService:AddCallback("Backpack", function(_characterService, _newCharacter: Model)
    local backpack = LocalPlayer:WaitForChild("Backpack", 30)
    if not backpack then return end

    Globals:UpdateGlobal("CurrentWeapons", { })
    Globals:UpdateGlobal("EquippedWeapon", nil)

    for _, child in ipairs(backpack:GetChildren()) do
        onBackpackChildAdded(child)
    end

    backpack.ChildAdded:Connect(onBackpackChildAdded)
end)

CharacterService:AddCallback("Running", function(characterService)
    local humanoid = characterService:GetHumanoid()
    if humanoid == nil then return end

    local playerState = Player.State
    local playerValues = playerState.Values

    local runningConnection: RBXScriptConnection?

    local sprintingState = playerState.CharacterState.Sprinting

    sprintingState:disconnect("Player.Sprinting")

    sprintingState:connect("Player.Sprinting", function(isSprinting: boolean)
        if isSprinting == false then

            if runningConnection then
                runningConnection:Disconnect()
                runningConnection = nil
            end

            task.delay(0.5, function()
                while (playerValues.Stamina:get() :: number) < 100 and (sprintingState:get() :: boolean) == false do
                    playerValues.Stamina:set(playerValues.Stamina:get() + 1 / 20)

                    task.wait()
                end
            end)

            return
        end

        runningConnection = humanoid.Running:Connect(function(_speed: number)    
            while humanoid.MoveDirection.Magnitude > 0 and (sprintingState:get() :: boolean) == true do
                local stamina: number = playerValues.Stamina:get()
    
                playerValues.Stamina:set(stamina - 1 / 5)
                if playerState:CanSprint() == false then
                    playerState:Sprint(false)
                end

                task.wait()
            end
        end)
    end)
end)

function Player.State:Sprint(sprinting: boolean)
    if self:CanSprint() == false and sprinting == true then 
        self.CharacterState.Sprinting:set(false)
        return
    end

    local humanoid = CharacterService:GetHumanoid()
    if humanoid == nil then return end

    humanoid.WalkSpeed = sprinting and self.Data.SprintSpeed or self.Data.WalkSpeed

    self.CharacterState.Sprinting:set(sprinting)

    return nil
end

return Player
