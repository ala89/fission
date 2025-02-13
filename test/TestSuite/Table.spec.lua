local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, Table, peek = Fission.Value, Fission.Computed, Fission.Table, Fission.peek

return function ()
    local it = getfenv().it
    describe("Table", function()
        it("should detect new variables appearing", function()
            local table = Value({
                abc = 123,
                def = 456,
            })
            local transformed = Table(table, function(use, key, value)
                local newValue = key .. use(value)
                return newValue
            end)
            local transformed_out = peek(transformed)
            expect(transformed_out.abc).to.be.equal("abc123")
            expect(transformed_out.def).to.be.equal("def456")
            table:set({
                abc = 123,
                ghi = 789,
                def = 456,
            })
            local transformed_out_2 = peek(transformed)
            expect(transformed_out_2.abc).to.be.equal("abc123")
            expect(transformed_out_2.def).to.be.equal("def456")
            expect(transformed_out_2.ghi).to.be.equal("ghi789")
        end)
        it("should detect variables disappearing", function()
            local table = Value({
                abc = 123,
                ghi = 789,
                def = 456,
            })
            local transformed = Table(table, function(use, key, value)
                local newValue = key .. use(value)
                return newValue
            end)
            local transformed_out = peek(transformed)
            expect(transformed_out.abc).to.be.equal("abc123")
            expect(transformed_out.def).to.be.equal("def456")
            expect(transformed_out.ghi).to.be.equal("ghi789")
            table:set({
                abc = 123,
                def = 456,
            })
            local transformed_out_2 = peek(transformed)
            expect(transformed_out_2.abc).to.be.equal("abc123")
            expect(transformed_out_2.def).to.be.equal("def456")
            expect(transformed_out_2.ghi).never.to.be.ok()
        end)
        it("should detect variables changing", function()
            local table = Value({
                abc = 123,
                ghi = 789,
                def = 456,
            })
            local transformed = Table(table, function(use, key, value)
                local newValue = key .. use(value)
                return newValue
            end)
            local transformed_out = peek(transformed)
            expect(transformed_out.abc).to.be.equal("abc123")
            expect(transformed_out.def).to.be.equal("def456")
            expect(transformed_out.ghi).to.be.equal("ghi789")
            table:set({
                abc = 123,
                ghi = 999,
                def = 456,
            })
            local transformed_out_2 = peek(transformed)
            expect(transformed_out_2.abc).to.be.equal("abc123")
            expect(transformed_out_2.def).to.be.equal("def456")
            expect(transformed_out_2.ghi).to.be.equal("ghi999")
        end)
        it("should work with embedded dependencies", function()
            local table = Value({
                abc = 123,
                ghi = 789,
                def = 456,
            })
            local x = Value(0)
            local transformed = Table(table, function(use, key, value)
                local a = Computed(function(use)
                    return use(value) + use(x)
                end)
                local newValue = key .. (use(a) + use(x))
                return newValue
            end)
            local transformed_out = peek(transformed)
            expect(transformed_out.abc).to.be.equal("abc123")
            expect(transformed_out.def).to.be.equal("def456")
            expect(transformed_out.ghi).to.be.equal("ghi789")
            table:set({
                abc = 123,
                ghi = 999,
                def = 456,
            })
            local transformed_out_2 = peek(transformed)
            expect(transformed_out_2.abc).to.be.equal("abc123")
            expect(transformed_out_2.def).to.be.equal("def456")
            expect(transformed_out_2.ghi).to.be.equal("ghi999")
            x:set(1)
            local transformed_out_3 = peek(transformed)
            expect(transformed_out_3.abc).to.be.equal("abc125")
            expect(transformed_out_3.def).to.be.equal("def458")
            expect(transformed_out_3.ghi).to.be.equal("ghi1001")
        end)
        it("should not perform unnecessary updates", function()
            local t = Value({
                a = 1,
                b = 2,
                c = 3
            })
            
            local counter = 0
            
            local t2 = Table(t, function(use, key, val)
                counter += 1
                return use(val) * 2
            end)
    
            expect(counter).to.be.equal(3)
                    
            t:set({
                a = 1,
                b = 2,
                c = 3,
                d = 4
            })
            
            expect(counter).to.be.equal(4)

            t:set({
                a = 2,
                b = 2,
                c = 3,
                d = 4
            })

            expect(counter).to.be.equal(5)

            t:set({
                a = 2,
                c = 4,
                d = 4
            })

            expect(counter).to.be.equal(6)

            t:set({
                a = 2
            })

            expect(counter).to.be.equal(6)
        end)
        it("should cleanup properly when a key is deleted", function()
            expect(function()
                local t = Value({
                    a = "a"
                })
    
                local t2 = Table(t, function(use, key, val)
                    return use(val).."b"
                end)
    
                t:set({})
            end).never.to.throw()
        end)
    end)
end