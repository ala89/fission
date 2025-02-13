local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Children, New, Value = Fission.Children, Fission.New, Fission.Value

return function ()
    local it = getfenv().it
    describe("New", function()
        it("should be initialized correctly on simple Children definition", function()
            local textLabel = New "TextLabel" {
                Name = "parentLabel",
                [Children] = {
                    New "TextLabel" {
                        Name = "label",
                        TextSize = 1
                    }
                }
            }
        end)
        it("should recursively apply to different Children keys", function()
            local textLabel = New "TextLabel" {
                [Children] = {
                    New "TextLabel" {},
                    New "TextLabel" {},
                    [Children] = {
                        New "TextLabel" {}
                    }
                }
            }
        end)
        it("should correctly react to deletion of nodes", function()
            local a = Value()

            local textLabel = New "TextLabel" {
                [Children] = {
                    a
                }
            }
            
            local b = Instance.new("TextLabel")

            a:set(b)
            task.wait()
            expect(textLabel:FindFirstChildWhichIsA("TextLabel")).to.be.equal(b)
            a:set(nil)
            task.wait()
            expect(textLabel:FindFirstChildWhichIsA("TextLabel")).to.be.equal(nil)
        end)
    end)
end
