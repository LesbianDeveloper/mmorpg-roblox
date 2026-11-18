local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Items = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Items"))
local hotbarAction = ReplicatedStorage:WaitForChild("HotbarAction")
local notify = ReplicatedStorage:WaitForChild("Notify")
local player = Players.LocalPlayer

local SLOTS = 6
local SIZE = 58
local KEYS = {
	[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5, [Enum.KeyCode.Six] = 6,
}
local GOLD = Color3.fromRGB(255, 200, 90)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, SLOTS * (SIZE + 6) - 6, 0, SIZE)
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, -48)
bar.BackgroundTransparency = 1
bar.Parent = UIKit.Gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = bar

local slots = {}
for i = 1, SLOTS do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, SIZE, 0, SIZE)
	button.LayoutOrder = i
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	button.BackgroundTransparency = 0.15
	button.Text = ""
	button.Parent = bar
	UIKit.corner(button, 8)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	local number = UIKit.label(button, tostring(i), UDim2.new(0, 14, 0, 14), UDim2.new(0, 4, 0, 2), 11, Color3.fromRGB(160, 160, 160))
	number.TextXAlignment = Enum.TextXAlignment.Left
	local name = UIKit.label(button, "", UDim2.new(1, -6, 1, -24), UDim2.new(0, 3, 0, 12), 11)
	name.TextWrapped = true
	local count = UIKit.label(button, "", UDim2.new(1, -6, 0, 14), UDim2.new(0, 3, 1, -16), 12)
	count.TextXAlignment = Enum.TextXAlignment.Right

	button.MouseButton1Click:Connect(function()
		hotbarAction:FireServer("select", i)
	end)
	button.MouseButton2Click:Connect(function() -- clic derecho: vaciar el slot
		UIKit.request("hotbar_clear", i)
	end)

	slots[i] = { stroke = stroke, name = name, count = count }
end

local snapshot = nil

local function redraw()
	local active = player:GetAttribute("ActiveSlot") or 1
	for i, ui in slots do
		local itemId = snapshot and snapshot.Hotbar and snapshot.Hotbar[tostring(i)]
		local item = itemId and Items[itemId]
		if item then
			local quantity = snapshot.Items[itemId] or 0
			local rarity = UIKit.RARITY[item.Rarity] or UIKit.RARITY.Common
			ui.name.Text = item.Name
			ui.name.TextColor3 = rarity.Color
			ui.name.TextTransparency = quantity > 0 and 0 or 0.6 -- gris si no te queda
			ui.count.Text = item.Type == "Consumable" and ("x" .. quantity) or ""
		else
			ui.name.Text = ""
			ui.count.Text = ""
		end
		ui.stroke.Color = i == active and GOLD or Color3.fromRGB(80, 80, 80)
		ui.stroke.Thickness = i == active and 3 or 1.5
	end
end

UIKit.DataChanged:Connect(function(newSnapshot)
	snapshot = newSnapshot
	redraw()
end)
player:GetAttributeChangedSignal("ActiveSlot"):Connect(redraw)

-- Cuando llega loot o se usa una poción, se actualizan las cantidades
notify.OnClientEvent:Connect(function()
	UIKit.request("get")
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local slot = KEYS[input.KeyCode]
	if slot then
		hotbarAction:FireServer("select", slot)
	end
end)

-- Primera carga, cuando los datos del jugador ya están
while player:GetAttribute("CharacterCreated") == nil do
	task.wait(0.2)
end
UIKit.request("get")