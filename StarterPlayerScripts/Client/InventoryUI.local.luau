local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared:WaitForChild("Items"))
local request = ReplicatedStorage:WaitForChild("InventoryRequest")
local notify = ReplicatedStorage:WaitForChild("Notify")
local player = Players.LocalPlayer

local RARITY = {
	Common    = { Name = "Común",      Order = 1, Color = Color3.fromRGB(200, 200, 200) },
	Uncommon  = { Name = "Poco común", Order = 2, Color = Color3.fromRGB(90, 220, 90) },
	Rare      = { Name = "Raro",       Order = 3, Color = Color3.fromRGB(80, 150, 255) },
	Epic      = { Name = "Épico",      Order = 4, Color = Color3.fromRGB(190, 90, 255) },
	Legendary = { Name = "Legendario", Order = 5, Color = Color3.fromRGB(255, 150, 40) },
	Mythic    = { Name = "Mítico",     Order = 6, Color = Color3.fromRGB(255, 60, 60) },
}
local TYPE_NAMES = { Material = "Material", Currency = "Moneda", Weapon = "Arma", Armor = "Armadura" }

---------------------------------------------------------------- Helpers de UI
local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

local function label(parent, text, size, position, textSize, color)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = textSize
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.Font = Enum.Font.GothamBold
	l.Parent = parent
	return l
end

---------------------------------------------------------------- Ventana
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Size = UDim2.new(0, 440, 0, 380)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
window.BorderSizePixel = 0
window.Visible = false
window.Parent = gui
corner(window, 8)
stroke(window, Color3.fromRGB(120, 100, 60), 2)

local title = label(window, "Inventario", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 6), 22, Color3.fromRGB(235, 210, 150))

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -36, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = window
corner(closeButton, 6)

local currency = label(window, "", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 44), 15, Color3.fromRGB(255, 210, 60))

local grid = Instance.new("ScrollingFrame")
grid.Size = UDim2.new(1, -24, 1, -110)
grid.Position = UDim2.new(0, 12, 0, 72)
grid.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
grid.BorderSizePixel = 0
grid.ScrollBarThickness = 6
grid.CanvasSize = UDim2.new()
grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
grid.Parent = window
corner(grid, 6)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.Parent = grid

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 92, 0, 92)
layout.CellPadding = UDim2.new(0, 8, 0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local emptyLabel = label(grid, "Tu inventario está vacío.\nDerrotá enemigos para conseguir materiales.",
	UDim2.new(1, -16, 0, 60), UDim2.new(0, 0, 0, 40), 14, Color3.fromRGB(150, 150, 150))
emptyLabel.Parent = window -- fuera de la grilla para que el layout no lo acomode
emptyLabel.Position = UDim2.new(0, 8, 0, 140)

local footer = label(window, "", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 1, -32), 15)

---------------------------------------------------------------- Casillas
local function makeSlot(itemId, quantity, order)
	local item = Items[itemId] or { Name = itemId, Type = "Material", Rarity = "Common" }
	local rarity = RARITY[item.Rarity] or RARITY.Common

	local slot = Instance.new("Frame")
	slot.Name = "Slot"
	slot.LayoutOrder = order
	slot.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	slot.Parent = grid
	corner(slot, 6)
	stroke(slot, rarity.Color, 2)

	local name = label(slot, item.Name, UDim2.new(1, -8, 1, -24), UDim2.new(0, 4, 0, 4), 13, rarity.Color)
	name.TextWrapped = true

	local qty = label(slot, "x" .. quantity, UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 1, -22), 14)
	qty.TextXAlignment = Enum.TextXAlignment.Right

	slot.MouseEnter:Connect(function()
		footer.Text = string.format("%s  —  %s · %s", item.Name, TYPE_NAMES[item.Type] or item.Type, rarity.Name)
		footer.TextColor3 = rarity.Color
	end)
	slot.MouseLeave:Connect(function()
		footer.Text = ""
	end)
end

local function refresh()
	local data = request:InvokeServer("get")
	if not data then return end

	currency.Text = string.format("Oro: %d     ·     Runas del Destino: %d", data.Gold or 0, data.Runes or 0)

	for _, child in grid:GetChildren() do
		if child.Name == "Slot" then child:Destroy() end
	end

	-- Ordenar: primero lo más raro, después por nombre
	local entries = {}
	for itemId, quantity in data.Items do
		if quantity > 0 then
			table.insert(entries, { id = itemId, qty = quantity })
		end
	end
	table.sort(entries, function(a, b)
		local ra = RARITY[(Items[a.id] or {}).Rarity or "Common"].Order
		local rb = RARITY[(Items[b.id] or {}).Rarity or "Common"].Order
		if ra ~= rb then return ra > rb end
		return a.id < b.id
	end)

	for i, entry in entries do
		makeSlot(entry.id, entry.qty, i)
	end
	emptyLabel.Visible = #entries == 0
end

---------------------------------------------------------------- Abrir / cerrar
local function toggle()
	window.Visible = not window.Visible
	footer.Text = ""
	if window.Visible then
		refresh()
	end
end

closeButton.MouseButton1Click:Connect(toggle)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- ignora si estás escribiendo en el chat
	if input.KeyCode == Enum.KeyCode.B then
		toggle()
	end
end)

-- Si está abierto y te llega loot, se actualiza
notify.OnClientEvent:Connect(function()
	if window.Visible then
		refresh()
	end
end)