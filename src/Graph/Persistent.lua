local Root = script.Parent.Parent
local Core = require(Root.Core)
local Computed = require(Root.Graph.Computed)
local cleanup = require(Root.Util.cleanup)
local defaultEq = require(Root.Util.defaultEq)
local doNothing = require(Root.Util.doNothing)
local FEnum = require(Root.Util.FEnum)
local Types = require(Root.Types)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:update()
	local newValue = self.state:peek()

    if newValue ~= nil then
		if self.pendingDestruction then
			self.destructor(self.cleanupTasks)
			self.pendingDestruction = nil
		end
	elseif self.value ~= nil then
		self.pendingDestruction = self.value

		if self.thread then task.cancel(self.thread) end
		self.thread = task.delay(self.duration, self.destructor, self.cleanupTasks)
	end

	self.value = newValue
	self.cleanupTasks = table.clone(self.state.cleanupTasks)

	return true
end

function class:peek()
	return { self.value, self.pendingDestruction }
end

function class:addDependency(dependency, type)
    self.dependencySet[dependency] = type
    dependency.dependentSet[self] = type
end

local function Persistent<T>(processor: (Types.Use) -> T, duration: number, destructor: Types.Destructor, eqFn: Types.EqFn): Types.State<T>
	local state = Computed(processor, doNothing, eqFn)

	local self = setmetatable({
		type = "State",
		destructor = destructor or cleanup,
		duration = duration,
		eqFn = eqFn or defaultEq,

		state = state,
		value = state:peek(),
		pendingDestruction = nil,
		dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		cleanupTasks = table.clone(state.cleanupTasks),
		thread = nil
	}, CLASS_METATABLE)

	self:addDependency(state, FEnum.DEPENDENCY_TYPE.DEFAULT)

	do
        local buildNode = Core:getCurrentProcessorNode()
        if buildNode then
            self:addDependency(buildNode, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            table.insert(buildNode.cleanupTasks, self)
        end
    end

	return self
end

return Persistent