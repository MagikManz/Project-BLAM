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
    _time: number
}

export type ProjectileService = {
    AliveProjectiles: { [number]: Projectile },

    new: (projectileData: Projectile) -> any,
}

local Projectile: ProjectileService = { } :: ProjectileService

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
            return true
        end
    end

    return false
end

local loopProjectiles do 
    local function removeFarProjectile(projectile: Projectile): boolean
        return (projectile.CurrentPosition - projectile.Origin).Magnitude >= projectile.MaxDistance
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
        local rayResult = castRay(rayParams, newPosition, projectile.CurrentPosition, { projectile.Owner.Character :: Model })

        if rayResult ~= nil then
            local hit: BasePart = rayResult.Instance :: BasePart
            local hitPosition = rayResult.Position

            projectile.CurrentPosition = hitPosition

            print(hit, hitPosition, "projectile hit!")
            return true
        end        

        projectile.CurrentPosition = newPosition
        projectile._time = currentTick

        return false
    end

    loopProjectiles = function()
        for idx = #Projectile.AliveProjectiles, 1, -1 do
            local projectile = Projectile.AliveProjectiles[idx]

            if projectile == nil then continue end

            if removeFarProjectile(projectile) then
                removeProjectileById(projectile._id)
                continue
            end

            local didProjectileHit = moveProjectile(projectile)


            projectile.BasePart.Position = projectile.CurrentPosition

            if didProjectileHit then
                removeProjectileById(projectile._id)
            end
        end


        if #Projectile.AliveProjectiles == 0 then return end

        loopProjectiles()
    end
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

        BasePart = projectileData.BasePart,

        _id = projectileData._id,
        _time = projectileData._time or workspace:GetServerTimeNow(),
        _ignoreList = projectileData._ignoreList or { }
    } :: Projectile

    table.insert(Projectile.AliveProjectiles, projectile)

    return projectile
end

return table.freeze(Projectile) :: ProjectileService
