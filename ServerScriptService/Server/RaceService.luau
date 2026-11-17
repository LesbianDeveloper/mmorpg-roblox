local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Races = require(ReplicatedStorage.Shared.Races)
local PlayerData = require(script.Parent.PlayerData)

local RaceService = {}
local rng = Random.new()

local EPIC_GUARANTEE = 60 -- Épico o mejor garantizado cada 60 tiradas
local SHARD_COST = 300    -- elegir raza Legendaria o inferior
local SHARD_COST_MYTHIC = 1000

local function weightedPick(minTier)
	local pool, total = {}, 0
	for _, race in Races.List do
		if Races.Tiers[race.Rarity] >= minTier then
			table.insert(pool, race)
			total += race.Chance
		end
	end
	local roll = rng:NextNumber(0, total)
	for _, race in pool do
		roll -= race.Chance
		if roll <= 0 then return race end
	end
	return pool[#pool]
end

local function applyRace(player, race)
	PlayerData.set(player, "Race", race.Id)
	if race.Lineages then
		PlayerData.set(player, "Lineage", "Aesir") -- después se elige por UI
	end
end

function RaceService.roll(player, isFree)
	local data = PlayerData.get(player)
	if not data then return false, "Datos no cargados" end

	if not isFree then
		if data.Runes < 1 then return false, "No tenés Runas del Destino" end
		PlayerData.set(player, "Runes", data.Runes - 1)
	end

	local minTier = Races.Tiers.Common
	if data.RollsSinceEpic + 1 >= EPIC_GUARANTEE then
		minTier = Races.Tiers.Epic
	end

	local race = weightedPick(minTier)
	if Races.Tiers[race.Rarity] >= Races.Tiers.Epic then
		PlayerData.set(player, "RollsSinceEpic", 0)
	else
		PlayerData.set(player, "RollsSinceEpic", data.RollsSinceEpic + 1)
	end
	PlayerData.set(player, "Shards", data.Shards + 1)

	applyRace(player, race)
	return true, race.Name .. " (" .. race.Rarity .. ")"
end

function RaceService.buyWithShards(player, raceId)
	local data = PlayerData.get(player)
	local race = Races.ById[raceId]
	if not data or not race then return false, "Raza inválida" end

	local cost = race.Rarity == "Mythic" and SHARD_COST_MYTHIC or SHARD_COST
	if data.Shards < cost then
		return false, "Te faltan " .. (cost - data.Shards) .. " esquirlas"
	end
	PlayerData.set(player, "Shards", data.Shards - cost)
	applyRace(player, race)
	return true, race.Name
end

-- Asigna una raza directamente (usado por comandos de prueba)
function RaceService.setRace(player, raceId)
	local race = Races.ById[raceId]
	if not race then return false, "Raza inválida: " .. tostring(raceId) end
	applyRace(player, race)
	return true, race.Name
end

return RaceService