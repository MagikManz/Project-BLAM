local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type ViewModel = Model & {
    Head: BasePart,
    PrimaryPart: BasePart,
    HumanoidRootPart: BasePart,
    Humanoid: Humanoid & { Animator: Animator }
}

local CHARACTER_PARTS_WHITELIST = {
    "Shirt",
    "Body Colors",

    "Humanoid",

    "Head",
    "HumanoidRootPart"
}

local function removeUselessBodyParts(character: Model)
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            child.LocalTransparencyModifier = 1
            child.Massless = true
            child.CollisionGroup = "ViewModel"
        end

        if table.find(CHARACTER_PARTS_WHITELIST, child.Name) 
            and child:IsA("LuaSourceContainer") == false or child.Name:match("Torso")
        then
            continue
        elseif child.Name:match("Hand") or child.Name:match("Arm") then
            (child :: BasePart).LocalTransparencyModifier = 0
            continue
        end

        child:Destroy()
    end
end

return function(character: Model & { PrimaryPart: BasePart, Humanoid: Humanoid & { Animator: Animator } }): ViewModel
    character.Archivable = true
    
    local viewModel = character:Clone() :: ViewModel
    character.Archivable = false

    removeUselessBodyParts(viewModel)

    local viewModelAnimations = { }
    local currentEquippedWeapon: Tool? = nil

    viewModel.Name = "ViewModel"
    viewModel.PrimaryPart = viewModel.HumanoidRootPart
    viewModel.PrimaryPart.Anchored = true

    viewModel.Parent = ReplicatedStorage

    character.Humanoid.Animator.AnimationPlayed:Connect(function(animationTrack)
        if viewModelAnimations[animationTrack] == nil then
            viewModelAnimations[animationTrack] = viewModel.Humanoid.Animator:LoadAnimation(animationTrack.Animation)
            viewModelAnimations[animationTrack].Looped = animationTrack.Looped
        end

        for charTrack, viewModelTrack in pairs(viewModelAnimations) do
            if charTrack.IsPlaying == false then
                viewModelTrack:Stop()
            elseif viewModelTrack.IsPlaying == false then
                viewModelTrack:Play()

                viewModelTrack.TimePosition = charTrack.TimePosition
            end
        end
    end)

    viewModel:GetPropertyChangedSignal("Parent"):Connect(function()
        if viewModel.Parent ~= nil then return end

        if currentEquippedWeapon ~= nil then
            currentEquippedWeapon:Destroy()
            currentEquippedWeapon = nil
        end

        table.clear(viewModelAnimations)
    end)

    return viewModel
end