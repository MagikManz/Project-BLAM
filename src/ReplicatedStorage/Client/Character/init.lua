--[[
    Filename: Character.lua
    Author(s): MagikTheWizard
    Description: Character system, helps handling camera and automatic character updating.
--]]

local Players = game:GetService("Players")

local CreateViewModel = require(script.CreateViewModel)
export type CharacterService = {
    _ref: {
        viewmodel: CreateViewModel.ViewModel?,
        character: Model?,
        humanoid: Humanoid?
    },

    GetCharacter: (self: CharacterService) -> Model?,
    GetViewModel: (self: CharacterService) -> CreateViewModel.ViewModel?,

    GetHumanoid: (self: CharacterService) -> Humanoid?,

    GetCameraComponents: (self: CharacterService) -> (Humanoid?, BasePart?, Model?),

    _updateCharacter: (self: CharacterService, newCharacter: Model) -> ()
}

local Player = Players.LocalPlayer

local Character = { 
    _ref = {
        viewmodel = nil,
        character = nil,
        humanoid = nil        
    },

    GetCharacter = function(_self: CharacterService) end,
    GetViewModel = function(_self_: CharacterService) end,

    GetHumanoid = function(_self: CharacterService) end,
    GetCameraComponents = function(_self: CharacterService) end,

    _updateCharacter = function(_self: CharacterService, _newCharacter: Model) end
}

function Character:_updateCharacter(newCharacter: Model)
    self._ref.character = newCharacter
    local humanoid = newCharacter:WaitForChild("Humanoid", 30)
    if humanoid == nil then
        if self._ref.character == newCharacter then
            Player:Kick("No humanoid")
        end

        return
    end

    self._ref.humanoid = humanoid :: Humanoid

    if self._ref.viewmodel and self._ref.viewmodel.Parent ~= nil then
        self._ref.viewmodel:Destroy()
    end

    self._ref.viewmodel = CreateViewModel(newCharacter :: Model & { PrimaryPart: BasePart }) 
end

function Character:GetCharacter(): Model?
    return self._ref.character
end

function Character:GetViewModel(): CreateViewModel.ViewModel?
    return self._ref.viewmodel
end

function Character:GetHumanoid(): Humanoid?
    return self._ref.humanoid
end

function Character:GetCameraComponents(): (Humanoid?, BasePart?, Model?)
    local character = self:GetCharacter()
    if character == nil then
        return nil
    end

    return self:GetHumanoid(), character:FindFirstChild("HumanoidRootPart") :: BasePart?, character
end

Player.CharacterAdded:Connect(function(newCharacter)
    Character:_updateCharacter(newCharacter)
end)

return table.freeze(Character) :: CharacterService