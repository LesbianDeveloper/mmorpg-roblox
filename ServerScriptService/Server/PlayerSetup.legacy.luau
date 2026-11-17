local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(ReplicatedStorage.Shared.Stats)

local function setupPlayer(player)
	player:SetAttribute("Level", 1)
	player:SetAttribute("XP", 0)
	for name, value in Stats.Base do
		player:SetAttribute(name, value)
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Nivel"
	level.Value = 1
	level.Parent = leaderstats

	print(player.Name .. " entró con nivel 1")
end

Players.PlayerAdded:Connect(setupPlayer)

-- Por si el jugador entró antes de que el script arrancara (pasa en Studio)
for _, player in Players:GetPlayers() do
	setupPlayer(player)
end