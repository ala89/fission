local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ferror = Tools.ferror
local Types = require(Root.Types)

local function AttributeChange(attributeName: string): Types.SpecialKey
    local Change = {}
    Change.type = "SpecialKey"
    Change.stage = "observer"

    function Change:apply(value, instance, toClean)
        local ok, event = pcall(instance.GetAttributeChangedSignal, instance, attributeName)

        if typeof(value) ~= "function" then
            ferror("AttributeChange handler is not a function")
        elseif not ok then
            ferror(`Cannot connect to attribute {attributeName} change`)
        else
            table.insert(toClean, event:Connect(function()
                value(instance:GetAttribute(attributeName))
            end))
        end
    end

    return Change
end

return AttributeChange