local System = require(script.System)
local Types = require(script.Type)

local WeaponsStats = { }

for _, weapon in ipairs(script.Stats:GetChildren()) do
    WeaponsStats[weapon.Name] = require(weapon) :: Types.Configuration
end

return {
    System = System,

    Types = Types,
    WeaponsStats = WeaponsStats
}