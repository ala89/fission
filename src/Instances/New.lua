local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local applyPropsTable = require(Root.Instances.applyPropsTable)
local defaultProps = require(Root.Instances.defaultProps)
local ferror = Tools.ferror
local Types = require(Root.Types)

local function New(className: string): (table) -> Instance
	return function (props)
		local ok, instance = pcall(Instance.new, className)

		if not ok then
			ferror(`Can not instantiate {className}`)
		end

		local classDefaults = defaultProps[className]
		if classDefaults ~= nil then
			for key, val in classDefaults do
				instance[key] = val
			end
		end

		applyPropsTable(instance, props)

		return instance
	end
end

return New