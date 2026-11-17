local Stats = {}

Stats.Base = {
	MaxHealth = 100,
	MaxStamina = 100,
	Strength = 10,
	Dexterity = 10,
	Intelligence = 10,
}

-- XP necesaria para pasar de nivel (crece con cada nivel)
function Stats.XPForLevel(level)
	return math.floor(100 * level ^ 1.5)
end

return Stats