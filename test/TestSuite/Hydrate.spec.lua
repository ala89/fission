local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, New, Hydrate = Fission.Value, Fission.Computed,  Fission.New, Fission.Hydrate


return function ()
    local it = getfenv().it
    describe("Hydrate", function()
        it("should be initialized corrrectly on normal keys", function()
            local textLabel = Instance.new("TextLabel")

            local size = Value(1)
            Hydrate(textLabel) {
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
            local textLabel = Instance.new("TextLabel")

            local value = Value(1)
            local size = Computed(function(use)
                return use(value) + 1
            end)
            Hydrate(textLabel) {
                TextSize = size
            }

            expect(textLabel.TextSize).to.be.equal(2)
            value:set(2)
            task.wait()
            expect(textLabel.TextSize).to.be.equal(3)
        end)
        it("should stop updating after disconnection", function()
            local textLabel = Instance.new("TextLabel")

            local size = Value(1)
            local disconnect = Hydrate(textLabel) {
                TextSize = size
            }

            expect(textLabel.TextSize).to.be.equal(1)
            size:set(2)
            task.wait()
            expect(textLabel.TextSize).to.be.equal(2)
            disconnect()
            size:set(3)
            task.wait()
            expect(textLabel.TextSize).to.be.equal(2)
        end)
    end)
end