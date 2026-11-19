local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local request = ReplicatedStorage:WaitForChild("SoulRequest")
local player = Players.LocalPlayer

local MAX_FLASKS = 3
local PURPLE = Color3.fromRGB(170, 120, 255)
local GREEN = Color3.fromRGB(90, 220, 90)
local RED = Color3.fromRGB(240, 80, 80)
local GREY = Color3.fromRGB(130, 130, 130)

local window, content, entry = UIKit.createWindow("Souls", "Almas", UDim2.new(0, 480, 0, 430))

local carriedLabel = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 0), 16, PURPLE)
UIKit.label(content, "La Esencia en un Alma no se pierde al morir. Liberala en un Santuario para gastarla.",
	UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 22), 12, GREY)

local status = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 1, -24), 14)

local function button(parent, text, x, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 96, 0, 30)
	b.Position = UDim2.new(0, x, 1, -38)
	b.BackgroundColor3 = color
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = parent
	UIKit.corner(b, 6)
	return b
end

local render -- se define abajo

local function act(action, index, amount)
	local ok, message, snap = request:InvokeServer(action, index, amount)
	status.Text = message or ""
	status.TextColor3 = ok and GREEN or RED
	if snap then render(snap) end
end

-- Tres tarjetas, una por frasco
local cards = {}
for i = 1, MAX_FLASKS do
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 104)
	card.Position = UDim2.new(0, 0, 0, 48 + (i - 1) * 112)
	card.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
	card.Parent = content
	UIKit.corner(card, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = card

	local title = UIKit.label(card, "", UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 6), 16)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local barBack = Instance.new("Frame")
	barBack.Size = UDim2.new(1, -20, 0, 14)
	barBack.Position = UDim2.new(0, 10, 0, 34)
	barBack.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
	barBack.BorderSizePixel = 0
	barBack.Parent = card
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = PURPLE
	barFill.BorderSizePixel = 0
	barFill.Parent = barBack
	local barText = UIKit.label(barBack, "", UDim2.fromScale(1, 1), UDim2.new(), 11)

	local depositAll = button(card, "Guardar todo", 10, Color3.fromRGB(80, 50, 130))
	local deposit100 = button(card, "Guardar 100", 112, Color3.fromRGB(80, 50, 130))
	local release = button(card, "Liberar", 0, Color3.fromRGB(150, 90, 30))
	release.Position = UDim2.new(1, -106, 1, -38)

	depositAll.MouseButton1Click:Connect(function() act("deposit", i, "all") end)
	deposit100.MouseButton1Click:Connect(function() act("deposit", i, 100) end)
	release.MouseButton1Click:Connect(function() act("release", i) end)

	cards[i] = {
		stroke = stroke, title = title, barBack = barBack, barFill = barFill, barText = barText,
		buttons = { depositAll, deposit100, release },
	}
end

render = function(snap)
	carriedLabel.Text = "Esencia que llevás encima (en riesgo): " .. snap.Essence
	for i, card in cards do
		local soul = snap.Souls[i]
		local hasFlask = i <= snap.Flasks
		if soul then
			card.title.Text = "🔮  " .. soul.Name
			card.title.TextColor3 = PURPLE
			card.stroke.Color = PURPLE
			card.barBack.Visible = true
			card.barFill.Size = UDim2.fromScale(soul.Capacity > 0 and soul.Essence / soul.Capacity or 0, 1)
			card.barText.Text = string.format("%d / %d Esencia", soul.Essence, soul.Capacity)
			for _, b in card.buttons do b.Visible = true end
		else
			card.title.Text = hasFlask and "Frasco vacío" or "Sin frasco (se compra en el Mercader)"
			card.title.TextColor3 = hasFlask and Color3.fromRGB(200, 200, 200) or GREY
			card.stroke.Color = hasFlask and Color3.fromRGB(90, 90, 110) or Color3.fromRGB(50, 50, 55)
			card.barBack.Visible = false
			for _, b in card.buttons do b.Visible = false end
		end
	end
end

local function refresh()
	local _, _, snap = request:InvokeServer("get")
	if snap then render(snap) end
end

entry.onOpen = function()
	status.Text = ""
	refresh()
end

player:GetAttributeChangedSignal("Essence"):Connect(function()
	if window.Visible then refresh() end
end)