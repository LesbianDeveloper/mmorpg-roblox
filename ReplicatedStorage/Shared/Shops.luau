-- Cada tienda: lo que vende. Special = artículos que no son ítems del inventario.
return {
	General = {
		Name = "Mercader",
		Buy = {
			{ Item = "HealthPotion", Price = 25, Bulk = true,
				Description = "Cura el 40% de tu vida. Tarda en beberse." },
			{ Special = "SoulFlask", Name = "Frasco de alma", Price = 1500, Rarity = "Epic",
				Description = "Guarda un Alma de jefe. Se compra una vez y no se pierde (máx. 3)." },
		},
	},
}