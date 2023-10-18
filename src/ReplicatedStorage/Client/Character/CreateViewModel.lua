export type ViewModel = Model & {
    Head: BasePart,
    PrimaryPart: BasePart,
    HumanoidRootPart: BasePart
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

return function(character: Model)
    character.Archivable = true
    
    local viewModel = character:Clone() :: ViewModel
    character.Archivable = false

    removeUselessBodyParts(viewModel)

    viewModel.Name = "ViewModel"
    viewModel.PrimaryPart = viewModel.Head
    viewModel.PrimaryPart.Anchored = true
    viewModel:PivotTo(CFrame.new(0, 5, 0))

    viewModel.Parent = workspace
end