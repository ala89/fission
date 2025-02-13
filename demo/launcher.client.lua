--// Globals
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Fission = require(ReplicatedStorage.Fission)

local GroceryList = require(script.Parent.GroceryList)
local Animations = require(script.Parent.Animations)

local New, Value, Computed, Children, OnEvent = Fission.New, Fission.Value, Fission.Computed, Fission.Children, Fission.OnEvent

--// Content
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local currentDemo = Value()

New "ScreenGui" {
    Name = "ScreenGui",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    IgnoreGuiInset = true,
  
    [Children] = {
        New "Frame" {
            Name = "Background",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
    
            [Children] = {
                Computed(function(use)
                    if use(currentDemo) == "GroceryList" then
                        return GroceryList {}
                    elseif use(currentDemo) == "Animations" then
                        return Animations {}
                    else
                        return New "Frame" {
                            Name = "Wrapper",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(500, 0),
                
                            [Children] = {
                                New "Frame" {
                                    Name = "List",
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    LayoutOrder = 1,
                                    Size = UDim2.fromScale(1, 0),
                    
                                    [Children] = {
                                        New "TextButton" {
                                            Name = "TextButton",
                                            BackgroundColor3 = Color3.fromRGB(0, 255, 85),
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                            Size = UDim2.fromScale(1, 0.1),
                                            SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                            Text = "Grocery List",
                                            TextColor3 = Color3.fromRGB(255, 255, 255),
                                            TextScaled = true,
                                            TextSize = 14,
                                            TextWrapped = true,

                                            [OnEvent "Activated"] = function()
                                                currentDemo:set("GroceryList")
                                            end,
                        
                                            [Children] = {
                                                New "UICorner" {
                                                    Name = "UICorner",
                                                    CornerRadius = UDim.new(0.2, 0),
                                                },
                            
                                                New "UIPadding" {
                                                    Name = "UIPadding",
                                                    PaddingBottom = UDim.new(0.1, 0),
                                                    PaddingTop = UDim.new(0.1, 0),
                                                },
                                            }
                                        },

                                        New "TextButton" {
                                            Name = "TextButton",
                                            BackgroundColor3 = Color3.fromRGB(0, 255, 85),
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                                            Size = UDim2.fromScale(1, 0.1),
                                            SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                            Text = "Animations",
                                            TextColor3 = Color3.fromRGB(255, 255, 255),
                                            TextScaled = true,
                                            TextSize = 14,
                                            TextWrapped = true,

                                            [OnEvent "Activated"] = function()
                                                currentDemo:set("Animations")
                                            end,
                        
                                            [Children] = {
                                                New "UICorner" {
                                                    Name = "UICorner",
                                                    CornerRadius = UDim.new(0.2, 0),
                                                },
                            
                                                New "UIPadding" {
                                                    Name = "UIPadding",
                                                    PaddingBottom = UDim.new(0.1, 0),
                                                    PaddingTop = UDim.new(0.1, 0),
                                                },
                                            }
                                        },
                        
                                        New "UIListLayout" {
                                            Name = "UIListLayout",
                                            Padding = UDim.new(0.1, 0),
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        },
                                    }
                                },
                    
                                New "TextLabel" {
                                    Name = "TextLabel",
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json"),
                                    Size = UDim2.fromScale(1, 0.12),
                                    SizeConstraint = Enum.SizeConstraint.RelativeXX,
                                    Text = "Fission demo",
                                    TextColor3 = Color3.fromRGB(0, 0, 0),
                                    TextScaled = true,
                                    TextSize = 14,
                                    TextWrapped = true,
                                },
                    
                                New "UIListLayout" {
                                    Name = "UIListLayout",
                                    Padding = UDim.new(0.2, 0),
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                            }
                        }
                    end
                end, Fission.cleanup)
            }
        },
    }
}