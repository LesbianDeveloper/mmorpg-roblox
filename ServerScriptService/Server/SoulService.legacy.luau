local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bosses = require(ReplicatedStorage.Shared.Bosses)
local PlayerData = require(script.Parent.PlayerData)

local notify = ReplicatedStorage:WaitForChild("Notify")
local SHRINE_RANGE = 14

local request = Instance.new("RemoteFunction")
request.Name = "SoulRequest"
request.Parent = ReplicatedStorage

local function isNearShrine(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local shrines = workspace:FindFirstChild("Shrines")
	if not root or not shrines then return false end
	for _, shrine in shrines:GetChildren() do
		if (shrine:GetPivot().Position - root.Position).Magnitude <= SHRINE_RANGE then
			return true
		end
	end
	return false
end

local function soulInfo(soul)
	local boss = Bosses[soul.Boss]
	return {
		Name = boss and boss.Soul.Name or "Alma desconocida",
		Capacity = boss and boss.Soul.Capacity or 0,
		Essence = soul.Essence,
	}
end

local function snapshot(data)
	local list = {}
	for i, soul in data.Souls or {} do
		list[i] = soulInfo(soul)
	end
	return { Souls = list, Flasks = data.SoulFlasks or 0, Essence = data.Essence or 0 }
end

request.OnServerInvoke = function(player, action, index, amount)
	local data = PlayerData.get(player)
	if not data then return false, "Datos no cargados" end
	data.Souls = data.Souls or {}

	if action == "get" then
		return true, "", snapshot(data)
	end

	local soul = typeof(index) == "number" and data.Souls[index]
	if not soul then
		return false, "No hay un Alma ahí", snapshot(data)
	end
	local info = soulInfo(soul)

	if action == "deposit" then
		local space = info.Capacity - soul.Essence
		if space <= 0 then
			return false, "Esa Alma está llena", snapshot(data)
		end
		local carried = data.Essence or 0
		if carried <= 0 then
			return false, "No llevás Esencia", snapshot(data)
		end
		local wanted = amount == "all" and carried or (typeof(amount) == "number" and math.floor(amount) or 0)
		local moved = math.min(wanted, carried, space)
		if moved <= 0 then
			return false, "Nada para guardar", snapshot(data)
		end
		soul.Essence += moved
		PlayerData.set(player, "Essence", carried - moved)
		return true, string.format("Guardaste %d de Esencia en %s", moved, info.Name), snapshot(data)

	elseif action == "release" then
		if not isNearShrine(player) then
			return false, "Solo podés liberar un Alma junto a un Santuario", snapshot(data)
		end
		table.remove(data.Souls, index)
		PlayerData.set(player, "Essence", (data.Essence or 0) + soul.Essence)
		PlayerData.save(player)
		notify:FireClient(player, string.format("Liberaste %s (+%d Esencia)", info.Name, soul.Essence), "Mythic")
		return true, "El Alma se consumió. El frasco quedó vacío.", snapshot(data)
	end

	return false, "Acción inválida", snapshot(data)
end