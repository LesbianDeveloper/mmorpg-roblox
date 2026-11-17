local Races = require(script.Parent.Races)
local Classes = require(script.Parent.Classes)

local Stats = {}

-- Fuerza, Agilidad, Intelecto, Vitalidad, Aguante
Stats.Base = { Strength = 10, Agility = 10, Intellect = 10, Vitality = 10, Endurance = 10 }

function Stats.XPForLevel(level)
	return math.floor(100 * level ^ 1.5)
end

-- Calcula los stats finales según raza, clase y nivel
function Stats.compute(raceId, classId, level)
	local final = table.clone(Stats.Base)
	local class = Classes.ById[classId]
	local race = Races.ById[raceId]
	local bonus = race and race.Bonuses or {}

	for stat in Stats.Base do
		final[stat] += (level - 1) -- +1 a todo por nivel
	end
	if class then
		for stat, value in class.StatBonus or {} do
			final[stat] += value
		end
		final[class.PrimaryStat] += (level - 1) -- +1 extra al stat principal
	end
	for stat in Stats.Base do -- bonus % de raza sobre stats (ej. Kitsune +10% Agilidad)
		if bonus[stat] then
			final[stat] = math.floor(final[stat] * (1 + bonus[stat]))
		end
	end

	final.MaxHealth = math.floor((100 + final.Vitality * 10) * (1 + (bonus.MaxHealth or 0)))
	final.MaxStamina = 100 + final.Endurance * 5
	return final
end

return Stats