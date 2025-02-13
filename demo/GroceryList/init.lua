--// Globals
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fission = require(ReplicatedStorage.Fission)

local Product = require(script.Product)

local New, Value, Computed, peek, Children, OnEvent, Out, Table = Fission.New, Fission.Value, Fission.Computed, Fission.peek, Fission.Children, Fission.OnEvent, Fission.Out, Fission.Table

--// Content
local function GroceryList()
    local list = Value({})
    local addText = Value("")

    local function addProduct(productName)
        if productName == "" then return end
        local newState = table.clone(peek(list))
        newState[productName] = { price = 1, qty = 1 }
        list:set(newState)
    end

    return New "Frame" {
        Name = "Wrapper",
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(600, 0),

        [Children] = {
            New "Frame" {
                Name = "AddWrapper",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 2,
                Size = UDim2.fromScale(1, 0.07),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                [Children] = {
                    New "TextBox" {
                        Name = "TextBox",
                        BackgroundColor3 = Color3.fromRGB(203, 203, 203),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        CursorPosition = -1,
                        FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json"),
                        Size = UDim2.fromScale(0.69, 1),
                        Text = addText,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = true,

                        [Out "Text"] = addText,

                        [OnEvent "FocusLost"] = function(isEnter)
                            if isEnter then
                                addProduct(peek(addText))
                            end
                        end,

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0.2, 0),
                            },

                            New "UIPadding" {
                                Name = "UIPadding",
                                PaddingBottom = UDim.new(0.15, 0),
                                PaddingLeft = UDim.new(0.03, 0),
                                PaddingRight = UDim.new(0.03, 0),
                                PaddingTop = UDim.new(0.151, 0),
                            },
                        }
                    },

                    New "TextButton" {
                        Name = "TextButton",
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = Color3.fromRGB(106, 198, 19),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.fromScale(0.3, 1),
                        Text = "Add",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,

                        [OnEvent "Activated"] = function()
                            addProduct(peek(addText))
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
                }
            },

            New "TextLabel" {
                Name = "TextLabel",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                Size = UDim2.fromScale(1, 0.1),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Text = "Groceries",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
            },

            New "UIListLayout" {
                Name = "UIListLayout",
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            },

            New "Frame" {
                Name = "List",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 5,
                Size = UDim2.fromScale(1, 0),

                [Children] = {
                    Table(list, function(use, name, productInfo)
                        return Product {
                            name = name,
                            productInfo = productInfo,
                            setPrice = function(newPrice)
                                local newList = table.clone(peek(list))
                                local newProductInfo = table.clone(newList[name])
                                newProductInfo.price = newPrice
                                newList[name] = newProductInfo
                                list:set(newList)
                            end,
                            setQty = function(newQty)
                                local newList = table.clone(peek(list))
                                local newProductInfo = table.clone(newList[name])
                                newProductInfo.qty = newQty
                                newList[name] = newProductInfo
                                list:set(newList)
                            end
                        }
                    end, Fission.cleanup, Fission.defaultEq, Fission.shallowEq),

                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
                }
            },

            New "Frame" {
                Name = "Separator",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 0, 1),
            },

            New "Frame" {
                Name = "Separator",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 4,
                Size = UDim2.new(1, 0, 0, 1),
            },

            New "Frame" {
                Name = "Frame",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 3,
                Size = UDim2.fromScale(1, 0.07),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                [Children] = {
                    New "TextLabel" {
                        Name = "TextLabel",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                        LayoutOrder = 3,
                        Size = UDim2.fromScale(0.56, 1),
                        Text = "List",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    },

                    New "TextLabel" {
                        Name = "TextLabel",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                        LayoutOrder = 3,
                        Size = UDim2.fromScale(0.2, 0.8),
                        Text = "Qty",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    },

                    New "UIListLayout" {
                        Name = "UIListLayout",
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0.02, 0),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },

                    New "TextLabel" {
                        Name = "TextLabel",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                        LayoutOrder = 3,
                        Size = UDim2.fromScale(0.2, 0.8),
                        Text = "Price (€)",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    },
                }
            },

            New "TextLabel" {
                Name = "TextLabel",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                LayoutOrder = 7,
                Size = UDim2.fromScale(1, 0.08),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Text = Computed(function(use)
                    local tot = 0
                    for _, productInfo in use(list) do
                        if use(productInfo).price and use(productInfo).qty then
                            tot += use(productInfo).price * use(productInfo).qty
                        end
                    end
                    return `Total: {tot}€`
                end),
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Right,
            },

            New "Frame" {
                Name = "Separator",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                LayoutOrder = 6,
                Size = UDim2.new(1, 0, 0, 1),
            },
        }
    }
end

return GroceryList