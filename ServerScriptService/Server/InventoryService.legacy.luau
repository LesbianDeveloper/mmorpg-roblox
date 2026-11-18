local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.Items)
local PlayerData = require(script.Parent.PlayerData)

local request = Instance.new("RemoteFunction")
request.Name = "InventoryRequest"
request.Parent = ReplicatedStorage

local function snapshot(data)
	return {
		Gold = data.Gold,
		Runes = data.Runes,
		Items = table.clone(data.Inventory),
		Equipment = table.clone(data.Equipment),
	}
end

local function addToInventory(data, itemId, amount)
	data.Inventory[itemId] = (data.Inventory[itemId] or 0) + amount
	if data.Inventory[itemId] <= 0 then
		data.Inventory[itemId] = nil
	end
end

-- Avisa a PlayerSetup que recalcule los stats
local function equipmentChanged(player)
	player:SetAttribute("EquipmentChanged", os.clock())
end

request.OnServerInvoke = function(player, action, value)
	local data = PlayerData.get(player)
	if not data then return nil end

	if action == "equip" and typeof(value) == "string" then
		local item = Items[value]
		if item and item.Slot and (data.Inventory[value] or 0) > 0 then
			local current = data.Equipment[item.Slot]
			if current then
				addToInventory(data, current, 1) -- lo que tenías puesto vuelve al inventario
			end
			addToInventory(data, value, -1)
			data.Equipment[item.Slot] = value
			equipmentChanged(player)
		end

	elseif action == "unequip" and typeof(value) == "string" then
		local current = data.Equipment[value]
		if current then
			addToInventory(data, current, 1)
			data.Equipment[value] = nil
			equipmentChanged(player)
		end
	end

	return snapshot(data) -- "get" y cualquier acción devuelven el estado actualizado
end