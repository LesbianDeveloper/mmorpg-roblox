return {
	-- Materiales
	Bone       = { Name = "Hueso",            Type = "Material", Rarity = "Common" },
	RustyIron  = { Name = "Hierro oxidado",   Type = "Material", Rarity = "Common" },
	BoneDust   = { Name = "Polvo de hueso",   Type = "Material", Rarity = "Uncommon" },
	-- Monedas (Field: suma a ese dato del jugador en vez de ir al inventario)
	RuneOfFate = { Name = "Runa del Destino", Type = "Currency", Rarity = "Epic", Field = "Runes" },

	-- Consumibles (van en la barra rápida)
	HealthPotion = { Name = "Poción de vida", Type = "Consumable", Rarity = "Common",
		Heal = 0.4,      -- cura el 40% de la vida máxima
		UseTime = 1.2,   -- segundos bebiendo (vulnerable)
		Cooldown = 2,
		Price = 25 },    -- para la tienda

	-- Armas (van en la barra rápida)
	RustySword = { Name = "Espada oxidada",   Type = "Weapon", Slot = "Weapon", Rarity = "Common",
		Color = Color3.fromRGB(140, 95, 60), Stats = { WeaponDamage = 4 } },
	BoneSword  = { Name = "Espada de hueso",  Type = "Weapon", Slot = "Weapon", Rarity = "Uncommon",
		Color = Color3.fromRGB(230, 225, 205), Stats = { WeaponDamage = 8, Strength = 2 } },

	-- Armaduras (van en la ventana de equipo)
	BoneHelm   = { Name = "Yelmo de hueso",   Type = "Armor", Slot = "Head",  Rarity = "Common",
		Stats = { Defense = 5, Vitality = 2 } },
	BoneChest  = { Name = "Coraza de hueso",  Type = "Armor", Slot = "Chest", Rarity = "Uncommon",
		Stats = { Defense = 12, Vitality = 4 } },
	BoneLegs   = { Name = "Grebas de hueso",  Type = "Armor", Slot = "Legs",  Rarity = "Common",
		Stats = { Defense = 8, Vitality = 2 } },
}