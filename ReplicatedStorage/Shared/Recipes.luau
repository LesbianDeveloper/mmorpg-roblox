-- Station: en qué estación se fabrica. Order: orden en la lista.
return {
	RustySword = { Result = "RustySword", Station = "Forge", Order = 1, Gold = 3,
		Materials = { RustyIron = 4 } },
	BoneSword  = { Result = "BoneSword",  Station = "Forge", Order = 2, Gold = 10,
		Materials = { Bone = 6, RustyIron = 3 } },
	BoneHelm   = { Result = "BoneHelm",   Station = "Forge", Order = 3, Gold = 5,
		Materials = { Bone = 4, BoneDust = 1 } },
	BoneLegs   = { Result = "BoneLegs",   Station = "Forge", Order = 4, Gold = 8,
		Materials = { Bone = 6, RustyIron = 1 } },
	BoneChest  = { Result = "BoneChest",  Station = "Forge", Order = 5, Gold = 15,
		Materials = { Bone = 8, RustyIron = 2, BoneDust = 2 } },
}