local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, peek = Fission.Value, Fission.Computed, Fission.peek

return function ()
    local it = getfenv().it
    describe("peek", function()
        it("returns Value value", function()
            local a = Value(1)
            expect(peek(a)).to.be.equal(1)
        end)
        it("does not cause updates", function()
            local a = Value(1)
            local compt = 0
            local b = Computed(function(use)
                local c = use(a)
                compt += 1
            end)
            peek(a)
            peek(a)
            peek(a)
            expect(compt).to.be.equal(1)
        end)
    end)
end