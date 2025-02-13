local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ferror = Tools.ferror
local Types = require(Root.Types)

local function OnChange(propertyName: string): Types.SpecialKey
    local Change = {}
    Change.type = "SpecialKey"
    Change.stage = "observer"

    function Change:apply(value, instance, toClean)
        local ok, event = pcall(instance.getPropertyChangedSignal, instance, propertyName)

        if typeof(value) ~= "function" then
            ferror("Event handler is not a function")
        elseif not ok then
            ferror(`{propertyName} is not a valid Property`)
        else
            table.insert(toClean, event:Connect(function()
				value(instance[propertyName])
			end))
        end
    end

    return Change
end

return OnChange