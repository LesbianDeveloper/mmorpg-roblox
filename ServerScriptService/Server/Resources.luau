local Players = game:GetService("Players")

local Resources = {}

local CLASS_RESOURCE = { Warrior = "Rage", Mage = "Mana", Priest = "Mana" }
local RAGE_MAX = 100
local RAGE_PER_HIT = 6        -- Furia por golpe acertado
local RAGE_FROM_DAMAGE = 60   -- Furia por recibir el 100% de tu vida en daño (proporcional)
local RAGE_DECAY = 4          -- Furia que se pierde por segundo fuera de combate
local OUT_OF_COMBAT = 6       -- segundos sin pelear para considerar "fuera de combate"
local MANA_REGEN = 4          -- Maná por segundo

local lastCombat = {}

local function kindOf(player)
	return CLASS_RESOURCE[player:GetAttribute("Class")] or "Mana"
end

function Resources.get(player)
	return player:GetAttribute("Resource") or 0
end

-- Recalcula tipo y máximo (al entrar, cambiar de clase o de Intelecto)
function Resources.setup(player)
	local kind = kindOf(player)
	local max = kind == "Rage" and RAGE_MAX or (100 + (player:GetAttribute("Intellect") or 10) * 3)
	player:SetAttribute("ResourceType", kind)
	player:SetAttribute("MaxResource", max)
	local current = player:GetAttribute("Resource")
	if current == nil then
		current = kind == "Rage" and 0 or max
	end
	player:SetAttribute("Resource", math.min(current, max))
end

-- Al reaparecer: Furia en 0, Maná lleno
function Resources.reset(player)
	local kind = kindOf(player)
	player:SetAttribute("Resource", kind == "Rage" and 0 or (player:GetAttribute("MaxResource") or 100))
end

function Resources.gain(player, amount)
	local max = player:GetAttribute("MaxResource") or 100
	player:SetAttribute("Resource", math.clamp(Resources.get(player) + amount, 0, max))
	lastCombat[player] = os.clock()
end

function Resources.spend(player, amount)
	player:SetAttribute("Resource", math.max(0, Resources.get(player) - amount))
end

-- Llamado por CombatService cada vez que acertás un golpe
function Resources.onHit(player)
	lastCombat[player] = os.clock()
	if kindOf(player) == "Rage" then
		Resources.gain(player, RAGE_PER_HIT)
	end
end

-- Recibir daño da Furia
function Resources.watch(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local last = humanoid.Health
	humanoid.HealthChanged:Connect(function(health)
		if health < last then
			lastCombat[player] = os.clock()
			if kindOf(player) == "Rage" and humanoid.MaxHealth > 0 then
				Resources.gain(player, (last - health) / humanoid.MaxHealth * RAGE_FROM_DAMAGE)
			end
		end
		last = health
	end)
end

-- Regeneración de Maná y caída de Furia
task.spawn(function()
	while true do
		local dt = task.wait(0.25)
		for _, player in Players:GetPlayers() do
			local current = player:GetAttribute("Resource")
			local max = player:GetAttribute("MaxResource")
			if current and max then
				if player:GetAttribute("ResourceType") == "Rage" then
					if current > 0 and os.clock() - (lastCombat[player] or 0) > OUT_OF_COMBAT then
						player:SetAttribute("Resource", math.max(0, current - RAGE_DECAY * dt))
					end
				elseif current < max then
					player:SetAttribute("Resource", math.min(max, current + MANA_REGEN * dt))
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastCombat[player] = nil
end)

return Resources