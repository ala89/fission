local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, peek = Fission.Value, Fission.Computed, Fission.peek

return function ()
    local it = getfenv().it
    describe("various graph are being tested", function()
        it("diamond graph should use the new value of a newly created Computed", function()
            local a = Value(1)
            local b = Computed(function(use)
                return use(a)
            end)
            local c = Computed(function(use)
                local d = Computed(function(use)
                    return use(b)
                end)
                return use(d)
            end)
            a:set(2)
            a:set(3)
            expect(peek(c)).to.be.equal(3)
        end)

        it("diamond graph should not be bothered by the deletion of a node", function()
            local a = Value(nil)
            local b = Computed(function(use)
                return use(a)
            end)
            local c = Computed(function(use)
                if use(a) ~= nil then
                    local d = Computed(function(use)
                        return use(b)
                    end)
                end
                    local d = Value(nil)
                return use(d)
            end)
            a:set("a")
            a:set(nil)
            expect(peek(c)).never.to.be.ok()
        end)
        it("3 nodes graphs should not bother computing values that were not updated in the middle", function()
            local count = 0
            local a = Value("a")
            local b = Computed(function(use)
                use(a)
                return 2
            end)
            local c = Computed(function(use)
                count += 1
                return use(b)
            end)
            a:set("b")
            a:set("c")
            expect(peek(count)).to.be.equal(1)
            expect(peek(c)).to.be.equal(2)
        end)

        it("graph can be dinamically updated", function()
            local switch = false
            local a = Value(2)

            local b = Computed(function(use)
                return use(a)
            end)

            local c = Computed(function(use)
                return use(a)
            end)

            local d = Computed(function(use)
                return use(c)
            end)

            local e = Computed(function(use)
                if switch == false then
                    return use(b)
                else
                    return use(b) + use(d)
                end
            end)

            expect(peek(e)).to.be.equal(2)
            switch = true
            a:set(4)
            expect(peek(e)).to.be.equal(8)
        end)

        it("diamond graph should support both creation and deletion of nodes", function()
            expect(function()
                local a = Value(nil)

                local c = Computed(function(use)
                    if use(a) ~= nil then
                        return use(a)
                    else
                        return nil
                    end
                end)

                local b = Computed(function(use)
                    local d = use(a) ~= nil and Computed(function(use)
                        return use(c) + 1
                    end)
                    return d
                end)

                a:set(0)
                a:set(nil)
            end).never.to.throw()
        end)

        it("update that does not modify branches should not create updates", function()
            local compt = 0
            local a = Value("a")
            local b = Computed(function(use)
                return nil ~= table.find({"a", "b"}, use(a)) 
            end)
            local c = Computed(function(use)
                compt += 1
                return use(b)
            end)
            expect(compt).to.be.equal(1)
            a:set("b")
            expect(compt).to.be.equal(1)
            a:set("c")
            expect(compt).to.be.equal(2)
        end)

        it("palm graph should not result in a deadlock", function()
            local a = Value(0)
            local b = Computed(function(use)
                return use(a)
            end)
            local c = Computed(function(use)
                if use(b) ~= nil then
                    return use(a)
                else
                    return nil
                end
            end)
            local d = Computed(function(use)
                if use(c) ~= nil then
                    return use(a)
                else
                    return nil
                end
            end)
            local e = Computed(function(use)
                if use(c) ~= nil then
                    return use(a)
                else
                    return nil
                end
            end)
            a:set(nil)
            expect(peek(e)).to.be.equal(nil)
            a:set(0)
            expect(peek(e)).to.be.equal(0)
        end)
    end)
end