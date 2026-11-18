local Races = require(script.Parent.Races)
local Classes = require(script.Parent.Classes)
local Items = require(script.Parent.Items)

local Stats = {}

-- Fuerza, Agilidad, Intelecto, Vitalidad, Aguante
Stats.Base = { Strength = 10, Agility = 10, Intellect = 10, Vitality = 10, Endurance = 10 }

function Stats.XPForLevel(level)
	return math.floor(100 * level ^ 1.5)
end

-- Stats finales según raza, clase, nivel y equipo
function Stats.compute(raceId, classId, level, equipment)
	local final = table.clone(Stats.Base)
	final.Defense = 0
	final.WeaponDamage = 0

	local class = Classes.ById[classId]
	local race = Races.ById[raceId]
	local bonus = race and race.Bonuses or {}

	for stat in Stats.Base do
		final[stat] += (level - 1)
	end
	if class then
		for stat, value in class.StatBonus or {} do
			final[stat] += value
		end
		final[class.PrimaryStat] += (level - 1)
	end

	-- Equipo
	for _, itemId in equipment or {} do
		local item = Items[itemId]
		if item and item.Stats then
			for stat, value in item.Stats do
				final[stat] = (final[stat] or 0) + value
			end
		end
	end

	-- Bonus % de raza sobre stats
	for stat in Stats.Base do
		if bonus[stat] then
			final[stat] = math.floor(final[stat] * (1 + bonus[stat]))
		end
	end
	if bonus.Defense then
		final.Defense = math.floor(final.Defense * (1 + bonus.Defense))
	end

	final.MaxHealth = math.floor((100 + final.Vitality * 10) * (1 + (bonus.MaxHealth or 0)))
	final.MaxStamina = 100 + final.Endurance * 5
	return final
end

return Stats