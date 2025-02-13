local Root = script.Parent.Parent
local Core = require(Root.Core)
local isState = require(Root.Util.isState)
local FEnum = require(Root.Util.FEnum)
local Types = require(Root.Types)

local class = {}
local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

local strongRefs = {}

function class:onChange(callback)
    local uuid = table.freeze({})

    self.numListeners += 1
    self.listeners[uuid] = callback

    -- as long as there is at least one listener, prevent the observer from getting GCed
    strongRefs[self] = true

    local disconnected = false
    return function ()
        if disconnected then return end

        self.listeners[uuid] = nil
        self.numListeners -= 1

        if self.numListeners == 0 then
            strongRefs[self] = nil
        end

        disconnected = true
    end
end

function class:update()
    for _, callback in self.listeners do
        task.spawn(callback)
    end
    return false
end

function class:onBind(callback)
    task.spawn(callback)
    return self:onChange(callback)
end

function class:onDefer(callback)
    task.defer(callback)
    return self:onChange(callback)
end

function class:destroy()
    for dependency in self.dependencySet do
        dependency.dependentSet[self] = nil
    end

    if Core.isUpdate then
        Core.counter[self] = nil
    end
end

function class:addDependency(dependency, type)
    self.dependencySet[dependency] = type
    dependency.dependentSet[self] = type
end

local function Observer(watchedStates: {Types.State<any>} | Types.State<any>): Types.Observer
    local self = setmetatable({
        type = "State",
        dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
        dependentSet = {},

        listeners = {},
        numListeners = 0
    }, CLASS_METATABLE)

    if isState(watchedStates) then
        self:addDependency(watchedStates, FEnum.DEPENDENCY_TYPE.DEFAULT)
    else
        for _, watchedState in watchedStates do
            self:addDependency(watchedState, FEnum.DEPENDENCY_TYPE.DEFAULT)
        end
    end

    do
        local buildNode = Core:getCurrentProcessorNode()
        if buildNode then
            self:addDependency(buildNode, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            table.insert(buildNode.cleanupTasks, self)
        end
    end

    return self
end

return Observer