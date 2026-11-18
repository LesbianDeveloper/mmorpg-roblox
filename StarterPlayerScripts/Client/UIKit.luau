local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local request = ReplicatedStorage:WaitForChild("InventoryRequest")
local player = Players.LocalPlayer

local UIKit = {}

UIKit.RARITY = {
	Common    = { Name = "Común",      Order = 1, Color = Color3.fromRGB(200, 200, 200) },
	Uncommon  = { Name = "Poco común", Order = 2, Color = Color3.fromRGB(90, 220, 90) },
	Rare      = { Name = "Raro",       Order = 3, Color = Color3.fromRGB(80, 150, 255) },
	Epic      = { Name = "Épico",      Order = 4, Color = Color3.fromRGB(190, 90, 255) },
	Legendary = { Name = "Legendario", Order = 5, Color = Color3.fromRGB(255, 150, 40) },
	Mythic    = { Name = "Mítico",     Order = 6, Color = Color3.fromRGB(255, 60, 60) },
}
UIKit.TYPE_NAMES = { Material = "Material", Currency = "Moneda", Weapon = "Arma", Armor = "Armadura", Consumable = "Consumible" }
UIKit.STAT_NAMES = {
	Strength = "Fuerza", Agility = "Agilidad", Intellect = "Intelecto",
	Vitality = "Vitalidad", Endurance = "Aguante", Defense = "Defensa", WeaponDamage = "Daño de arma",
}

local gui = Instance.new("ScreenGui")
gui.Name = "GameUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
UIKit.Gui = gui

---------------------------------------------------------------- Helpers
function UIKit.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

function UIKit.stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

function UIKit.label(parent, text, size, position, textSize, color)
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

function UIKit.describeStats(stats)
	local parts = {}
	for stat, value in stats or {} do
		table.insert(parts, (UIKit.STAT_NAMES[stat] or stat) .. " +" .. value)
	end
	table.sort(parts)
	return table.concat(parts, " · ")
end

---------------------------------------------------------------- Ventanas
local windows = {}

function UIKit.createWindow(name, titleText, size)
	local window = Instance.new("Frame")
	window.Name = name
	window.Size = size
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	window.BorderSizePixel = 0
	window.Visible = false
	window.Parent = gui
	UIKit.corner(window, 8)
	UIKit.stroke(window, Color3.fromRGB(120, 100, 60), 2)

	UIKit.label(window, titleText, UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 6), 22, Color3.fromRGB(235, 210, 150))

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Position = UDim2.new(1, -36, 0, 8)
	close.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	close.Text = "X"
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.Parent = window
	UIKit.corner(close, 6)

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -24, 1, -56)
	content.Position = UDim2.new(0, 12, 0, 46)
	content.BackgroundTransparency = 1
	content.Parent = window

	local entry = { frame = window, onOpen = nil }
	windows[name] = entry
	close.MouseButton1Click:Connect(function()
		UIKit.toggle(name)
	end)
	return window, content, entry
end

-- Abre una ventana y cierra las demás (o la cierra si ya estaba abierta)
function UIKit.toggle(name)
	local entry = windows[name]
	if not entry then return end
	local open = not entry.frame.Visible
	for _, other in windows do
		other.frame.Visible = false
	end
	entry.frame.Visible = open
	if open and entry.onOpen then
		entry.onOpen()
	end
end

---------------------------------------------------------------- Datos
local changed = Instance.new("BindableEvent")
UIKit.DataChanged = changed.Event -- se dispara con el estado nuevo del inventario y equipo

function UIKit.request(action, value)
	local snapshot = request:InvokeServer(action or "get", value)
	if snapshot then
		changed:Fire(snapshot)
	end
	return snapshot
end

return UIKit