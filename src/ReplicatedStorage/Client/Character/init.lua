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

    Callbacks: { [string]: (self: CharacterService, newCharacter: Model) -> () },
    GlobalCallbacks: { [string]: (self: CharacterService, newCharacter: Model) -> () },

    GetCharacter: (self: CharacterService) -> Model?,
    GetViewModel: (self: CharacterService) -> CreateViewModel.ViewModel?,

    GetHumanoid: (self: CharacterService) -> Humanoid?,

    GetCameraComponents: (self: CharacterService) -> (Humanoid?, BasePart?, Model?),

    AddCallback: (self: CharacterService, name: string, callback: (self: CharacterService, newCharacter: Model) -> ()) -> () -> (),
    AddGlobalCallback: (self: CharacterService, name: string, callback: (self: CharacterService, newCharacter: Model) -> ()) -> () -> (),

    _updateCharacter: (self: CharacterService, newCharacter: Model) -> ()
}

local Player = Players.LocalPlayer

local Character: CharacterService = {
    _ref = { },
    Callbacks = { }
} :: CharacterService

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

    for _, callback in pairs(self.Callbacks) do
        task.defer(callback, self, newCharacter)
    end
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

function Character:AddCallback(name: string, callback: (self: CharacterService, newCharacter: Model) -> ()): () -> ()
    self.Callbacks[name] = callback

    local character = self:GetCharacter()
    if character then
        task.defer(callback, self, character)
    end

    return function()
        self.Callbacks[name] = nil
    end
end

function Character:AddGlobalCallback(name: string, callback: (self: CharacterService, newCharacter: Model) -> ()): () -> ()
    self.GlobalCallbacks[name] = callback

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            task.defer(callback, self, character)
        end
    end

    return function()
        self.GlobalCallbacks[name] = nil
    end
end




local __init = (function()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end

        local character = player.Character
        if not character then continue end

        for _, callback in pairs(Character.GlobalCallbacks) do
            task.defer(callback, Character, character)
        end
    end

    Player.CharacterAdded:Connect(function(newCharacter)
        Character:_updateCharacter(newCharacter)
    end)
    
    Players.PlayerAdded:Connect(function(player)
        if player == Player then
            return
        end
    
        player.CharacterAdded:Connect(function(newCharacter)
            for _, callback in pairs(Character.GlobalCallbacks) do
                task.defer(callback, Character, newCharacter)
            end
        end)
    end)

    return nil
end)()

return table.freeze(Character) :: CharacterService
