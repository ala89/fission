local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, peek = Fission.Value, Fission.Computed, Fission.peek

return function ()
    local it = getfenv().it
    describe("example", function()
        it("should prune the update graph when a node's value is unchanged", function()
            local counter = 0

            local a = Value(0)
            local b = Computed(function(use)
                counter += 1
                use(a)
                return 1
            end)
            local c = Computed(function(use)
                counter += 1
                return use(b)
            end)
            local d = Computed(function(use)
                counter += 1
                return use(c)
            end)

            a:set(1)

            expect(counter).to.be.equal(4)
        end)

        it("should handle multiple blocking nodes", function()
            local switch = false

            local a = Value(0)
            local b = Computed(function(use)
                return use(a)
            end)
            local c = Computed(function(use)
                if switch == false then
                    return use(a)
                else
                    return use(a) + use(b)
                end
            end)
            local d = Computed(function(use)
                if switch == false then
                    return use(a)
                else
                    return use(a) + use(c)
                end
            end)

            switch = true
            a:set(1)

            expect(peek(d)).to.be.equal(3)
        end)

        it("should handle nested updates properly", function()
            local i = 0
            local aa = Value(1)
            local b = Value()
            local a = Computed(function(use)
                b:set(i)
                i += 1
                return use(aa)
            end)
            local c = Computed(function(use)
                return use(a) + use(b)
            end)
            local d = Computed(function(use)
                return use(a) + use(c)
            end)
            local e = Computed(function(use)
                return use(b) + use(c)
            end)

            expect(peek(d)).to.be.equal(2)
            expect(peek(e)).to.be.equal(1)

            aa:set(2)

            expect(peek(d)).to.be.equal(5)
            expect(peek(e)).to.be.equal(4)
        end)

        it("should handle nested updates properly even if it causes recursion", function()
            local a = Value(0)
            local b = Computed(function(use)
                local av = use(a)
                if av < 10 then
                    a:set(av + 1)
                end
            end)

            expect(peek(a)).to.be.equal(10)
        end)
    end)
end