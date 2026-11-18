local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)
local RaceService = require(script.Parent.RaceService)
local Races = require(ReplicatedStorage.Shared.Races)
local Stats = require(ReplicatedStorage.Shared.Stats)
local Rewards = require(script.Parent.Rewards)

local RunService = game:GetService("RunService")

-- Canal para que el cliente pida tiradas (el servidor valida todo)
local raceRequest = Instance.new("RemoteFunction")
raceRequest.Name = "RaceRequest"
raceRequest.Parent = ReplicatedStorage

raceRequest.OnServerInvoke = function(player, action, value)
	if action == "roll" then
		return RaceService.roll(player, false)
	elseif action == "shards" and typeof(value) == "string" then
		return RaceService.buyWithShards(player, value)
	end

	-- Comandos de prueba: SOLO funcionan dentro de Roblox Studio
	if RunService:IsStudio() then
		local data = PlayerData.get(player)
		if action == "devrace" and typeof(value) == "string" then
			return RaceService.setRace(player, value)
		elseif action == "devrunes" and typeof(value) == "number" then
			PlayerData.set(player, "Runes", data.Runes + value)
			return true, "Runas: " .. data.Runes
		elseif action == "devshards" and typeof(value) == "number" then
			PlayerData.set(player, "Shards", data.Shards + value)
			return true, "Esquirlas: " .. data.Shards
		elseif action == "devlevel" and typeof(value) == "number" then
			PlayerData.set(player, "XP", 0)
			PlayerData.set(player, "Level", math.clamp(math.floor(value), 1, 60))
			return true, "Nivel " .. data.Level
		elseif action == "devxp" and typeof(value) == "number" then
			Rewards.addXP(player, value)
			return true, "Nivel " .. data.Level .. " | XP " .. data.XP
		elseif action == "devinv" then
			local items = {}
			for itemId, quantity in data.Inventory do
				table.insert(items, itemId .. " x" .. quantity)
			end
			local list = #items > 0 and table.concat(items, ", ") or "vacío"
			return true, "Oro: " .. data.Gold .. " | Runas: " .. data.Runes .. " | Inventario: " .. list
		end
	end

	return false, "Acción inválida"
end

local function applyStats(player)
	local data = PlayerData.get(player)
	local final = Stats.compute(data.Race, data.Class, data.Level)
	for name, value in final do
		player:SetAttribute(name, value)
	end
end

local function setupPlayer(player)
	local data = PlayerData.load(player)
	if not data then
		player:Kick("Error cargando tus datos. Probá entrar de nuevo.")
		return
	end

	if not data.Race then
		RaceService.roll(player, true) -- primera tirada gratis
	end
	applyStats(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Nivel"
	level.Value = data.Level
	level.Parent = leaderstats

	local race = Instance.new("StringValue")
	race.Name = "Raza"
	race.Value = Races.ById[data.Race].Name
	race.Parent = leaderstats

	player:GetAttributeChangedSignal("Race"):Connect(function()
		race.Value = Races.ById[player:GetAttribute("Race")].Name
		applyStats(player)
	end)
	
	player:GetAttributeChangedSignal("Level"):Connect(function()
		level.Value = player:GetAttribute("Level")
		applyStats(player)
	end)

	print(string.format("%s | Raza: %s | Clase: %s | Vida: %d",
		player.Name, race.Value, data.Class, player:GetAttribute("MaxHealth")))
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(PlayerData.release)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		PlayerData.save(player)
	end
end)