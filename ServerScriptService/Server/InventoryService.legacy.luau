local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)

local request = Instance.new("RemoteFunction")
request.Name = "InventoryRequest"
request.Parent = ReplicatedStorage

request.OnServerInvoke = function(player, action)
	local data = PlayerData.get(player)
	if not data then return nil end

	if action == "get" then
		return {
			Gold = data.Gold,
			Runes = data.Runes,
			Items = table.clone(data.Inventory),
		}
	end
	return nil
end