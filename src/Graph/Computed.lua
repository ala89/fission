local Root = script.Parent.Parent
local Core = require(Root.Core)
local cleanup = require(Root.Util.cleanup)
local defaultEq = require(Root.Util.defaultEq)
local isState = require(Root.Util.isState)
local FEnum = require(Root.Util.FEnum)
local Types = require(Root.Types)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}
local WEAK_VALUES_METATABLE = {__mode = "v"}

function class:peek()
    return self.value
end

function class:update()
    for dependency, type in self.dependencySet do
        if type == FEnum.DEPENDENCY_TYPE.DEFAULT then
            self.dependencySet[dependency] = nil
            dependency.dependentSet[self] = nil
        end
    end

    self.destructor(self.cleanupTasks)
    table.clear(self.cleanupTasks)

    Core:pushProcessor(self)

    local newValue = self.processor(self:makeUseCallback())
    Core:popProcessor()

    table.insert(self.cleanupTasks, newValue)

    local hasChanged = not self.eqFn(newValue, self.value)

    if hasChanged then
        self.oldValue = self.value
        self.value = newValue
    end

    return hasChanged
end

function class:makeUseCallback()
    return function (obj: any)
        if isState(obj) then
            self:addDependency(obj, FEnum.DEPENDENCY_TYPE.DEFAULT)

            if Core.isUpdate then
                return Core:resolveNode(obj)
            else
                return obj:peek()
            end
        else
            return obj
        end
    end
end

function class:destroy()
    for dependency in self.dependencySet do
        dependency.dependentSet[self] = nil
    end

    self.destructor(self.cleanupTasks)

    if Core.isUpdate then
        Core.counter[self] = nil
    end
end

function class:addDependency(dependency, type)
    self.dependencySet[dependency] = type
    dependency.dependentSet[self] = type
end

local function Computed<T>(processor: (Types.Use) -> T, destructor: Types.Destructor, eqFn: Types.EqFn): Types.State<T>
    local self = setmetatable({
        type = "State",
        processor = processor,
        destructor = destructor or cleanup,
        eqFn = eqFn or defaultEq,

        value = nil,
        oldValue = nil,
        dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
        dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
        cleanupTasks = setmetatable({}, WEAK_VALUES_METATABLE)
    }, CLASS_METATABLE)

    do
        local buildNode = Core:getCurrentProcessorNode()
        if buildNode then
            self:addDependency(buildNode, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            table.insert(buildNode.cleanupTasks, self)
        end
    end

    self:update()

    return self
end

return Computed