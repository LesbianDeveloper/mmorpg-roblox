local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Stats = require(ReplicatedStorage.Shared.Stats)

local store = DataStoreService:GetDataStore("PlayerData_v1")

local function defaultData()
	return { Level = 1, XP = 0 }
end

local function loadData(player)
	local ok, data = pcall(function()
		return store:GetAsync("player_" .. player.UserId)
	end)
	if not ok then
		warn("No se pudo cargar a " .. player.Name .. ": " .. tostring(data))
		return nil
	end
	return data or defaultData()
end

local function saveData(player)
	-- Si los datos nunca cargaron, no guardamos (evita pisar el progreso real)
	if not player:GetAttribute("DataLoaded") then return end
	local data = {
		Level = player:GetAttribute("Level"),
		XP = player:GetAttribute("XP"),
	}
	local ok, err = pcall(function()
		store:SetAsync("player_" .. player.UserId, data)
	end)
	if not ok then
		warn("No se pudo guardar a " .. player.Name .. ": " .. tostring(err))
	end
end

local function setupPlayer(player)
	local data = loadData(player)
	if not data then
		player:Kick("Error cargando tus datos. Probá entrar de nuevo.")
		return
	end

	player:SetAttribute("Level", data.Level)
	player:SetAttribute("XP", data.XP)
	for name, value in Stats.Base do
		player:SetAttribute(name, value)
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Nivel"
	level.Value = data.Level
	level.Parent = leaderstats

	-- Mantiene la columna "Nivel" sincronizada con el atributo
	player:GetAttributeChangedSignal("Level"):Connect(function()
		level.Value = player:GetAttribute("Level")
	end)

	player:SetAttribute("DataLoaded", true)
	print(player.Name .. " cargado con nivel " .. data.Level)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

Players.PlayerRemoving:Connect(saveData)

-- Guarda a todos cuando el servidor se apaga
game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveData(player)
	end
end)