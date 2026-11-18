local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(ReplicatedStorage.Shared.Stats)
local Races = require(ReplicatedStorage.Shared.Races)
local Items = require(ReplicatedStorage.Shared.Items)
local PlayerData = require(script.Parent.PlayerData)

-- Canal para mandarle avisos al jugador ("+40 XP", "+2 Hueso"...)
local notify = ReplicatedStorage:FindFirstChild("Notify") or Instance.new("RemoteEvent")
notify.Name = "Notify"
notify.Parent = ReplicatedStorage

local MAX_LEVEL = 60
local rng = Random.new()
local Rewards = {}

function Rewards.addEssence(player, amount)
	local data = PlayerData.get(player)
	if not data then return end
	local race = Races.ById[data.Race]
	local bonus = race and race.Bonuses.XPGain or 0 -- Humano: +5%
	amount = math.floor(amount * (1 + bonus))
	PlayerData.set(player, "Essence", (data.Essence or 0) + amount)
	notify:FireClient(player, "+" .. amount .. " Esencia", "xp")
end

function Rewards.addGold(player, amount)
	local data = PlayerData.get(player)
	if not data then return end
	PlayerData.set(player, "Gold", data.Gold + amount)
	notify:FireClient(player, "+" .. amount .. " oro", "gold")
end

function Rewards.addItem(player, itemId, quantity)
	local data = PlayerData.get(player)
	local item = Items[itemId]
	if not data or not item then return end
	if item.Field then
		PlayerData.set(player, item.Field, (data[item.Field] or 0) + quantity)
	else
		data.Inventory[itemId] = (data.Inventory[itemId] or 0) + quantity
	end
	notify:FireClient(player, "+" .. quantity .. " " .. item.Name, item.Rarity)
end

-- Reparte recompensas a todos los que le pegaron al enemigo
function Rewards.grantKill(enemy, enemyData)
	for attributeName in enemy:GetAttributes() do
		local userId = tonumber(string.match(attributeName, "^Hit_(%d+)$"))
		local player = userId and Players:GetPlayerByUserId(userId)
		if player and PlayerData.get(player) then
			Rewards.addEssence(player, enemyData.XP or 0)
			if enemyData.Gold then
				Rewards.addGold(player, rng:NextInteger(enemyData.Gold[1], enemyData.Gold[2]))
			end
			for _, drop in enemyData.Loot or {} do
				if rng:NextNumber() <= drop.Chance then
					Rewards.addItem(player, drop.Item, rng:NextInteger(drop.Min, drop.Max))
				end
			end
		end
	end
end

return Rewards