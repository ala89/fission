local Root = script.Parent.Parent
local Core = require(Root.Core)
local Scheduler = require(Root.Animation.Scheduler)
local Tools = require(Root.Util.Tools)
local peek = require(Root.Graph.peek)
local FEnum = require(Root.Util.FEnum)
local ferror, ftypeof = Tools.ferror, Tools.ftypeof
local Types = require(Root.Types)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

function class:update()
	local targetValue = peek(self.targetState)

	if targetValue == self.nextValue and not self.currentlyAnimating then
		return false
	end

	local tweenInfo = peek(self.tweenInfo)

	if ftypeof(tweenInfo) ~= "TweenInfo" then
        ferror(`Invalid Tween argument 2, expected TweenInfo, got {typeof(tweenInfo)}`)
        return false
	end

	self.prevValue = self.currentValue
	self.nextValue = targetValue

	self:beginAnimation()

	return false
end

function class:beginAnimation()
	local tweenInfo = peek(self.tweenInfo)

	self.currentTweenStartTime = os.clock()
	self.currentTweenInfo = tweenInfo

	local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		tweenDuration += tweenInfo.Time
	end
	tweenDuration *= tweenInfo.RepeatCount + 1
	self.currentTweenDuration = tweenDuration

	Scheduler.add(self)
end

function class:peek()
	return self.currentValue
end

function class:destroy()
    for dependency in self.dependencySet do
        dependency.dependentSet[self] = nil
    end

	Scheduler.remove(self)

    if Core.isUpdate then
        Core.counter[self] = nil
    end
end

function class:addDependency(dependency, type)
    self.dependencySet[dependency] = type
    dependency.dependentSet[self] = type
end

local function Tween<T>(targetState: Types.State<T>, tweenInfo: Types.CanBeState<TweenInfo>?, startValue: T?): Types.State<T>
	if not tweenInfo then
		tweenInfo = TweenInfo.new()
	end

	if typeof(peek(tweenInfo)) ~= "TweenInfo" then
		ferror(`Invalid Tween argument 2, expected TweenInfo, got {typeof(peek(tweenInfo))}`)
	end

	local targetValue = peek(targetState)
	local initialValue = targetValue
	if typeof(startValue) ~= "nil" then
		initialValue = startValue
	end

	local self = setmetatable({
		type = "State",
		targetState = targetState,
		tweenInfo = tweenInfo,
		startValue = startValue,

		prevValue =  initialValue,
		nextValue = targetValue,
		currentValue = initialValue,

		dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		currentTweenInfo = tweenInfo,
		currentTweenDuration = 0,
		currentTweenStartTime = 0,
		currentlyAnimating = false
	}, CLASS_METATABLE)

	self:addDependency(targetState, FEnum.DEPENDENCY_TYPE.DEFAULT)
	if ftypeof(tweenInfo) == "State" then
		self:addDependency(tweenInfo, FEnum.DEPENDENCY_TYPE.DEFAULT)
	end

	do
        local buildNode = Core:getCurrentProcessorNode()
        if buildNode then
            self:addDependency(buildNode, FEnum.DEPENDENCY_TYPE.VIRTUAL_FORCED)
            table.insert(buildNode.cleanupTasks, self)
        end
    end

	if self.currentValue ~= self.nextValue then
		self:beginAnimation()
	end

	return self
end

return Tween