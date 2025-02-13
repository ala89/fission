local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local New, OnChange, Value = Fission.New, Fission.OnChange, Fission.Value

return function ()
    local it = getfenv().it
    describe("OnEvent", function()
        it("it should react to new events", function()
            local changes = 0
            local dynamicSize = Value(1)
            local label = New "TextLabel" {
                TextSize = dynamicSize,
                [OnChange "TextSize"] = function()
                    changes += 1
                end
            }
            expect(changes).to.be.equal(0)
            dynamicSize:set(2)
            task.wait()
            expect(changes).to.be.equal(1)
        end)
        it("it should yield an error on wrong inputs", function()
            local childs = 0
            expect(function()
                local label = New "TextLabel" {
                    [OnChange "TextSize"]
                = 7
                }
            end).to.throw("[Fission] Event handler is not a function")

            expect(function()
                local label = New "TextLabel" {
                    [OnChange "foo"] = function() end
                }
            end).to.throw("[Fission] foo is not a valid Property")
        end)
    end)
end