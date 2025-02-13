local Root = script.Parent.Parent
local Core = require(Root.Core)
local peek = require(Root.Graph.peek)
local defaultEq = require(Root.Util.defaultEq)
local cleanup = require(Root.Util.cleanup)
local doNothing = require(Root.Util.doNothing)
local Computed = require(Root.Graph.Computed)
local FEnum = require(Root.Util.FEnum)
local Types = require(Root.Types)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}
local WEAK_VALUES_METATABLE = {__mode = "v"}

function class:update()
    local hasChanged = false
    local inputTable = peek(self.inputTable)

    for key in inputTable do
        if self.cache[key] == nil then
            local val = Computed(function(use)
                return use(self.inputTable)[key]
            end, doNothing, self.valEqFn)
            local processor = Computed(function(use)
                return self.processor(use, key, val)
            end, self.destructor, self.eqFn)

            processor:addDependency(self, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)

            self.cleanupTasks.processors[key] = processor
            self.cleanupTasks.values[key] = val
            self.cache[key] = true

            hasChanged = true
        end
    end

    for cachedKey in self.cache do
        if inputTable[cachedKey] == nil then
            self.destructor(self.cleanupTasks.processors[cachedKey])
            self.destructor(self.cleanupTasks.values[cachedKey])
            self.cleanupTasks.processors[cachedKey] = nil
            self.cleanupTasks.values[cachedKey] = nil
            self.cache[cachedKey] = nil
            hasChanged = true
        end
    end

    return hasChanged
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

function class:peek()
    error("[Fusion] Internal error, :peek() called on Table")
end

function class:addDependency(dependency, type)
    self.dependencySet[dependency] = type
    dependency.dependentSet[self] = type
end

local function Table<TK, TV, T>(inputTable: Types.State<{[TK]: TV}>, processor: (Types.Use, TK, Types.State<TV>) -> T, destructor: Types.Destructor, eqFn: Types.EqFn, valEqFn: Types.EqFn): Types.State<{[TK]: T}>
    local self = setmetatable({
        type = "State",
        inputTable = inputTable,
        processor = processor,
        destructor = destructor or cleanup,
        eqFn = eqFn or defaultEq,
        valEqFn = valEqFn or defaultEq,

        cache = {},
        dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
        dependentSet = {},
        cleanupTasks = {
            processors = setmetatable({}, WEAK_VALUES_METATABLE),
            values = setmetatable({}, WEAK_VALUES_METATABLE)
        },
    }, CLASS_METATABLE)

    self:addDependency(inputTable, FEnum.DEPENDENCY_TYPE.DEFAULT)

    do
        local buildNode = Core:getCurrentProcessorNode()
        if buildNode then
            self:addDependency(buildNode, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            table.insert(buildNode.cleanupTasks, self)
        end
    end

    self:update()

    local join = Computed(function(use)
        local res = {}
        for key in self.cache do
            res[key] = use(self.cleanupTasks.processors[key])
        end
        return res
    end, doNothing)

    join:addDependency(self, FEnum.DEPENDENCY_TYPE.DEFAULT_FORCED)

    return join
end

return Table