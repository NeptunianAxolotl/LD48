local defs = {
	rock = {
		image = "rock",
		name = "rock",
		imageBase = "rock_",
		backImage = "dirt",
		toughness = 2,
		hitPoints = 3,
		canVein = true,
	},
	coal = {
		image = "coal",
		name = "coal",
		backImage = "dirt",
		toughness = 1,
		value = 20,
		canVein = true,
	},
	gold = {
		image = "gold",
		name = "gold",
		backImage = "dirt",
		toughness = 1,
		value = 50,
		canVein = true,
	},
	diamond = {
		image = "diamond_block",
		name = "diamond",
		backImage = "dirt",
		toughness = 1,
		value = 250,
		canVein = true,
	},
	dirt = {
		image = "dirt",
		name = "dirt",
		toughness = 1,
	},
}

return defs
