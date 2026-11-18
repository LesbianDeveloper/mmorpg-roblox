return {
	Skeleton = {
		Name = "Esqueleto",
		MaxHealth = 120,
		WalkSpeed = 12,
		AggroRange = 35,
		LeashRange = 70,
		RespawnTime = 15,
		XP = 40,
		Gold = { 2, 6 }, -- mínimo y máximo
		Attacks = {
			{ Name = "Tajo", Damage = 15, Range = 6, Windup = 0.5, Cooldown = 1.6, Animation = "Light1" },
			{ Name = "Golpe pesado", Damage = 30, Range = 7, Windup = 0.9, Cooldown = 3, Animation = "Heavy" },
		},
		Loot = { -- Chance: 0.8 = 80%
			{ Item = "Bone",       Chance = 0.8,  Min = 1, Max = 3 },
			{ Item = "RustyIron",  Chance = 0.4,  Min = 1, Max = 2 },
			{ Item = "BoneDust",   Chance = 0.15, Min = 1, Max = 1 },
			{ Item = "RuneOfFate", Chance = 0.03, Min = 1, Max = 1 },
			{ Item = "RustySword", Chance = 0.05, Min = 1, Max = 1 },
		},
	},
}