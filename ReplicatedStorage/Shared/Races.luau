local Races = {}

Races.Tiers = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6 }

-- Chance = % de obtención (suman 100). Bonuses: 0.06 = +6%
Races.List = {
	{ Id = "Human",      Name = "Humano",       Rarity = "Common",    Chance = 70,
		Bonuses = { XPGain = 0.05 },                                   Ability = "Voluntad" },
	{ Id = "Dwarf",      Name = "Enano",        Rarity = "Uncommon",  Chance = 8,
		Bonuses = { Defense = 0.06, CraftArmor = 0.10 },               Ability = "Piel de piedra" },
	{ Id = "Orc",        Name = "Orco",         Rarity = "Uncommon",  Chance = 6,
		Bonuses = { MeleeDamage = 0.06, MaxHealth = 0.03 },            Ability = "Grito de guerra" },
	{ Id = "WoodElf",    Name = "Elfo silvano", Rarity = "Rare",      Chance = 4,
		Bonuses = { RangedDamage = 0.08, MoveSpeed = 0.05 },           Ability = "Paso del bosque" },
	{ Id = "Jotunn",     Name = "Jotunn",       Rarity = "Rare",      Chance = 3.5,
		Bonuses = { MaxHealth = 0.10, MeleeDamage = 0.06, FrostResist = 0.10 }, Ability = "Furia del invierno" },
	{ Id = "Nymph",      Name = "Ninfa",        Rarity = "Rare",      Chance = 3,
		Bonuses = { HealingDone = 0.10 },                              Ability = "Bendición del manantial" },
	{ Id = "DarkElf",    Name = "Elfo oscuro",  Rarity = "Epic",      Chance = 1.5,
		Bonuses = { MagicDamage = 0.10, ShadowResist = 0.06 },         Ability = "Velo" },
	{ Id = "Gorgon",     Name = "Gorgona",      Rarity = "Epic",      Chance = 1.1,
		Bonuses = { Agility = 0.08, PoisonDamage = 0.08 },             Ability = "Mirada de piedra" },
	{ Id = "AesirVanir", Name = "Æsir / Vanir", Rarity = "Epic",      Chance = 1.1,
		Bonuses = { MaxHealth = 0.05 },                                Ability = "Llamado del Valhalla",
		Lineages = {
			Aesir = { PhysicalDamage = 0.10 },
			Vanir = { MagicDamage = 0.10, HealingDone = 0.10 },
		} },
	{ Id = "Kitsune",    Name = "Kitsune",      Rarity = "Legendary", Chance = 0.7,
		Bonuses = { Agility = 0.10, CritChance = 0.10 },               Ability = "Kitsunebi" },
	{ Id = "Dragonkin",  Name = "Dracónido",    Rarity = "Legendary", Chance = 0.5,
		Bonuses = { MaxHealth = 0.12, FireResist = 0.15 },             Ability = "Aliento de fuego" },
	{ Id = "Angel",      Name = "Ángel",        Rarity = "Mythic",    Chance = 0.4,
		Bonuses = { HealingDone = 0.15, HolyDamage = 0.15, MaxHealth = 0.05, ShadowDamage = -0.10 }, Ability = "Gracia divina" },
	{ Id = "Demon",      Name = "Demonio",      Rarity = "Mythic",    Chance = 0.2,
		Bonuses = { AllDamage = 0.15, Lifesteal = 0.05, HealingReceived = -0.15 }, Ability = "Forma infernal" },
}

Races.ById = {}
for _, race in Races.List do
	Races.ById[race.Id] = race
end

return Races