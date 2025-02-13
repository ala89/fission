local Root = script.Parent.Parent
local Observer = require(Root.Graph.Observer)
local peek = require(Root.Graph.peek)
local cleanup = require(Root.Util.cleanup)
local Tools = require(Root.Util.Tools)
local ferror, ftypeof =Tools.ferror, Tools.ftypeof
local isState = require(Root.Util.isState)

local function safeAssign(instance, key, value):nil
	local ok, err = pcall(function() 
		instance[key] = value 
	end)
	if not ok then
		ferror(`Can not assign {value} to {key} in {instance} : {err}`)
	end
end

local function applyPropsTable(instance, props)
    local toClean = {}

    local specialKeys = {
        self = {},
        observer = {}
    }

    for key, value in props do
        local typee = ftypeof(key)
        if typee == "string" then
            if isState(value) then
                safeAssign(instance, key, peek(value))
                local toBeUpdated = false
                table.insert(toClean, Observer(value):onChange(function ()
                    -- If the value associated to key has not been
                    -- updated during this frame, then we need to
                    -- update it. Else, nothing has to be done.
                    if not toBeUpdated then
                        toBeUpdated = true
                        task.defer(function()
                            toBeUpdated = false
                            safeAssign(instance, key, peek(value))
                        end)
                    end
                end))
            else
                safeAssign(instance, key, value)
            end
        elseif typee == "SpecialKey" then
            specialKeys[key.stage][key] = value
        else
            ferror(`Invalid key type: {typee}`)
        end
    end

    for _, stage in { "self", "observer" } do
        for key, value in specialKeys[stage] do
            key:apply(value, instance, toClean)
        end
    end

    -- Destroy the references once this instances is destroyed
    table.insert(toClean, instance.Destroying:Once(function()
        cleanup(toClean)
    end))

    return toClean
end

return applyPropsTable