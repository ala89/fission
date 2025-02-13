local function isState(obj: any): boolean
    return typeof(obj) == "table" and typeof(obj.peek) == "function"
end

return isState