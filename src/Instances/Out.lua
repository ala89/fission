local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ferror, ftypeof = Tools.ferror, Tools.ftypeof
local Types = require(Root.Types)

local function Out(propertyName: string): Types.SpecialKey
	local OutKey = {}
	OutKey.type = "SpecialKey"
	OutKey.stage = "observer"

	function OutKey:apply(targetState, instance, toClean)
		local ok, event = pcall(instance.GetPropertyChangedSignal, instance, propertyName)
		if not ok then
			ferror(`{propertyName} is not a valid Property`)
		elseif ftypeof(targetState) ~= "State" or typeof(targetState.set) ~= "function" then
			ferror(`Invalid value for Out special key, expected Value`)
		else
			targetState:set(instance[propertyName])
			table.insert(toClean, event:Connect(function()
				targetState:set(instance[propertyName])
			end))
			-- don't set the state to nil on cleanup
		end
	end

	return OutKey
end

return Out