local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Races = require(Shared:WaitForChild("Races"))
local request = ReplicatedStorage:WaitForChild("CreationRequest")
local player = Players.LocalPlayer

local RARITY = UIKit.RARITY
local GOLD = Color3.fromRGB(235, 210, 150)
local RED = Color3.fromRGB(240, 80, 80)

local CLASS_ORDER = { "Warrior", "Mage", "Priest" }
local CLASS_INFO = {
	Warrior = { Name = "Guerrero", Icon = "⚔️", Role = "Tanque · Daño cuerpo a cuerpo", Stat = "Fuerza",
		Text = "Espada y escudo o armas a dos manos. Mucha vida y defensa; su Furia crece en plena pelea." },
	Mage = { Name = "Mago", Icon = "🔥", Role = "Daño mágico a distancia", Stat = "Intelecto",
		Text = "Fuego, escarcha y arcano. Gran daño en área y control de enemigos, pero muy frágil." },
	Priest = { Name = "Sacerdote", Icon = "✨", Role = "Sanación · Daño de sombras", Stat = "Intelecto",
		Text = "Cura y protege a su grupo, o castiga a sus enemigos con magia de sombras." },
}
local BONUS_NAMES = {
	XPGain = "Esencia obtenida", Defense = "Defensa", CraftArmor = "Crafteo de armaduras",
	MeleeDamage = "Daño cuerpo a cuerpo", MaxHealth = "Vida", RangedDamage = "Daño a distancia",
	MoveSpeed = "Velocidad", FrostResist = "Resistencia al frío", HealingDone = "Curación realizada",
	MagicDamage = "Daño mágico", ShadowResist = "Resistencia a sombras", Agility = "Agilidad",
	PoisonDamage = "Daño de veneno", CritChance = "Crítico", FireResist = "Resistencia al fuego",
	HolyDamage = "Daño sagrado", ShadowDamage = "Daño de sombras", AllDamage = "Daño",
	Lifesteal = "Robo de vida", HealingReceived = "Curación recibida", PhysicalDamage = "Daño físico",
}

local function setPlayerList(enabled)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, enabled)
	end)
end

---------------------------------------------------------------- Pantalla base
local gui = Instance.new("ScreenGui")
gui.Name = "CharacterCreation"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
background.Parent = gui

local title = UIKit.label(background, "", UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 50), 40, GOLD)
title.Font = Enum.Font.GothamBlack
local subtitle = UIKit.label(background, "", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 104), 18, Color3.fromRGB(180, 180, 180))

local function bigButton(parent, text, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 280, 0, 54)
	b.AnchorPoint = Vector2.new(0.5, 0)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 22
	b.Parent = parent
	UIKit.corner(b, 8)
	return b
end

---------------------------------------------------------------- Paso 1: clase
local classPage = Instance.new("Frame")
classPage.Size = UDim2.fromScale(1, 1)
classPage.BackgroundTransparency = 1
classPage.Parent = background

local row = Instance.new("Frame")
row.Size = UDim2.new(0, #CLASS_ORDER * 270, 0, 340)
row.AnchorPoint = Vector2.new(0.5, 0.5)
row.Position = UDim2.fromScale(0.5, 0.55)
row.BackgroundTransparency = 1
row.Parent = classPage

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.Padding = UDim.new(0, 20)
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Parent = row

---------------------------------------------------------------- Paso 2: raza
local racePage = Instance.new("Frame")
racePage.Size = UDim2.fromScale(1, 1)
racePage.BackgroundTransparency = 1
racePage.Visible = false
racePage.Parent = background

local raceName = UIKit.label(racePage, "?", UDim2.new(1, 0, 0, 80), UDim2.new(0, 0, 0.32, 0), 64)
raceName.Font = Enum.Font.GothamBlack
local rarityLabel = UIKit.label(racePage, "", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0.32, 84), 22)
local bonusLabel = UIKit.label(racePage, "", UDim2.new(0.6, 0, 0, 60), UDim2.new(0.2, 0, 0.32, 120), 16, Color3.fromRGB(200, 200, 200))
bonusLabel.TextWrapped = true

local rollButton = bigButton(racePage, "🎲  Tirar", Color3.fromRGB(110, 60, 150))
rollButton.Position = UDim2.new(0.5, 0, 0.7, 0)
local startButton = bigButton(racePage, "Comenzar aventura", Color3.fromRGB(150, 90, 30))
startButton.Position = UDim2.new(0.5, 0, 0.7, 0)
startButton.Visible = false

-- Tabla de probabilidades
local odds = Instance.new("Frame")
odds.Size = UDim2.new(0, 220, 0, 380)
odds.AnchorPoint = Vector2.new(1, 0.5)
odds.Position = UDim2.new(1, -30, 0.55, 0)
odds.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
odds.Parent = racePage
UIKit.corner(odds, 8)
UIKit.label(odds, "Probabilidades", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 6), 16, GOLD)
for i, race in Races.List do
	local line = UIKit.label(odds, string.format("%s   %s%%", race.Name, tostring(race.Chance)),
		UDim2.new(1, -24, 0, 22), UDim2.new(0, 12, 0, 8 + i * 26), 14, RARITY[race.Rarity].Color)
	line.TextXAlignment = Enum.TextXAlignment.Left
end

---------------------------------------------------------------- Lógica
local function formatBonuses(race)
	local parts = {}
	for key, value in race.Bonuses do
		local percent = math.floor(value * 100 + 0.5)
		table.insert(parts, string.format("%s%d%% %s", percent >= 0 and "+" or "", percent, BONUS_NAMES[key] or key))
	end
	table.sort(parts)
	return table.concat(parts, "   ·   ") .. "\nHabilidad racial: " .. race.Ability
end

local function showRace(race)
	local rarity = RARITY[race.Rarity] or RARITY.Common
	raceName.Text = race.Name
	raceName.TextColor3 = rarity.Color
	rarityLabel.Text = rarity.Name
	rarityLabel.TextColor3 = rarity.Color
	bonusLabel.Text = formatBonuses(race)
end

local function showRacePage(alreadyRolled)
	classPage.Visible = false
	racePage.Visible = true
	title.Text = "Tu raza"
	if alreadyRolled then
		subtitle.Text = "Este es tu linaje. Podrás ganar otras razas con misiones."
		showRace(Races.ById[player:GetAttribute("Race")] or Races.ById.Human)
		rollButton.Visible = false
		startButton.Visible = true
	else
		subtitle.Text = "Tu primera tirada es gratis. Solo hay una."
		raceName.Text = "?"
		raceName.TextColor3 = Color3.new(1, 1, 1)
		rarityLabel.Text = ""
		bonusLabel.Text = ""
		rollButton.Visible = true
		startButton.Visible = false
	end
end

for i, classId in CLASS_ORDER do
	local info = CLASS_INFO[classId]
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(0, 250, 0, 340)
	card.LayoutOrder = i
	card.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	card.Text = ""
	card.Parent = row
	UIKit.corner(card, 10)
	UIKit.stroke(card, Color3.fromRGB(120, 100, 60), 2)

	UIKit.label(card, info.Icon, UDim2.new(1, 0, 0, 70), UDim2.new(0, 0, 0, 16), 54)
	UIKit.label(card, info.Name, UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 92), 28, GOLD)
	UIKit.label(card, info.Role, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 130), 14, Color3.fromRGB(170, 200, 255))
	UIKit.label(card, "Stat principal: " .. info.Stat, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 154), 13, Color3.fromRGB(180, 180, 180))
	local text = UIKit.label(card, info.Text, UDim2.new(1, -28, 0, 110), UDim2.new(0, 14, 0, 186), 14, Color3.fromRGB(210, 210, 210))
	text.TextWrapped = true
	text.Font = Enum.Font.Gotham

	card.MouseButton1Click:Connect(function()
		local ok, message = request:InvokeServer("chooseClass", classId)
		if ok then
			showRacePage(false)
		else
			subtitle.Text = message
			subtitle.TextColor3 = RED
		end
	end)
end

rollButton.MouseButton1Click:Connect(function()
	rollButton.Visible = false
	local ok, raceId = request:InvokeServer("roll")
	if not ok then
		subtitle.Text = raceId
		subtitle.TextColor3 = RED
		return
	end
	-- Ruleta: pasa por razas al azar, cada vez más lento
	for step = 1, 28 do
		local randomRace = Races.List[math.random(#Races.List)]
		raceName.Text = randomRace.Name
		raceName.TextColor3 = RARITY[randomRace.Rarity].Color
		task.wait(0.03 + step * 0.007)
	end
	showRace(Races.ById[raceId])
	startButton.Visible = true
end)

startButton.MouseButton1Click:Connect(function()
	local ok, message = request:InvokeServer("finish")
	if ok then
		gui.Enabled = false
		setPlayerList(true)
	else
		subtitle.Text = message
		subtitle.TextColor3 = RED
	end
end)

local function open()
	gui.Enabled = true
	setPlayerList(false) -- oculta la lista de jugadores (spoiler de la raza)
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
	if player:GetAttribute("FreeRollUsed") then
		showRacePage(true)
	else
		classPage.Visible = true
		racePage.Visible = false
		title.Text = "Elegí tu clase"
		subtitle.Text = "Define cómo vas a pelear. Más clases se desbloquean jugando."
	end
end

-- Esperar a que carguen los datos y decidir si mostrar la pantalla
while player:GetAttribute("CharacterCreated") == nil do
	task.wait(0.1)
end
if not player:GetAttribute("CharacterCreated") then
	open()
end
player:GetAttributeChangedSignal("CharacterCreated"):Connect(function()
	if player:GetAttribute("CharacterCreated") == false then
		open()
	end
end)