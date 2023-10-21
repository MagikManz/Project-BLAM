local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type CharacterService = {
    GetHumanoid: (self: CharacterService, player: Player, character: Model, retry: boolean) -> Humanoid?,

    DefaultConnections: { { priority: number, func: (player: Player, character: Model) -> () } }
}

type AnimateScript = LocalScript & {
    run: StringValue & { RunAnim: Animation },
    walk: StringValue & { WalkAnim: Animation },
    jump: StringValue & { ["!ID!"]: Animation },
    idle: StringValue & { Animation1: Animation, Animation2: Animation },
    fall: StringValue & { FallAnim: Animation },
}

local PLAYER_RESPAWN_TIME = 3
local DEFAULT_WALK_SPEED = 12

local Animations = require(ReplicatedStorage.Shared.Animations).Character

local Character: CharacterService = {
    GetHumanoid = function(_self, _player, _character, _retry): Humanoid? return nil end,

    DefaultConnections = { }
}

function Character:GetHumanoid(player: Player, character: Model, retry: boolean): Humanoid?
    local humanoid = character:WaitForChild("Humanoid", 30) :: Humanoid?
    if humanoid == nil and player.Character ~= character and player.Character ~= nil and retry then
        return self:GetHumanoid(player, player.Character, retry)
    end

    return humanoid
end

local __init = (function()
    table.insert(Character.DefaultConnections, {
        priority = math.huge,
        func = function(player: Player, character: Model) 
            local humanoid = Character:GetHumanoid(player, character, false)
            if humanoid == nil then
                return
            end

            humanoid.WalkSpeed = DEFAULT_WALK_SPEED

            local healthConnection
            healthConnection = humanoid.HealthChanged:Connect(function(newHealth)
                if newHealth ~= 0 then return end

                healthConnection:Disconnect()
                task.wait(PLAYER_RESPAWN_TIME)

                player:LoadCharacter()
            end)
        end
    })

    table.insert(Character.DefaultConnections, {
        priority = math.huge,
        func = function(player: Player, character: Model)
            local humanoid = Character:GetHumanoid(player, character, false)
            if humanoid == nil then
                return
            end

            local animator = humanoid:WaitForChild("Animator", 30) :: Animator?
            local animateScript = character:WaitForChild("Animate", 30) :: AnimateScript?
            if animator == nil or animateScript == nil then
                return
            end

            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end

            animateScript.run.RunAnim.AnimationId = Animations.Survivor.Walk
            animateScript.walk.WalkAnim.AnimationId = Animations.Survivor.Walk

            local jumpAnimation = animateScript.jump:FindFirstChildOfClass("Animation")
            if jumpAnimation then
                jumpAnimation.AnimationId = Animations.Survivor.Jump
            end

            animateScript.idle.Animation1.AnimationId = Animations.Survivor.Idle
            animateScript.idle.Animation2.AnimationId = Animations.Survivor.Idle

            animateScript.fall.FallAnim.AnimationId = Animations.Survivor.Fall
        end
    })

    return nil
end)()

return table.freeze(Character) :: CharacterService