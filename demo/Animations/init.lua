--// Globals
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fission = require(ReplicatedStorage.Fission)

local New, Value, Computed, peek, Children, OnEvent, Out, Table, Tween, Persistent = Fission.New, Fission.Value, Fission.Computed, Fission.peek, Fission.Children, Fission.OnEvent, Fission.Out, Fission.Table, Fission.Tween, Fission.Persistent

local ANIMATION_DURATION = 0.5
local ENTER_TWEEN_INFO = TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Back)
local EXIT_TWEEN_INFO = TweenInfo.new(ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local COLORS = { Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1) }

--// Content
local function Animations()
    local slideInBlock = Value(false)
    local colorBlock = Value(COLORS[1])
    local sizeBlock = Value(false)
    local rotBlock = Value(0)
    
    return {
        New "Frame" {
            Name = "Wrapper",
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(600, 0),

            [Children] = {
                New "TextButton" {
                    Name = "Button",
                    Size = UDim2.fromOffset(70, 70),
                    Text = "Toggle",
                    BorderSizePixel = 1,
                    TextScaled = true,

                    [OnEvent "Activated"] = function()
                        slideInBlock:set(not peek(slideInBlock))
                    end
                },

                New "Frame" {
                    Name = "Frame",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(70, 150),
                
                    [Children] = {
                        New "TextButton" {
                            Name = "TextButton",
                            BorderSizePixel = 1,
                            BorderColor3 = Color3.new(),
                            Size = UDim2.fromOffset(70, 70),
                            Text = "Click",
                            TextScaled = true,

                            [OnEvent "Activated"] = function()
                                colorBlock:set(COLORS[table.find(COLORS, peek(colorBlock)) % #COLORS + 1])
                            end
                        },

                        New "Frame" {
                            Name = "Frame",
                            BackgroundColor3 = Tween(colorBlock, TweenInfo.new(2)),
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(0, 80),
                            Size = UDim2.fromOffset(70, 70),
                        }
                    }
                },

                New "Frame" {
                    Name = "Frame",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(70, 150),
                
                    [Children] = {
                        New "TextButton" {
                            Name = "TextButton",
                            BorderSizePixel = 1,
                            BorderColor3 = Color3.new(),
                            Size = UDim2.fromOffset(70, 70),
                            Text = "Click",
                            TextScaled = true,

                            [OnEvent "Activated"] = function()
                                sizeBlock:set(not peek(sizeBlock))
                            end
                        },

                        New "Frame" {
                            Name = "Frame",
                            BackgroundColor3 = Color3.new(1, 1, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(0, 80),
                            Size = Tween(Computed(function(use)
                                return use(sizeBlock) and UDim2.fromOffset(70, 140) or UDim2.fromOffset(70, 70)
                            end), TweenInfo.new(1, Enum.EasingStyle.Bounce)),
                        }
                    }
                },

                New "Frame" {
                    Name = "Frame",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(70, 150),
                
                    [Children] = {
                        New "TextButton" {
                            Name = "TextButton",
                            BorderSizePixel = 1,
                            BorderColor3 = Color3.new(),
                            Size = UDim2.fromOffset(70, 70),
                            Text = "Click",
                            TextScaled = true,

                            [OnEvent "Activated"] = function()
                                rotBlock:set(peek(rotBlock) + 90)
                            end
                        },

                        New "Frame" {
                            Name = "Frame",
                            BackgroundColor3 = Color3.new(0, 1, 1),
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(0, 80),
                            Size = UDim2.fromOffset(70, 70),
                            Rotation = Tween(rotBlock, TweenInfo.new(0.7, Enum.EasingStyle.Linear))
                        }
                    }
                },

                New "UIListLayout" {
                    Name = "UIListLayout",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0.05, 0)
                }
            }
        },

        Persistent(function(use)
            if use(slideInBlock) then
                return New "Frame" {
                    Size = UDim2.fromOffset(50, 50),
                    BorderSizePixel = 1,
                    BackgroundColor3 = Color3.new(),
                    Position = Tween(Computed(function(use)
                        return use(slideInBlock) and UDim2.fromScale(0.7, 0.5) or UDim2.fromScale(0.7, 1.5)
                    end), Computed(function(use)
                        return use(slideInBlock) and ENTER_TWEEN_INFO or EXIT_TWEEN_INFO
                    end), UDim2.fromScale(0.7, 1.5))
                }
            end
        end, 1, Fission.cleanup)
    }
end

return Animations