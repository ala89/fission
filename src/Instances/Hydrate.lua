local Root = script.Parent.Parent
local applyPropsTable = require(Root.Instances.applyPropsTable)
local cleanup = require(Root.Util.cleanup)
local Types = require(Root.Types)

local function Hydrate(instance: Instance): (table) -> Instance
	return function(props)
		local toClean = applyPropsTable(instance, props)
		return function ()
            cleanup(toClean)
        end
	end
end

return Hydrate