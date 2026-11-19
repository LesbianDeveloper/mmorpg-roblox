local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Abilities = require(Shared:WaitForChild("Abilities"))
local Animations = require(Shared:WaitForChild("Animations"))
local request = ReplicatedStorage:WaitForChild("AbilityRequest")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local KEYS = { [Enum.KeyCode.Z] = 1, [Enum.KeyCode.X] = 2, [Enum.KeyCode.V] = 3, [Enum.KeyCode.T] = 4 }
local RESOURCE = {
	Rage = { Name = "Furia", Color = Color3.fromRGB(200, 60, 40) },
	Mana = { Name = "Maná", Color = Color3.fromRGB(60, 120, 230) },
}
local CLASS_NAMES = { Warrior = "Guerrero", Mage = "Mago", Priest = "Sacerdote" }
local GOLD = Color3.fromRGB(235, 210, 150)
local RED = Color3.fromRGB(240, 80, 80)

local function myAbilities()
	return Abilities[player:GetAttribute("Class")] or {}
end

---------------------------------------------------------------- Animaciones
local tracks = {}
player.CharacterAdded:Connect(function()
	table.clear(tracks)
end)

local function playAnimation(name)
	local id = Animations[name]
	if not id or id == "" then return end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	if not tracks[name] then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. id
		tracks[name] = animator:LoadAnimation(animation)
	end
	tracks[name]:Play(0.05)
end

---------------------------------------------------------------- Barra de recurso (arriba de la vida)
local resourceBack = Instance.new("Frame")
resourceBack.Size = UDim2.new(0, 260, 0, 12)
resourceBack.Position = UDim2.new(0, 20, 1, -80)
resourceBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
resourceBack.BorderSizePixel = 0
resourceBack.Parent = UIKit.Gui

local resourceFill = Instance.new("Frame")
resourceFill.Size = UDim2.fromScale(0, 1)
resourceFill.BorderSizePixel = 0
resourceFill.Parent = resourceBack

local resourceText = UIKit.label(resourceBack, "", UDim2.fromScale(1, 1), UDim2.new(), 11)
resourceText.TextStrokeTransparency = 0.4

---------------------------------------------------------------- Barra de habilidades
local SIZE = 52
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 4 * (SIZE + 6) - 6, 0, SIZE)
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, -114)
bar.BackgroundTransparency = 1
bar.Parent = UIKit.Gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = bar

local errorLabel = UIKit.label(UIKit.Gui, "", UDim2.new(0, 300, 0, 20), UDim2.new(0.5, -150, 1, -140), 15, RED)

local cooldownEnds = {}
local slots = {}

local function cast(index)
	local ability = myAbilities()[index]
	if not ability then return end
	local target = mouse.Target and mouse.Target:FindFirstAncestorOfClass("Model")
	local ok, result = request:InvokeServer(index, mouse.Hit.Position, target)
	if ok then
		cooldownEnds[index] = os.clock() + result
		if ability.Animation then
			playAnimation(ability.Animation)
		end
	else
		errorLabel.Text = result or ""
		task.delay(1.2, function()
			if errorLabel.Text == result then errorLabel.Text = "" end
		end)
	end
end

for i = 1, 4 do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, SIZE, 0, SIZE)
	button.LayoutOrder = i
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	button.BackgroundTransparency = 0.15
	button.Text = ""
	button.ClipsDescendants = true
	button.Parent = bar
	UIKit.corner(button, 8)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 1.5
	stroke.Parent = button

	local cooldown = Instance.new("Frame")
	cooldown.AnchorPoint = Vector2.new(0, 1)
	cooldown.Position = UDim2.fromScale(0, 1)
	cooldown.Size = UDim2.fromScale(1, 0)
	cooldown.BackgroundColor3 = Color3.new(0, 0, 0)
	cooldown.BackgroundTransparency = 0.35
	cooldown.BorderSizePixel = 0
	cooldown.ZIndex = 2
	cooldown.Parent = button

	local key = UIKit.label(button, "", UDim2.new(0, 14, 0, 14), UDim2.new(0, 4, 0, 2), 11, GOLD)
	key.TextXAlignment = Enum.TextXAlignment.Left
	key.ZIndex = 3
	local name = UIKit.label(button, "", UDim2.new(1, -6, 1, -16), UDim2.new(0, 3, 0, 12), 10)
	name.TextWrapped = true
	name.ZIndex = 3

	button.MouseButton1Click:Connect(function()
		cast(i)
	end)
	slots[i] = { stroke = stroke, cooldown = cooldown, key = key, name = name }
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local index = KEYS[input.KeyCode]
	if index then
		cast(index)
	end
end)

RunService.RenderStepped:Connect(function()
	-- Recurso
	local resourceType = RESOURCE[player:GetAttribute("ResourceType") or "Mana"]
	local current = player:GetAttribute("Resource") or 0
	local max = player:GetAttribute("MaxResource") or 100
	resourceFill.BackgroundColor3 = resourceType.Color
	resourceFill.Size = UDim2.fromScale(math.clamp(current / max, 0, 1), 1)
	resourceText.Text = string.format("%s %d / %d", resourceType.Name, current, max)

	-- Habilidades
	local level = player:GetAttribute("Level") or 1
	local list = myAbilities()
	for i, ui in slots do
		local ability = list[i]
		if ability then
			local usable = ability.Implemented and level >= ability.Level
			ui.key.Text = ability.Key
			ui.name.Text = usable and ability.Name or ("Nv. " .. ability.Level)
			ui.name.TextColor3 = (usable and current >= ability.Cost) and Color3.new(1, 1, 1) or Color3.fromRGB(110, 110, 110)
			ui.stroke.Color = usable and Color3.fromRGB(120, 100, 60) or Color3.fromRGB(60, 60, 60)
			local remaining = (cooldownEnds[i] or 0) - os.clock()
			ui.cooldown.Size = UDim2.fromScale(1, remaining > 0 and remaining / ability.Cooldown or 0)
		else
			ui.key.Text = ""
			ui.name.Text = ""
		end
	end
end)

---------------------------------------------------------------- Libro de habilidades (K)
local window, content, entry = UIKit.createWindow("Spellbook", "Libro de habilidades", UDim2.new(0, 520, 0, 460))

local header = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 0), 15, GOLD)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -30)
list.Position = UDim2.new(0, 0, 0, 28)
list.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = content
UIKit.corner(list, 6)

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingLeft = UDim.new(0, 6)
listPadding.PaddingRight = UDim.new(0, 12)
listPadding.Parent = list

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

local function rebuildBook()
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end
	local resourceType = RESOURCE[player:GetAttribute("ResourceType") or "Mana"]
	local className = CLASS_NAMES[player:GetAttribute("Class")] or "?"
	header.Text = className .. "  ·  Recurso: " .. resourceType.Name
	local level = player:GetAttribute("Level") or 1

	for i, ability in myAbilities() do
		local unlocked = level >= ability.Level
		local available = unlocked and ability.Implemented
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 84)
		row.LayoutOrder = i
		row.BackgroundColor3 = available and Color3.fromRGB(35, 35, 44) or Color3.fromRGB(26, 26, 30)
		row.Parent = list
		UIKit.corner(row, 6)

		local title = UIKit.label(row, string.format("[%s]  %s", ability.Key, ability.Name),
			UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 6), 16, available and GOLD or Color3.fromRGB(120, 120, 120))
		title.TextXAlignment = Enum.TextXAlignment.Left

		local stats = string.format("Nivel %d  ·  Costo: %d %s  ·  Espera: %ss",
			ability.Level, ability.Cost, resourceType.Name, tostring(ability.Cooldown))
		if not ability.Implemented then
			stats ..= "  ·  PRÓXIMAMENTE"
		elseif not unlocked then
			stats ..= "  ·  Se desbloquea en nivel " .. ability.Level
		end
		local info = UIKit.label(row, stats, UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 28), 12,
			unlocked and Color3.fromRGB(170, 200, 255) or Color3.fromRGB(110, 110, 110))
		info.TextXAlignment = Enum.TextXAlignment.Left

		local description = UIKit.label(row, ability.Description, UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, 48), 13,
			available and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(110, 110, 110))
		description.TextXAlignment = Enum.TextXAlignment.Left
		description.TextWrapped = true
		description.Font = Enum.Font.Gotham
	end
end

entry.onOpen = rebuildBook