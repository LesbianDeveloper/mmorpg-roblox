return {
	Attacks = {
		Light = {
			Damage = { 10, 12, 16 },
			Stamina = 12,
			Cooldown = 0.4,
			Range = 6,
			Width = 5,
			ComboReset = 1.2,
		},
		Heavy = {
			Damage = 30,
			Stamina = 30,
			Cooldown = 1.1,
			Range = 7,
			Width = 6,
			Windup = 0.35,
		},
	},
	Dodge = {
		Stamina = 20,
		IFrames = 0.35,
		Cooldown = 0.5,
		Speed = 60,
		Duration = 0.2,
	},
	Block = {
		DamageReduction = 0.8,  -- bloquea el 80% del daño
		StaminaPerDamage = 1.5, -- estamina que cuesta cada punto de daño bloqueado
		ParryWindow = 0.25,     -- segundos tras apretar F en los que cuenta como parry
		ParryStun = 2.0,        -- aturdimiento al atacante tras un parry
		GuardBreakStun = 1.0,   -- aturdimiento propio si te rompen la guardia
		WalkSpeed = 8,          -- velocidad al bloquear (normal: 16)
		Cooldown = 0.5,         -- espera entre bloqueos
	},
	DummyAttack = {
		Interval = 3,           -- cada cuánto ataca el muñeco
		Windup = 0.6,           -- tiempo en rojo antes de pegar (tu señal)
		Damage = 25,
		Range = 8,
	},
	StaminaRegen = 30,
	RegenDelay = 0.8,
}