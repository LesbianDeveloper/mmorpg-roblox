local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Stats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Stats"))
local notify = ReplicatedStorage:WaitForChild("Notify")
local player = Players.LocalPlayer

local COLORS = {
	xp = Color3.fromRGB(170, 120, 255),
	gold = Color3.fromRGB(255, 210, 60),
	Common = Color3.fromRGB(230, 230, 230),
	Uncommon = Color3.fromRGB(90, 220, 90),
	Rare = Color3.fromRGB(80, 150, 255),
	Epic = Color3.fromRGB(190, 90, 255),
	Legendary = Color3.fromRGB(255, 150, 40),
	Mythic = Color3.fromRGB(255, 60, 60),
}

local gui = Instance.new("ScreenGui")
gui.Name = "ProgressHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function fadeOut(label, delay)
	task.delay(delay, function()
		local tween = TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		label:Destroy()
	end)
end

---------------------------------------------------------------- Barra de XP
local xpBack = Instance.new("Frame")
xpBack.Size = UDim2.new(0.4, 0, 0, 10)
xpBack.Position = UDim2.new(0.3, 0, 1, -18)
xpBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
xpBack.BorderSizePixel = 0
xpBack.Parent = gui

local xpFill = Instance.new("Frame")
xpFill.Size = UDim2.fromScale(0, 1)
xpFill.BackgroundColor3 = COLORS.xp
xpFill.BorderSizePixel = 0
xpFill.Parent = xpBack

local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(1, 0, 0, 18)
xpLabel.Position = UDim2.new(0, 0, 0, -20)
xpLabel.BackgroundTransparency = 1
xpLabel.TextColor3 = Color3.new(1, 1, 1)
xpLabel.TextStrokeTransparency = 0.3
xpLabel.Font = Enum.Font.GothamBold
xpLabel.TextSize = 14
xpLabel.Parent = xpBack

local function refreshXP()
	local level = player:GetAttribute("Level") or 1
	local essence = player:GetAttribute("Essence") or 0
	local needed = Stats.XPForLevel(level)
	xpFill.Size = UDim2.fromScale(math.clamp(essence / needed, 0, 1), 1)
	if essence >= needed then
		xpLabel.Text = string.format("Nivel %d   ·   %d Esencia   ·   ¡Podés subir de nivel en un santuario!", level, essence)
	else
		xpLabel.Text = string.format("Nivel %d   ·   %d / %d Esencia", level, essence, needed)
	end
end
player:GetAttributeChangedSignal("Essence"):Connect(refreshXP)
player:GetAttributeChangedSignal("Level"):Connect(refreshXP)
refreshXP()

---------------------------------------------------------------- Avisos de botín
local list = Instance.new("Frame")
list.Size = UDim2.new(0, 260, 0, 300)
list.Position = UDim2.new(1, -280, 0.5, -150)
list.BackgroundTransparency = 1
list.Parent = gui

local layout = Instance.new("UIListLayout")
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.Padding = UDim.new(0, 4)
layout.Parent = list

notify.OnClientEvent:Connect(function(text, kind)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS[kind] or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Parent = list
	fadeOut(label, 2.5)
end)

---------------------------------------------------------------- ¡Subiste de nivel!
local lastLevel = player:GetAttribute("Level")
player:GetAttributeChangedSignal("Level"):Connect(function()
	local level = player:GetAttribute("Level")
	if lastLevel and level > lastLevel then
		local big = Instance.new("TextLabel")
		big.Size = UDim2.new(1, 0, 0, 80)
		big.Position = UDim2.new(0, 0, 0.3, 0)
		big.BackgroundTransparency = 1
		big.Text = "¡NIVEL " .. level .. "!"
		big.TextColor3 = COLORS.gold
		big.TextStrokeTransparency = 0
		big.Font = Enum.Font.GothamBlack
		big.TextSize = 64
		big.Parent = gui
		fadeOut(big, 2)
	end
	lastLevel = level
end)