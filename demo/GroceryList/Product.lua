--// Globals
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fission = require(ReplicatedStorage.Fission)

local New, Value, Computed, peek, Children, OnEvent, Out, OnChange = Fission.New, Fission.Value, Fission.Computed, Fission.peek, Fission.Children, Fission.OnEvent, Fission.Out, Fission.OnChange

--// Content
local function Product(props)
    return New "Frame" {
        Name = props.name,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0.07),
        SizeConstraint = Enum.SizeConstraint.RelativeXX,

        [Children] = {
            New "TextLabel" {
                Name = "TextLabel",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                Size = UDim2.fromScale(0.56, 0.9),
                Text = props.name,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
            },

            New "UIListLayout" {
                Name = "UIListLayout",
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0.02, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            },

            New "TextBox" {
                Name = "Qty",
                BackgroundColor3 = Color3.fromRGB(203, 203, 203),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json"),
                Size = UDim2.fromScale(0.2, 1),
                Text = Computed(function(use)
                    return use(props.productInfo).qty or ""
                end),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Right,
                ClearTextOnFocus = true,

                [OnChange "Text"] = function(newText)
                    props.setQty(tonumber(newText))
                end,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.2, 0),
                    },

                    New "UIPadding" {
                        Name = "UIPadding",
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0.07, 0),
                        PaddingRight = UDim.new(0.07, 0),
                        PaddingTop = UDim.new(0.151, 0),
                    },
                }
            },

            New "TextBox" {
                Name = "Price",
                BackgroundColor3 = Color3.fromRGB(203, 203, 203),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json"),
                Size = UDim2.fromScale(0.2, 1),
                Text = Computed(function(use)
                    return use(props.productInfo).price or ""
                end),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Right,
                ClearTextOnFocus = true,

                [OnChange "Text"] = function(newText)
                    props.setPrice(tonumber(newText))
                end,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.2, 0),
                    },

                    New "UIPadding" {
                        Name = "UIPadding",
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0.07, 0),
                        PaddingRight = UDim.new(0.07, 0),
                        PaddingTop = UDim.new(0.151, 0),
                    },
                }
            },
        }
    }
end

return Product