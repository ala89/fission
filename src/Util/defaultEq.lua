local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ftypeof = Tools.ftypeof

local function defaultEq(a: any, b: any): boolean
    if ftypeof(a) == "table" then
        return false
    else
        return a == b
    end
end

return defaultEq