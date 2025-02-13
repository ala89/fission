local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ferror = Tools.ferror
local Types = require(Root.Types)

local function OnEvent(eventName:string): Types.SpecialKey
    local Event = {}
    Event.type = "SpecialKey"
    Event.stage = "observer"

    function Event:apply(value, instance, toClean)
        local ok, event = pcall(function (instance, eventName)
            return instance[eventName]
        end, instance, eventName)

        if typeof(value) ~= "function" then
            ferror("Event handler is not a function")
        elseif not ok or typeof(event) ~= "RBXScriptSignal" then
            ferror(`{eventName} is not a valid Event`)
        else
            table.insert(toClean, event:connect(value))
        end
    end

    return Event
end

return OnEvent