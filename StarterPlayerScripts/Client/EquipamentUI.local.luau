local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Items = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Items"))
local player = Players.LocalPlayer

local SLOTS = {
	{ Id = "Weapon", Name = "Arma" },
	{ Id = "Head",   Name = "Cabeza" },
	{ Id = "Chest",  Name = "Pecho" },
	{ Id = "Legs",   Name = "Piernas" },
}
local STAT_LINES = {
	{ "MaxHealth", "Vida máxima" }, { "MaxStamina", "Estamina máxima" },
	{ "Strength", "Fuerza" }, { "Agility", "Agilidad" }, { "Intellect", "Intelecto" },
	{ "Vitality", "Vitalidad" }, { "Endurance", "Aguante" },
	{ "Defense", "Defensa" }, { "WeaponDamage", "Daño de arma" },
}

local window, content, entry = UIKit.createWindow("Equipment", "Equipo", UDim2.new(0, 480, 0, 380))

---------------------------------------------------------------- Slots (izquierda)
local slotButtons = {}
for i, slotInfo in SLOTS do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 220, 0, 62)
	button.Position = UDim2.new(0, 0, 0, (i - 1) * 70)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	button.Text = ""
	button.Parent = content
	UIKit.corner(button, 6)
	local strokeObj = Instance.new("UIStroke")
	strokeObj.Thickness = 2
	strokeObj.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	strokeObj.Parent = button

	local slotName = UIKit.label(button, slotInfo.Name, UDim2.new(1, -12, 0, 18), UDim2.new(0, 8, 0, 4), 12, Color3.fromRGB(160, 160, 160))
	slotName.TextXAlignment = Enum.TextXAlignment.Left
	local itemName = UIKit.label(button, "", UDim2.new(1, -12, 0, 20), UDim2.new(0, 8, 0, 22), 15)
	itemName.TextXAlignment = Enum.TextXAlignment.Left
	local itemStats = UIKit.label(button, "", UDim2.new(1, -12, 0, 16), UDim2.new(0, 8, 0, 42), 11, Color3.fromRGB(180, 180, 180))
	itemStats.TextXAlignment = Enum.TextXAlignment.Left
	itemStats.TextTruncate = Enum.TextTruncate.AtEnd

	button.MouseButton1Click:Connect(function()
		UIKit.request("unequip", slotInfo.Id)
	end)

	slotButtons[slotInfo.Id] = { stroke = strokeObj, name = itemName, stats = itemStats }
end

local hint = UIKit.label(content, "Clic en un slot para desequipar.\nEquipá desde el inventario (B).",
	UDim2.new(0, 220, 0, 36), UDim2.new(0, 0, 0, 282), 12, Color3.fromRGB(140, 140, 140))

---------------------------------------------------------------- Stats (derecha)
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, -236, 1, 0)
statsPanel.Position = UDim2.new(0, 236, 0, 0)
statsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
statsPanel.Parent = content
UIKit.corner(statsPanel, 6)

UIKit.label(statsPanel, "Atributos", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 6), 16, Color3.fromRGB(235, 210, 150))
local statLabels = {}
for i, line in STAT_LINES do
	local l = UIKit.label(statsPanel, "", UDim2.new(1, -24, 0, 22), UDim2.new(0, 12, 0, 6 + i * 26), 14)
	l.TextXAlignment = Enum.TextXAlignment.Left
	statLabels[line[1]] = { label = l, name = line[2] }
end

local function refreshStats()
	for attribute, info in statLabels do
		info.label.Text = info.name .. ":  " .. tostring(player:GetAttribute(attribute) or 0)
	end
end

player.AttributeChanged:Connect(function()
	if window.Visible then refreshStats() end
end)

---------------------------------------------------------------- Redibujar
local function redraw(snapshot)
	for slotId, ui in slotButtons do
		local itemId = snapshot.Equipment[slotId]
		local item = itemId and Items[itemId]
		if item then
			local rarity = UIKit.RARITY[item.Rarity] or UIKit.RARITY.Common
			ui.name.Text = item.Name
			ui.name.TextColor3 = rarity.Color
			ui.stroke.Color = rarity.Color
			ui.stats.Text = UIKit.describeStats(item.Stats)
		else
			ui.name.Text = "— vacío —"
			ui.name.TextColor3 = Color3.fromRGB(110, 110, 110)
			ui.stroke.Color = Color3.fromRGB(70, 70, 70)
			ui.stats.Text = ""
		end
	end
	refreshStats()
end

UIKit.DataChanged:Connect(redraw)

entry.onOpen = function()
	UIKit.request("get")
end