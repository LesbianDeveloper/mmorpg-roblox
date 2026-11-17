return {
	Attacks = {
		Light = {
			Damage = { 10, 12, 16 }, -- daño de cada golpe del combo
			Stamina = 12,
			Cooldown = 0.4,
			Range = 6,          -- alcance hacia adelante (studs)
			Width = 5,
			ComboReset = 1.2,   -- si esperás más que esto, el combo vuelve al golpe 1
		},
		Heavy = {
			Damage = 30,
			Stamina = 30,
			Cooldown = 1.1,
			Range = 7,
			Width = 6,
			Windup = 0.35,      -- tiempo de "carga" antes de que pegue
		},
	},
	Dodge = {
		Stamina = 20,
		IFrames = 0.35,         -- segundos de invulnerabilidad
		Cooldown = 0.5,
		Speed = 60,
		Duration = 0.2,
	},
	StaminaRegen = 30,          -- estamina por segundo
	RegenDelay = 0.8,           -- segundos sin gastar antes de regenerar
}