local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local isState = require(Root.Util.isState)
local peek = require(Root.Graph.peek)
local Observer = require(Root.Graph.Observer)
local ferror, ftypeof = Tools.ferror, Tools.ftypeof
local Types = require(Root.Types)

local function safeAssign(instance, attributeName, value)
	local ok, err = pcall(function()
		instance:SetAttribute(attributeName, value)
	end)
	if not ok then
		ferror(`Can not set attribute {attributeName} to {value} in {instance} : {err}`)
	end
end

local function Attribute(attributeName: string): Types.SpecialKey
	local OutKey = {}
	OutKey.type = "SpecialKey"
    OutKey.stage = "self"

	function OutKey:apply(value, instance, toClean)
		if isState(value) then
            safeAssign(instance, attributeName, peek(value))
            local toBeUpdated = false
            table.insert(toClean, Observer(value):onChange(function ()
                if not toBeUpdated then
                    toBeUpdated = true
                    task.defer(function()
                        toBeUpdated = false
                        safeAssign(instance, attributeName, peek(value))
                    end)
                end
            end))
        else
            safeAssign(instance, attributeName, value)
        end
	end

	return OutKey
end

return Attribute