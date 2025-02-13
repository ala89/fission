local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ferror, ftypeof = Tools.ferror, Tools.ftypeof
local Types = require(Root.Types)

local function AttributeOut(attributeName: string): Types.SpecialKey
	local OutKey = {}
	OutKey.type = "SpecialKey"
	OutKey.stage = "observer"

	function OutKey:apply(targetState, instance, toClean)
		local ok, event = pcall(instance.GetAttributeChangedSignal, instance, attributeName)

		if not ok then
			ferror(`Cannot connect to attribute {attributeName} change`)
		elseif ftypeof(targetState) ~= "State" or typeof(targetState.set) ~= "function" then
			ferror(`Invalid value for AttributeOut special key, expected Value`)
		else
			targetState:set(instance:GetAttribute(attributeName))
			table.insert(toClean, event:Connect(function()
				targetState:set(instance:GetAttribute(attributeName))
			end))
			-- don't set the state to nil on cleanup
		end
	end

	return OutKey
end

return AttributeOut