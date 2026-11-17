local Classes = {}

Classes.List = {
	-- Base (gratis)
	{ Id = "Warrior",      Name = "Guerrero",      Access = "Base", Enabled = true,
		Specs = { "Tank", "Damage" }, PrimaryStat = "Strength", Resource = "Rage",
		StatBonus = { Strength = 5, Vitality = 5, Endurance = 3 } },
	{ Id = "Mage",         Name = "Mago",          Access = "Base", Enabled = true,
		Specs = { "Fire", "Frost", "Arcane" }, PrimaryStat = "Intellect", Resource = "Mana",
		StatBonus = { Intellect = 8, Agility = 2 } },
	{ Id = "Priest",       Name = "Sacerdote",     Access = "Base", Enabled = true,
		Specs = { "Healing", "Shadow" }, PrimaryStat = "Intellect", Resource = "Mana",
		StatBonus = { Intellect = 6, Vitality = 3 } },
	{ Id = "Hunter",       Name = "Cazador",       Access = "Base", Enabled = false, PrimaryStat = "Agility",  Resource = "Focus" },
	{ Id = "Rogue",        Name = "Pícaro",        Access = "Base", Enabled = false, PrimaryStat = "Agility",  Resource = "Energy" },
	{ Id = "Paladin",      Name = "Paladín",       Access = "Base", Enabled = false, PrimaryStat = "Strength", Resource = "Mana" },
	{ Id = "Druid",        Name = "Druida",        Access = "Base", Enabled = false, PrimaryStat = "Agility",  Resource = "Mana" },
	-- Premium (Robux o desbloqueo jugando)
	{ Id = "Warlock",      Name = "Brujo",         Access = "Premium", Enabled = false, PrimaryStat = "Intellect", Resource = "Mana" },
	{ Id = "Shaman",       Name = "Chamán",        Access = "Premium", Enabled = false, PrimaryStat = "Intellect", Resource = "Mana" },
	{ Id = "Monk",         Name = "Monje",         Access = "Premium", Enabled = false, PrimaryStat = "Agility",   Resource = "Chi" },
	{ Id = "Bard",         Name = "Bardo",         Access = "Premium", Enabled = false, PrimaryStat = "Intellect", Resource = "Inspiration" },
	{ Id = "Valkyrie",     Name = "Valquiria",     Access = "Premium", Enabled = false, PrimaryStat = "Strength",  Resource = "Rage" },
	{ Id = "Ronin",        Name = "Ronin",         Access = "Premium", Enabled = false, PrimaryStat = "Agility",   Resource = "Focus" },
	{ Id = "Alchemist",    Name = "Alquimista",    Access = "Premium", Enabled = false, PrimaryStat = "Intellect", Resource = "Reagents" },
	-- Heroicas
	{ Id = "DeathKnight",  Name = "Caballero de la Muerte", Access = "Heroic", Enabled = false, PrimaryStat = "Strength", Resource = "Runes" },
	{ Id = "DemonHunter",  Name = "Cazador de demonios",    Access = "Heroic", Enabled = false, PrimaryStat = "Agility",  Resource = "Fury" },
	-- Exclusiva de raza
	{ Id = "Evoker",       Name = "Evocador",      Access = "RaceExclusive", RequiredRace = "Dragonkin", Enabled = false,
		PrimaryStat = "Intellect", Resource = "Essence" },
}

Classes.ById = {}
for _, class in Classes.List do
	Classes.ById[class.Id] = class
end

return Classes