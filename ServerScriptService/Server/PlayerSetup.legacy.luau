local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)
local RaceService = require(script.Parent.RaceService)
local Races = require(ReplicatedStorage.Shared.Races)
local Stats = require(ReplicatedStorage.Shared.Stats)

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
		if action == "devrace" and typeof(value) == "string" then
			return RaceService.setRace(player, value)
		elseif action == "devrunes" and typeof(value) == "number" then
			local data = PlayerData.get(player)
			PlayerData.set(player, "Runes", data.Runes + value)
			return true, "Runas: " .. data.Runes
		elseif action == "devshards" and typeof(value) == "number" then
			local data = PlayerData.get(player)
			PlayerData.set(player, "Shards", data.Shards + value)
			return true, "Esquirlas: " .. data.Shards
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