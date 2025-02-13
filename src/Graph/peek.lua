local Root = script.Parent.Parent
local isState = require(Root.Util.isState)
local Types = require(Root.Types)

local function peek<T>(obj: Types.CanBeState<T>): T
    if isState(obj) then
        return obj:peek()
    else
        return obj
    end
end

return peek