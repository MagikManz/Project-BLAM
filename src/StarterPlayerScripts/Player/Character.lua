local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterService = require(ReplicatedStorage.Client.Character)

local Character = { }

CharacterService:AddCallback("Player.LookAt", function(_characterService, character)
    local REQUEST_LIMIT = 0.5

    local Camera = workspace.CurrentCamera

    local Head: BasePart? = character:WaitForChild("Head", 40) :: BasePart
    if Head == nil then
        return
    end

    local UpperTorso = character:WaitForChild("UpperTorso", 40)
    if UpperTorso == nil then
        return
    end

    local lastRequest = 0
    local currentLookVector = Vector3.zero
    local queuedLookVector: Vector3? = Vector3.zero

    local IKControl = Instance.new("IKControl")
    IKControl.Name = "LookAt"
    IKControl.Weight = 0.5
    IKControl.SmoothTime = 0.2
    IKControl.Type = Enum.IKControlType.LookAt
    IKControl.Parent = character

    local LookVectorPart = Instance.new("Part")
    LookVectorPart.Name = "LookVector"
    LookVectorPart.Anchored = true
    LookVectorPart.CanQuery = false
    LookVectorPart.CanCollide = false
    LookVectorPart.Transparency = 1
    LookVectorPart.Size = Vector3.new(0.1, 0.1, 0.1)
    LookVectorPart.Parent = character

    IKControl.Target = LookVectorPart
    IKControl.ChainRoot = UpperTorso
    IKControl.EndEffector = Head

    local function updateLookAt()
        LookVectorPart:PivotTo(CFrame.new(Head.Position + Vector3.yAxis * 3 + currentLookVector * 10))

        if character.Parent ~= nil then
            task.wait()
            updateLookAt()
        end
    end

    Camera:GetPropertyChangedSignal("CFrame"):Connect(function()
        if Camera.CFrame.LookVector:Dot(currentLookVector) > 0.99 then
            return
        end

        if os.time() < lastRequest then
            queuedLookVector = Camera.CFrame.LookVector
            task.delay(os.time() - lastRequest, function()
                if queuedLookVector == nil then
                    return
                end

                currentLookVector = queuedLookVector
                queuedLookVector = nil
            end)

            return
        end

        lastRequest = os.time() + REQUEST_LIMIT

        currentLookVector = Camera.CFrame.LookVector
        queuedLookVector = nil
    end)

    updateLookAt()
end)

return Character
