local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local New, OnEvent = Fission.New, Fission.OnEvent

return function ()
    local it = getfenv().it
    describe("OnEvent", function()
        it("it should react to new events", function()
            local children = 0
            local label = New "TextLabel" {
                [OnEvent "ChildAdded"] = function()
                    children += 1
                end
            }
            expect(children).to.be.equal(0)
            local child = New "TextLabel" {
                Parent = label
            }
            task.wait()
            expect(children).to.be.equal(1)
        end)
        it("it should yield an error on wrong inputs", function()
            local childs = 0
            expect(function()
                local label = New "TextLabel" {
                    [OnEvent "ChildAdded"]
                = 7
                }
            end).to.throw("[Fission] Event handler is not a function")

            expect(function()
                local label = New "TextLabel" {
                    [OnEvent "Foo"] = function() end
                }
            end).to.throw("[Fission] Foo is not a valid Event")
        end)
    end)
end