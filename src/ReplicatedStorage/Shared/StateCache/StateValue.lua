export type StateValues = {
    minValue: number?,
    maxValue: number?,
    
    name: string,

    default: number | string | boolean | { [any]: any },
    value: number | string | boolean | { [any]: any },

    connections: {
        [string]: (value: number & string & boolean & { [any]: any }) -> nil,
    }
}

export type BaseState = {
    __index: BaseState,

    new: ((stateName: string, defaultValue: number, minValue: number?, maxValue: number?) -> State)
            & ((stateName: string, defaultValue: string) -> State) 
            & ((stateName: string, defaultValue: boolean) -> State)
            & ((stateName: string, defaultValue: { [any]: any }) -> State),

    set: (self: State, value: number | string | boolean | { [any]: any }) -> nil,
    get: (self: State) -> number & string & boolean & { [any]: any },

    reset: (self: State) -> nil,

    connect: (self: State, connectionName: string, callback: (value: number & string & boolean) -> nil) -> nil,
    disconnect: (self: State, connectionName: string) -> nil
}

export type State = typeof(setmetatable({} :: StateValues, {} :: BaseState))

local StateValue: BaseState = { } :: BaseState
StateValue.__index = StateValue

local function deepCopy(t: {[any]: any})
    local copy = { }

    for key, value in pairs(t) do
        if type(value) == "table" then
            copy[key] = deepCopy(value)
        else
            copy[key] = value
        end
    end

    return copy
end

local function callConnections(self: State, value: number & string & boolean)
    for _, callback in pairs(self.connections) do
        callback(value)
    end

    return nil
end

function StateValue.new(stateName: string, defaultValue: number | string | boolean | { [any]: any }, minValue: number?, maxValue: number?): State
    local state: StateValues = { 
        name = stateName,
        default = defaultValue,
        value = defaultValue,
        minValue = minValue,
        maxValue = maxValue,

        connections = { }
    }

    return setmetatable(state, StateValue) :: State
end

function StateValue:get()
    return self.value :: number & string & boolean
end

function StateValue:set(value: number | string | boolean | { [any]: any })

    if type(value) == "number" then
        if self.minValue and value < self.minValue then
            value = self.minValue
        elseif self.maxValue and value > self.maxValue then
            value = self.maxValue
        end
    elseif type(value) == "table" then
        value = deepCopy(value)
    end

    self.value = value :: number | string | boolean | { [any]: any }

    callConnections(self, self.value :: number & string & boolean & { [any]: any })

    return nil
end

function StateValue:reset()
    self:set(self.default)

    return nil
end

function StateValue:connect(connectionName: string, callback: (value: number & string & boolean & { [any]: any }) -> nil)
    assert(type(connectionName) == "string", "connectionName must be a string")
    assert(type(callback) == "function", "callback must be a function")

    assert(not self.connections[connectionName], "connectionName already exists")

    self.connections[connectionName] = callback

    task.defer(callback, self.value :: number & string & boolean & { [any]: any })

    return nil
end

function StateValue:disconnect(connectionName: string)
    self.connections[connectionName] = nil

    return nil
end

return StateValue
