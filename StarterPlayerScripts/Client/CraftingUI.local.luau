local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared:WaitForChild("Items"))
local Recipes = require(Shared:WaitForChild("Recipes"))
local craftRequest = ReplicatedStorage:WaitForChild("CraftRequest")
local player = Players.LocalPlayer
local RARITY = UIKit.RARITY

local GREEN = Color3.fromRGB(90, 220, 90)
local RED = Color3.fromRGB(240, 80, 80)

local window, content, entry = UIKit.createWindow("Crafting", "Forja", UDim2.new(0, 540, 0, 400))

local currentStation, currentStationModel = nil, nil
local selectedRecipe = nil
local lastSnapshot = nil

---------------------------------------------------------------- Lista de recetas (izquierda)
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(0, 200, 1, 0)
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
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.Parent = list

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

---------------------------------------------------------------- Detalle (derecha)
local detail = Instance.new("Frame")
detail.Size = UDim2.new(1, -212, 1, 0)
detail.Position = UDim2.new(0, 212, 0, 0)
detail.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
detail.Parent = content
UIKit.corner(detail, 6)

local resultName = UIKit.label(detail, "Elegí una receta", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 8), 18)
local resultInfo = UIKit.label(detail, "", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 34), 13, Color3.fromRGB(180, 180, 180))
resultInfo.TextWrapped = true

UIKit.label(detail, "Materiales", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 82), 14, Color3.fromRGB(235, 210, 150))
local materials = Instance.new("Frame")
materials.Size = UDim2.new(1, -20, 0, 130)
materials.Position = UDim2.new(0, 10, 0, 106)
materials.BackgroundTransparency = 1
materials.Parent = detail
local materialsLayout = Instance.new("UIListLayout")
materialsLayout.Padding = UDim.new(0, 4)
materialsLayout.SortOrder = Enum.SortOrder.LayoutOrder
materialsLayout.Parent = materials

local craftButton = Instance.new("TextButton")
craftButton.Size = UDim2.new(1, -20, 0, 40)
craftButton.Position = UDim2.new(0, 10, 1, -76)
craftButton.Text = "Fabricar"
craftButton.Font = Enum.Font.GothamBold
craftButton.TextSize = 18
craftButton.TextColor3 = Color3.new(1, 1, 1)
craftButton.Parent = detail
UIKit.corner(craftButton, 6)

local status = UIKit.label(detail, "", UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 1, -30), 14)

---------------------------------------------------------------- Lógica
local function countOf(itemId)
	return lastSnapshot and lastSnapshot.Items[itemId] or 0
end

local function canCraft(recipe)
	for itemId, amount in recipe.Materials do
		if countOf(itemId) < amount then return false end
	end
	return (lastSnapshot and lastSnapshot.Gold or 0) >= (recipe.Gold or 0)
end

local function showDetail()
	for _, child in materials:GetChildren() do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	local recipe = selectedRecipe and Recipes[selectedRecipe]
	if not recipe then
		resultName.Text = "Elegí una receta"
		resultName.TextColor3 = Color3.new(1, 1, 1)
		resultInfo.Text = ""
		craftButton.Visible = false
		return
	end

	local item = Items[recipe.Result]
	local rarity = RARITY[item.Rarity] or RARITY.Common
	resultName.Text = item.Name
	resultName.TextColor3 = rarity.Color
	resultInfo.Text = (UIKit.TYPE_NAMES[item.Type] or item.Type) .. " · " .. rarity.Name
		.. (item.Stats and ("\n" .. UIKit.describeStats(item.Stats)) or "")

	local order = 0
	for itemId, amount in recipe.Materials do
		order += 1
		local have = countOf(itemId)
		local line = UIKit.label(materials, string.format("%s     %d / %d", Items[itemId].Name, have, amount),
			UDim2.new(1, 0, 0, 20), UDim2.new(), 14, have >= amount and GREEN or RED)
		line.TextXAlignment = Enum.TextXAlignment.Left
		line.LayoutOrder = order
	end
	if recipe.Gold then
		local gold = lastSnapshot and lastSnapshot.Gold or 0
		local line = UIKit.label(materials, string.format("Oro     %d / %d", gold, recipe.Gold),
			UDim2.new(1, 0, 0, 20), UDim2.new(), 14, gold >= recipe.Gold and GREEN or RED)
		line.TextXAlignment = Enum.TextXAlignment.Left
		line.LayoutOrder = order + 1
	end

	craftButton.Visible = true
	craftButton.BackgroundColor3 = canCraft(recipe) and Color3.fromRGB(150, 90, 30) or Color3.fromRGB(60, 60, 60)
end

local function rebuildList()
	for _, child in list:GetChildren() do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for recipeId, recipe in Recipes do
		if recipe.Station == currentStation then
			local item = Items[recipe.Result]
			local rarity = RARITY[item.Rarity] or RARITY.Common
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 36)
			button.LayoutOrder = recipe.Order or 99
			button.BackgroundColor3 = recipeId == selectedRecipe and Color3.fromRGB(70, 60, 40) or Color3.fromRGB(40, 40, 48)
			button.Text = item.Name
			button.TextColor3 = rarity.Color
			button.Font = Enum.Font.GothamBold
			button.TextSize = 14
			button.Parent = list
			UIKit.corner(button, 6)
			button.MouseButton1Click:Connect(function()
				selectedRecipe = recipeId
				status.Text = ""
				rebuildList()
				showDetail()
			end)
		end
	end
end

craftButton.MouseButton1Click:Connect(function()
	if not selectedRecipe then return end
	local ok, message = craftRequest:InvokeServer(selectedRecipe)
	status.Text = message or ""
	status.TextColor3 = ok and GREEN or RED
	UIKit.request("get") -- actualiza materiales e inventario
end)

UIKit.DataChanged:Connect(function(snapshot)
	lastSnapshot = snapshot
	if window.Visible then
		showDetail()
	end
end)

entry.onOpen = function()
	status.Text = ""
	rebuildList()
	showDetail()
	UIKit.request("get")
end

---------------------------------------------------------------- Abrir desde la estación
ProximityPromptService.PromptTriggered:Connect(function(prompt)
	local station = prompt:FindFirstAncestorOfClass("Model")
	local stationType = station and station:GetAttribute("StationType")
	if not stationType then return end
	currentStation = stationType
	currentStationModel = station
	selectedRecipe = nil
	if not window.Visible then
		UIKit.toggle("Crafting")
	else
		entry.onOpen()
	end
end)

-- Si te alejás de la estación, se cierra
RunService.Heartbeat:Connect(function()
	if not window.Visible or not currentStationModel then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (currentStationModel:GetPivot().Position - root.Position).Magnitude > 16 then
		UIKit.toggle("Crafting")
	end
end)