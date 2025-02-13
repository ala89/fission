local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fission = require(ReplicatedStorage.Fission)
local Value, Computed, Children, New, Persistent, peek = Fission.Value, Fission.Computed, Fission.Children, Fission.New, Fission.Persistent, Fission.peek

return function ()
    local it = getfenv().it
    describe("New", function()
        it("should cleanup after the specified duration when the processor returns nil", function()
            local switch = Value(false)

            local a = New "TextLabel" {
                [Children] = Persistent(function(use)
                    return use(switch) and Instance.new("TextLabel") or nil
                end, 1, Fission.cleanup)
            }

            switch:set(true)
            task.wait()
            expect(a:FindFirstChildWhichIsA("TextLabel")).to.be.ok()
            switch:set(false)
            task.wait(0.5)
            expect(a:FindFirstChildWhichIsA("TextLabel")).to.be.ok()
            task.wait(0.6)
            expect(a:FindFirstChildWhichIsA("TextLabel")).never.to.be.ok()
        end)
        it("should cleanup immediately when the processor returns a new value", function()
            local switch = Value(false)

            local a = New "TextLabel" {
                [Children] = Persistent(function(use)
                    local Child = Instance.new("TextLabel")
                    if use(switch) then
                        Child.Name = "Child2"
                    else
                        Child.Name = "Child1"
                    end
                    return Child
                end, 1, Fission.cleanup)
            }

            expect(#a:GetChildren()).to.be.equal(1)
            expect(a:FindFirstChildWhichIsA("TextLabel").Name).to.be.equal("Child1")
            switch:set(true)
            task.wait()
            expect(#a:GetChildren()).to.be.equal(1)
            expect(a:FindFirstChildWhichIsA("TextLabel").Name).to.be.equal("Child2")
            switch:set(false)
            task.wait()
            expect(#a:GetChildren()).to.be.equal(1)
            expect(a:FindFirstChildWhichIsA("TextLabel").Name).to.be.equal("Child1")
        end)
    end)
end