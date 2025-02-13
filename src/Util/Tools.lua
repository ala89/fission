-- Returns the type of the the fission object
local function ftypeof(object)
    local typee = typeof(object)
    if  typee == "table" and typeof(object.type) == "string" then
        return object.type
    else
        return typee
    end
end

local function ferror(msg)
    error("[Fission] "..msg)
end

return {
    ftypeof = ftypeof,
    ferror = ferror
}