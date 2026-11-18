local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)
local Hotbar = require(script.Parent.Hotbar)

local remote = Instance.new("RemoteEvent")
remote.Name = "HotbarAction"
remote.Parent = ReplicatedStorage

remote.OnServerEvent:Connect(function(player, action, value)
	if action == "select" then
		Hotbar.select(player, value)
	elseif action == "use" then
		Hotbar.use(player)
	end
end)

local function waitForData(player)
	while player.Parent and not PlayerData.get(player) do
		task.wait(0.2)
	end
	return PlayerData.get(player)
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		task.wait(0.2) -- espera a que el cuerpo termine de armarse
		Hotbar.refresh(player)
	end)

	task.spawn(function()
		local data = waitForData(player)
		if not data then return end

		-- Migración: el arma que estaba en la ventana de equipo pasa a la barra
		if data.Equipment.Weapon then
			local weaponId = data.Equipment.Weapon
			data.Equipment.Weapon = nil
			data.Inventory[weaponId] = (data.Inventory[weaponId] or 0) + 1
			player:SetAttribute("EquipmentChanged", os.clock())
			Hotbar.assign(player, weaponId)
		end

		player:SetAttribute("ActiveSlot", 1)
		Hotbar.refresh(player)
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
Players.PlayerRemoving:Connect(Hotbar.forget)