local Root = script.Parent.Parent
local isState =  require(Root.Util.isState)
local peek = require(Root.Graph.peek)
local Observer = require(Root.Graph.Observer)

local Children = {}
Children.type = "SpecialKey"
Children.stage = "self"

function Children:apply(keyValue, instance, toClean)

    local oldObservers = {}
    local newObservers = {}
    local oldInstances = {}
    local newInstances = {}

    local toBeUpdated = false

    local function globalProcessing()

        oldInstances = newInstances
        oldObservers = newObservers
        newObservers, newInstances = {}, {}

        local function recursiveProcessing(value)

            if isState(value) then
                local current = peek(value)

                if not oldObservers[value] then
                    newObservers[value] = Observer(value):onChange(function ()
                        if not toBeUpdated then
                            toBeUpdated = true
                            task.defer(function()
                                toBeUpdated = false
                                globalProcessing()
                            end)
                        end
                    end)
                else
                    newObservers[value]= oldObservers[value]
                    oldObservers[value] = nil
                end
                recursiveProcessing(current)

            elseif typeof(value) == "Instance" then

                if not oldInstances[value] then
                    value.Parent = instance
                else
                    oldInstances[value] = nil
                end

                newInstances[value] = true

            elseif typeof(value) == "table" then
                for _, current in value do
                    recursiveProcessing(current)
                end
            end
        end

        recursiveProcessing(keyValue)

        for _, observer in oldObservers do
            observer()
        end

        for instance, _ in oldInstances do
            instance.Parent = nil
        end
    end

    table.insert(toClean, function()
        for _, observer in oldObservers do
            observer()
        end
    end)

    globalProcessing()
end

return Children