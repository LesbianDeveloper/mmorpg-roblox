local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Items = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Items"))
local notify = ReplicatedStorage:WaitForChild("Notify")
local RARITY = UIKit.RARITY

local window, content, entry = UIKit.createWindow("Inventory", "Inventario", UDim2.new(0, 440, 0, 420))

local currency = UIKit.label(content, "", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), 15, Color3.fromRGB(255, 210, 60))

local grid = Instance.new("ScrollingFrame")
grid.Size = UDim2.new(1, 0, 1, -76)
grid.Position = UDim2.new(0, 0, 0, 26)
grid.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
grid.BorderSizePixel = 0
grid.ScrollBarThickness = 6
grid.CanvasSize = UDim2.new()
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
grid.Parent = content
UIKit.corner(grid, 6)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.Parent = grid

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 92, 0, 92)
layout.CellPadding = UDim2.new(0, 8, 0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local emptyLabel = UIKit.label(content, "Tu inventario está vacío.\nDerrotá enemigos para conseguir materiales.",
	UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 120), 14, Color3.fromRGB(150, 150, 150))

local footer = UIKit.label(content, "", UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 1, -46), 14)
footer.TextWrapped = true

local function makeSlot(itemId, quantity, order)
	local item = Items[itemId] or { Name = itemId, Type = "Material", Rarity = "Common" }
	local rarity = RARITY[item.Rarity] or RARITY.Common

	local slot = Instance.new("TextButton")
	slot.Name = "Slot"
	slot.Text = ""
	slot.AutoButtonColor = item.Slot ~= nil
	slot.LayoutOrder = order
	slot.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	slot.Parent = grid
	UIKit.corner(slot, 6)
	UIKit.stroke(slot, rarity.Color, 2)

	local name = UIKit.label(slot, item.Name, UDim2.new(1, -8, 1, -24), UDim2.new(0, 4, 0, 4), 13, rarity.Color)
	name.TextWrapped = true
	local qty = UIKit.label(slot, "x" .. quantity, UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 1, -22), 14)
	qty.TextXAlignment = Enum.TextXAlignment.Right

	slot.MouseEnter:Connect(function()
		local text = string.format("%s  —  %s · %s", item.Name, UIKit.TYPE_NAMES[item.Type] or item.Type, rarity.Name)
		if item.Stats then
			text ..= "\n" .. UIKit.describeStats(item.Stats) .. "   (clic para equipar)"
		end
		footer.Text = text
		footer.TextColor3 = rarity.Color
	end)
	slot.MouseLeave:Connect(function()
		footer.Text = ""
	end)

	if item.Slot then
		slot.MouseButton1Click:Connect(function()
			footer.Text = ""
			UIKit.request("equip", itemId)
		end)
	end
end

local function redraw(snapshot)
	currency.Text = string.format("Oro: %d     ·     Runas del Destino: %d", snapshot.Gold or 0, snapshot.Runes or 0)

	for _, child in grid:GetChildren() do
		if child.Name == "Slot" then child:Destroy() end
	end

	local entries = {}
	for itemId, quantity in snapshot.Items do
		if quantity > 0 then
			table.insert(entries, { id = itemId, qty = quantity })
		end
	end
	table.sort(entries, function(a, b)
		local ra = (RARITY[(Items[a.id] or {}).Rarity] or RARITY.Common).Order
		local rb = (RARITY[(Items[b.id] or {}).Rarity] or RARITY.Common).Order
		if ra ~= rb then return ra > rb end
		return a.id < b.id
	end)

	for i, e in entries do
		makeSlot(e.id, e.qty, i)
	end
	emptyLabel.Visible = #entries == 0
end

UIKit.DataChanged:Connect(redraw)

entry.onOpen = function()
	footer.Text = ""
	UIKit.request("get")
end

notify.OnClientEvent:Connect(function()
	if window.Visible then
		UIKit.request("get")
	end
end)