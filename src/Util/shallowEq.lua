local Root = script.Parent.Parent
local Tools = require(Root.Util.Tools)
local ftypeof = Tools.ftypeof

local function shallowEq(a: any, b: any): boolean
    if ftypeof(a) == "table" and ftypeof(b) == "table" then
        for ka, va in a do
            if b[ka] ~= va then
                return false
            end
        end

        for kb, vb in b do
            if a[kb] ~= vb then
                return false
            end
        end

        return true
    else
        return a == b
    end
end

return shallowEq