local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData_v1")

local PlayerData = {}
local profiles = {}

local DEFAULTS = {
	Level = 1, XP = 0,
	Class = "Warrior",
	Runes = 5,          -- Runas del Destino (5 para testear)
	Shards = 0,         -- Esquirlas del Destino
	RollsSinceEpic = 0, -- contador para la garantía de Épico
}

function PlayerData.load(player)
	local ok, data = pcall(function()
		return store:GetAsync("player_" .. player.UserId)
	end)
	if not ok then
		warn("No se pudo cargar a " .. player.Name .. ": " .. tostring(data))
		return nil
	end
	data = data or {}
	for key, value in DEFAULTS do
		if data[key] == nil then data[key] = value end
	end
	profiles[player] = data
	for key, value in data do
		player:SetAttribute(key, value) -- espejo para que el cliente pueda leerlo
	end
	return data
end

function PlayerData.get(player)
	return profiles[player]
end

-- Única forma de modificar datos: actualiza la tabla y el atributo
function PlayerData.set(player, key, value)
	local data = profiles[player]
	if not data then return end
	data[key] = value
	player:SetAttribute(key, value)
end

function PlayerData.save(player)
	local data = profiles[player]
	if not data then return end
	local ok, err = pcall(function()
		store:SetAsync("player_" .. player.UserId, data)
	end)
	if not ok then
		warn("No se pudo guardar a " .. player.Name .. ": " .. tostring(err))
	end
end

function PlayerData.release(player)
	PlayerData.save(player)
	profiles[player] = nil
end

return PlayerData