local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, Table, peek, Tween, New = Fission.Value, Fission.Computed, Fission.Table, Fission.peek, Fission.Tween, Fission.New

return function ()
    local it = getfenv().it
    describe("Tween", function()
        it("should handle destruction properly", function()
            expect(function()
                local a = Value(true)
                local b = Computed(function(use)
                    local c = use(a) and New "TextLabel" {
                        TextColor3 = Tween(Computed(function(use)
                            if not use(a) then
                                error()
                            end
                            return use(a) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                        end), TweenInfo.new())
                    }
                end)
    
                a:set(false)
            end).never.to.throw()
        end)
    end)
end