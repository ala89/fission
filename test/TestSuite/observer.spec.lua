local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, Observer, peek = Fission.Value, Fission.Computed, Fission.Observer, Fission.peek

return function ()
    local it = getfenv().it
    describe("example", function()
        it("should detect updates", function()
            local a = Value(0)

            local b = Computed(function(use)
                return use(a) + 1
            end)

            local res1 = nil
            local res2 = nil
            
            Observer(a):onChange(function()
                res1 = peek(a)
            end)

            Observer(b):onChange(function()
                res2 = peek(b)
            end)

            a:set(2)
            expect(res1).to.be.equal(2)
            expect(res2).to.be.equal(3)
            a:set(5)
            expect(res1).to.be.equal(5)
            expect(res2).to.be.equal(6)
        end)

        it("should not detect updates when there's no change", function()
            local a = Value(0)

            local b = Computed(function(use)
                use(a)
                return 1
            end)

            local counter = 0
            
            Observer(a):onChange(function()
                counter += 1
            end)

            Observer(b):onChange(function()
                counter += 1
            end)

            a:set(0)
            expect(counter).to.be.equal(0)
            a:set(1)
            expect(counter).to.be.equal(1)
        end)

        it("should run the callback initially with onBind", function()
            local a = Value(0)

            local counter = 0
            
            Observer(a):onBind(function()
                counter += 1
            end)

            expect(counter).to.be.equal(1)
            a:set(1)
            expect(counter).to.be.equal(2)
        end)

        it("should support multiple watched states", function()
            local a = Value(0)
            local b = Value(1)

            local counter = 0

            Observer({ a, b }):onChange(function()
                counter += 1
            end)

            a:set(1)
            expect(counter).to.be.equal(1)
            a:set(2)
            expect(counter).to.be.equal(2)
        end)

        it("update once even if several dependencies change", function()
            local a = Value(0)

            local b = Computed(function(use)
                return use(a) + 1
            end)

            local c = Computed(function(use)
                return use(a) + 2
            end)

            local counter = 0

            Observer({ a, b }):onChange(function()
                counter += 1
            end)

            a:set(1)
            expect(counter).to.be.equal(1)
            a:set(2)
            expect(counter).to.be.equal(2)
        end)

        it("should not trigger after cleanup", function()
            local a = Value(nil)

            local counter = 0

            local b = Computed(function(use)
                if use(a) ~= nil then
                    Observer({ a }):onChange(function()
                        counter += 1
                    end)
                end
            end)

            a:set(1)
            expect(counter).to.be.equal(0)
            a:set(2)
            expect(counter).to.be.equal(0)
            a:set(nil)
            expect(counter).to.be.equal(0)
        end)
    end)
end