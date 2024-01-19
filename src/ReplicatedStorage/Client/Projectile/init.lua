local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

export type Projectile = {
    Origin: Vector3,
    Direction: Vector3,

    Acceleration: Vector3,

    MaxDistance: number,

    MassMultiplier: number,
    CurrentPosition: Vector3,

    BasePart: BasePart,

    Owner: Player,

    _ignoreList: { Instance },
    _id: string,
    _time: number,
    _aliveTime: number,
}

export type ProjectileService = {
    AliveProjectiles: { [number]: Projectile },

    new: (projectileData: Projectile) -> any,
}

local ProjectileFolder = Instance.new("Folder")
ProjectileFolder.Name = "Projectiles"
ProjectileFolder.Parent = workspace

local Projectile: ProjectileService = { AliveProjectiles = { } } :: ProjectileService

local function getProjectileById(id: string): Projectile?
    for _, projectile in ipairs(Projectile.AliveProjectiles) do
        if projectile._id == id then
            return projectile
        end
    end

    return nil
end

local function removeProjectileById(id: string): boolean
    for index, projectile in ipairs(Projectile.AliveProjectiles) do
        if projectile._id == id then
            table.remove(Projectile.AliveProjectiles, index)

            projectile.BasePart:Destroy()

            return true
        end
    end

    return false
end

do 
    local function getProjectileDistance(projectile: Projectile): number
        return (projectile.CurrentPosition - projectile.Origin).Magnitude / projectile.MaxDistance
    end

    local function createRayParams(projectile: Projectile): RaycastParams
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = projectile._ignoreList
        rayParams.RespectCanCollide = true
        rayParams.IgnoreWater = true

        return rayParams
    end

    local function castRay(rayParams: RaycastParams, newPosition: Vector3, oldPosition: Vector3, addToIgnoreList: { Instance }): RaycastResult?
        rayParams:AddToFilter(addToIgnoreList)
        
        local rayResult = workspace:Raycast(oldPosition, newPosition - oldPosition, rayParams)
        if rayResult == nil then
            return
        end

        local hit: BasePart = rayResult.Instance :: BasePart
        if hit.Transparency == 1 then
            return castRay(rayParams, newPosition, oldPosition, { hit })
        end

        return rayResult
    end

    local function moveProjectile(projectile: Projectile): boolean
        local currentTick = workspace:GetServerTimeNow()

        local t = currentTick - projectile._time
                
        local newPosition = projectile.CurrentPosition + projectile.Acceleration * t * t / 2

        local rayParams = createRayParams(projectile)
        local rayResult = castRay(rayParams, newPosition, projectile.CurrentPosition, projectile._ignoreList)

        if rayResult ~= nil then
            local hit: BasePart = rayResult.Instance :: BasePart
            local hitPosition = rayResult.Position

            projectile.CurrentPosition = hitPosition

            print(hit, hitPosition, "projectile hit!")
            return true
        end

        projectile.CurrentPosition = newPosition
        projectile._time = currentTick
        projectile._aliveTime += t

        return false
    end

    task.defer(function()
        while true do
            task.wait()

            for idx = #Projectile.AliveProjectiles, 1, -1 do
                local projectile = Projectile.AliveProjectiles[idx]
    
                if projectile == nil then continue end
    
                local projectileDistanceDifference = getProjectileDistance(projectile)
                
                if projectileDistanceDifference >= 0.7 then
                    projectile.BasePart.Transparency = projectileDistanceDifference
                else
                    projectile.BasePart.Size = Vector3.new(0.2, 0.2,  math.min(5, projectile._aliveTime * 50))
                end
    
                if projectileDistanceDifference >= 1 then
                    removeProjectileById(projectile._id)
                    continue
                end
    
                local didProjectileHit = moveProjectile(projectile)
    
                projectile.BasePart:PivotTo(CFrame.new(projectile.CurrentPosition, projectile.CurrentPosition + projectile.Direction) * CFrame.new(0, 0, projectile.BasePart.Size.Z / -2))
    
                if didProjectileHit then
                    removeProjectileById(projectile._id)
                end
            end
        end
    end)
end

local function createDefaultProjectile(startCF: CFrame): BasePart
    local part = Instance.new("Part")

    part.Color = Color3.fromRGB(255, 106, 0)
    part.Material = Enum.Material.Neon

    part.CFrame = startCF
    part.Size = Vector3.new(0.2, 0.2, 0)

    part.Anchored = true
    part.CanCollide = false

    part.Parent = ProjectileFolder

    return part
end

function Projectile.new(projectileData: Projectile)
    if projectileData._id == nil then
        if projectileData.Owner == Players.LocalPlayer then
            projectileData._id = HttpService:GenerateGUID()
        else
            return warn("Cannot create projectile without _id, owner:", projectileData.Owner)
        end
    end

    local projectile = {
        Origin = projectileData.Origin,
        Direction = projectileData.Direction,

        Acceleration = projectileData.Acceleration,

        MaxDistance = projectileData.MaxDistance,

        MassMultiplier = projectileData.MassMultiplier,
        CurrentPosition = projectileData.Origin,

        Owner = projectileData.Owner,

        BasePart = projectileData.BasePart or createDefaultProjectile(CFrame.new(projectileData.Origin, projectileData.Origin + projectileData.Direction)),

        _id = projectileData._id,
        _time = projectileData._time or workspace:GetServerTimeNow(),
        _ignoreList = projectileData._ignoreList or { },

        _aliveTime = 0,
    } :: Projectile

    if projectile.Owner == Players.LocalPlayer then
        local playerCharacter: Model? = projectile.Owner.Character
        if playerCharacter == nil then
            return warn("Cannot create projectile without owner character, owner:", projectile.Owner)
        end

        local playerRoot = playerCharacter.PrimaryPart
        if playerRoot == nil then
            return warn("Cannot create projectile without owner character root, owner:", projectile.Owner)
        end

        projectile.Origin = (playerRoot.CFrame * CFrame.new(projectile.Origin)).Position + projectile.Direction.Unit * projectile.BasePart.Size.Z / 2
        projectile.CurrentPosition = projectile.Origin
    end

    table.insert(projectile._ignoreList, ProjectileFolder)
    table.insert(projectile._ignoreList, projectile.Owner.Character :: Model)

    table.insert(Projectile.AliveProjectiles, projectile)

    return projectile
end

return table.freeze(Projectile) :: ProjectileService
