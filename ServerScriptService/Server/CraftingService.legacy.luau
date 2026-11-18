local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Recipes = require(ReplicatedStorage.Shared.Recipes)
local Items = require(ReplicatedStorage.Shared.Items)
local PlayerData = require(script.Parent.PlayerData)
local Rewards = require(script.Parent.Rewards)

local MAX_DISTANCE = 14

local request = Instance.new("RemoteFunction")
request.Name = "CraftRequest"
request.Parent = ReplicatedStorage

local function isNearStation(player, stationType)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local stations = workspace:FindFirstChild("Stations")
	if not root or not stations then return false end
	for _, station in stations:GetChildren() do
		if station:GetAttribute("StationType") == stationType
			and (station:GetPivot().Position - root.Position).Magnitude <= MAX_DISTANCE then
			return true
		end
	end
	return false
end

request.OnServerInvoke = function(player, recipeId)
	local recipe = typeof(recipeId) == "string" and Recipes[recipeId]
	local data = PlayerData.get(player)
	if not recipe or not data then
		return false, "Receta inválida"
	end
	if not isNearStation(player, recipe.Station) then
		return false, "Tenés que estar junto a la estación"
	end
	for itemId, amount in recipe.Materials do
		if (data.Inventory[itemId] or 0) < amount then
			return false, "Te faltan materiales"
		end
	end
	if data.Gold < (recipe.Gold or 0) then
		return false, "No tenés suficiente oro"
	end

	-- Consumir materiales y oro
	for itemId, amount in recipe.Materials do
		data.Inventory[itemId] -= amount
		if data.Inventory[itemId] <= 0 then
			data.Inventory[itemId] = nil
		end
	end
	if recipe.Gold then
		PlayerData.set(player, "Gold", data.Gold - recipe.Gold)
	end

	Rewards.addItem(player, recipe.Result, recipe.Quantity or 1)
	return true, "Fabricaste: " .. Items[recipe.Result].Name
end