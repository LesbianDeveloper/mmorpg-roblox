local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData_v1")

local PlayerData = {}
local profiles = {}

local DEFAULTS = {
	Level = 1, XP = 0,
	Class = "Warrior",
	Runes = 5,
	Shards = 0,
	RollsSinceEpic = 0,
	Gold = 0,
	Inventory = {}, -- [itemId] = cantidad
	Equipment = {}, -- [slot] = itemId
	Essence = 0,    -- Esencia sin gastar (se pierde al morir)
	Shrines = {},   -- [shrineId] = true, santuarios activados
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
		if data[key] == nil then
			-- las tablas se copian para que cada jugador tenga la suya
			data[key] = typeof(value) == "table" and table.clone(value) or value
		end
	end
	profiles[player] = data
	for key, value in data do
		if typeof(value) ~= "table" then
			player:SetAttribute(key, value) -- espejo para el cliente (las tablas no pueden ser atributos)
		end
	end
	return data
end

function PlayerData.get(player)
	return profiles[player]
end

function PlayerData.set(player, key, value)
	local data = profiles[player]
	if not data then return end
	data[key] = value
	if typeof(value) ~= "table" then
		player:SetAttribute(key, value)
	end
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