
local StateValue = require(script.StateValue)

export type State = StateValue.State

export type StateCache = {
    _states: { StateValue.State },

    GetState: (self: StateCache, stateName: string) -> StateValue.State?,
    CreateState: (self: StateCache, stateName: string, defaultValue: number | string | boolean | { [any]: any }, minValue: number?, maxValue: number?) -> StateValue.State
}

local StateCache: StateCache = { 
    _states = { }
} :: StateCache

function StateCache:GetState(stateName: string): StateValue.State?
    for _, state in ipairs(self._states) do
        if state.name == stateName then
            return state
        end
    end

    return nil
end

function StateCache:CreateState(stateName: string, defaultValue: number | string | boolean | {[any]: any}, minValue: number?, maxValue: number?): StateValue.State
    local state = StateValue.new(stateName, defaultValue :: number & string & boolean & {[any]: any}, minValue, maxValue)
    table.insert(self._states, state)

    return state
end

return StateCache
