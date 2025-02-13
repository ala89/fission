local RunService = game:GetService("RunService")

local Root = script.Parent.Parent
local Core = require(Root.Core)
local lerpType = require(Root.Animation.lerpType)
local getTweenRatio = require(Root.Animation.getTweenRatio)

local WEAK_KEYS_METATABLE = {__mode = "k"}

local Scheduler = {
    _tweens = setmetatable({}, WEAK_KEYS_METATABLE)
}

function Scheduler.add(tween)
	Scheduler._tweens[tween] = true
end

function Scheduler.remove(tween)
	Scheduler._tweens[tween] = nil
end

RunService.RenderStepped:Connect(function()
    local now = os.clock()
	for tween in Scheduler._tweens do
		local currentTime = now - tween.currentTweenStartTime

		if currentTime > tween.currentTweenDuration and tween.currentTweenInfo.RepeatCount > -1 then
			if tween.currentTweenInfo.Reverses then
				tween.currentValue = tween.prevValue
			else
				tween.currentValue = tween.nextValue
			end
			tween.currentlyAnimating = false
			Core:propagate(tween)
			Scheduler.remove(tween)
		else
			local ratio = getTweenRatio(tween.currentTweenInfo, currentTime)
			local currentValue = lerpType(tween.prevValue, tween.nextValue, ratio)
			tween.currentValue = currentValue
			tween.currentlyAnimating = true
			Core:propagate(tween)
		end
	end
end)

return Scheduler