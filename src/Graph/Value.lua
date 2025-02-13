local Root = script.Parent.Parent
local Core = require(Root.Core)
local defaultEq = require(Root.Util.defaultEq)
local Types = require(Root.Types)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:set(newValue: any)
    local oldValue = self.value
    if not self.eqFn(oldValue, newValue) then
        self.oldValue = self.value
        self.value = newValue
        Core:propagate(self)
    end
end

function class:peek()
    return self.value
end

local function Value<T>(initialValue: T, eqFn: Types.EqFn): Types.Value<T>
    local self = setmetatable({
        type = "State",
        eqFn = eqFn or defaultEq,

        value = initialValue,
        oldValue = nil,
        dependentSet = setmetatable({}, WEAK_KEYS_METATABLE)
    }, CLASS_METATABLE)

    return self
end

return Value