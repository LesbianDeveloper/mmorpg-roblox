return {
	Skeleton = {
		Name = "Esqueleto",
		MaxHealth = 120,
		WalkSpeed = 12,
		AggroRange = 35,    -- distancia a la que te detecta
		LeashRange = 70,    -- si se aleja más que esto de su spawn, vuelve
		RespawnTime = 15,
		Attacks = {
			{ Name = "Tajo", Damage = 15, Range = 6, Windup = 0.5, Cooldown = 1.6, Animation = "Light1" },
			{ Name = "Golpe pesado", Damage = 30, Range = 7, Windup = 0.9, Cooldown = 3, Animation = "Heavy" },
		},
	},
}