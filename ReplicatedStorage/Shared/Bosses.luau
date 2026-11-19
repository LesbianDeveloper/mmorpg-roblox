return {
	SkeletonKing = {
		Name = "Rey Esqueleto",
		RecommendedLevel = 5,
		BaseHealth = 900,
		WalkSpeed = 10,
		EnragedWalkSpeed = 15,

		-- Escalado
		HealthPerLevel = 0.12,        -- +12% de vida por nivel (del jugador de nivel más alto)
		DamagePerLevel = 0.07,        -- +7% de daño por nivel
		HealthPerExtraPlayer = 0.6,   -- +60% de vida por cada jugador extra

		Cooldown = 20 * 60,           -- segundos de espera por jugador tras vencerlo

		-- Recompensas
		Essence = 500,
		Gold = { 80, 150 },
		Loot = {
			{ Item = "Bone",       Chance = 1,    Min = 8, Max = 15 },
			{ Item = "BoneDust",   Chance = 0.8,  Min = 2, Max = 5 },
			{ Item = "RustyIron",  Chance = 0.6,  Min = 3, Max = 6 },
			{ Item = "RuneOfFate", Chance = 0.15, Min = 1, Max = 1 },
		},
		Soul = {
			Name = "Alma del Rey Esqueleto",
			Capacity = 1500,      -- Esencia máxima que puede guardar
			BaseChance = 1.0,    -- 10% (para probar podés ponerlo en 1)
			LevelPenalty = 0.85,  -- ×0,85 por cada nivel por encima del recomendado
			MinChance = 0.01,
		},

		-- Ataques
		Attacks = {
			Combo = { Damage = 28, Range = 9, Windup = 0.6, SecondWindup = 0.45 },
			Slam  = { Damage = 45, Radius = 12, Windup = 1.2, Cooldown = 8 },
			Leap  = { Damage = 35, Radius = 8, Windup = 0.8, MinDistance = 14, Cooldown = 7 },
		},
		Minions = { Count = 2, Health = 80, Damage = 10 },
	},
}