local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, New = Fission.Value, Fission.Computed,  Fission.New


return function ()
    local it = getfenv().it
    describe("New", function()
        it("should be initialized corrrectly on normal keys", function()
            local size = Value(1)
            local textLabel = New "TextLabel" {
                Name = "label",
                Font = Enum.Font.Arial,
                TextSize = size
            }
            expect(textLabel.Name).to.be.equal("label")
            expect(textLabel.TextSize).to.be.equal(1)
            size:set(2)
            task.wait()
            expect(textLabel.TextSize).to.be.equal(2)
            expect(textLabel.Name).to.be.equal("label")
            expect(textLabel.Font).to.be.equal(Enum.Font.Arial)
        end)
        it("should react to graph updates", function()
            local value = Value(1)
            local size = Computed(function(use)
                return use(value) + 1
            end)
            local textLabel = New "TextLabel" {
                TextSize = size
            }
            expect(textLabel.TextSize).to.be.equal(2)
            value:set(2)
            task.wait()
            expect(textLabel.TextSize).to.be.equal(3)
        end)
    end)
end