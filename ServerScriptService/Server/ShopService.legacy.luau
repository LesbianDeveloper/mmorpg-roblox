local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.Items)
local Shops = require(ReplicatedStorage.Shared.Shops)
local PlayerData = require(script.Parent.PlayerData)
local Rewards = require(script.Parent.Rewards)
local Hotbar = require(script.Parent.Hotbar)

local MAX_DISTANCE = 14
local MAX_FLASKS = 3

local request = Instance.new("RemoteFunction")
request.Name = "ShopRequest"
request.Parent = ReplicatedStorage

-- Devuelve el ShopId del mercader que tenés cerca (o nil)
local function nearbyShop(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local shops = workspace:FindFirstChild("Shops")
	if not root or not shops then return nil end
	for _, shop in shops:GetChildren() do
		if (shop:GetPivot().Position - root.Position).Magnitude <= MAX_DISTANCE then
			return shop:GetAttribute("ShopId")
		end
	end
	return nil
end

request.OnServerInvoke = function(player, action, a, b)
	local data = PlayerData.get(player)
	if not data then return false, "Datos no cargados" end
	local shopId = nearbyShop(player)
	local shop = shopId and Shops[shopId]
	if not shop then return false, "Tenés que estar junto al mercader" end

	if action == "buy" then
		local entry = typeof(a) == "number" and shop.Buy[a]
		if not entry then return false, "Artículo inválido" end
		local quantity = typeof(b) == "number" and math.clamp(math.floor(b), 1, 99) or 1

		if entry.Special == "SoulFlask" then
			if (data.SoulFlasks or 0) >= MAX_FLASKS then
				return false, "Ya tenés los 3 frascos"
			end
			if data.Gold < entry.Price then
				return false, "No tenés suficiente oro"
			end
			PlayerData.set(player, "Gold", data.Gold - entry.Price)
			PlayerData.set(player, "SoulFlasks", (data.SoulFlasks or 0) + 1)
			return true, "Compraste un Frasco de alma"
		end

		local cost = entry.Price * quantity
		if data.Gold < cost then
			return false, "No tenés suficiente oro"
		end
		PlayerData.set(player, "Gold", data.Gold - cost)
		Rewards.addItem(player, entry.Item, quantity)
		Hotbar.refresh(player) -- por si estaba en la barra y no te quedaba ninguna
		return true, string.format("Compraste %d × %s", quantity, Items[entry.Item].Name)

	elseif action == "sell" then
		local item = typeof(a) == "string" and Items[a]
		if not item or not item.Value then
			return false, "Eso no se puede vender"
		end
		local have = data.Inventory[a] or 0
		local quantity = b == "all" and have or (typeof(b) == "number" and math.floor(b) or 1)
		if quantity < 1 or quantity > have then
			return false, "No tenés suficientes"
		end
		data.Inventory[a] = have - quantity
		if data.Inventory[a] <= 0 then
			data.Inventory[a] = nil
		end
		local earned = item.Value * quantity
		PlayerData.set(player, "Gold", data.Gold + earned)
		Hotbar.refresh(player) -- si vendiste lo que tenías en la mano
		return true, string.format("Vendiste %d × %s por %d de oro", quantity, item.Name, earned)
	end

	return false, "Acción inválida"
end