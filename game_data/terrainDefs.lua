local defs = {
	rock = {
		image = "rock",
		name = "rock",
		imageBase = "rock_",
		backImage = "dirt",
		toughness = 2,
		hitPoints = 3,
		canVein = true,
		wantDirt = true,
	},
	coal = {
		image = "coal",
		name = "coal",
		backImage = "dirt",
		toughness = 1,
		value = 20,
		canVein = true,
		wantDirt = true,
	},
	gold = {
		image = "gold",
		name = "gold",
		backImage = "dirt",
		toughness = 1,
		value = 50,
		canVein = true,
		wantDirt = true,
	},
	diamond = {
		image = "diamond_block",
		name = "diamond",
		backImage = "dirt",
		toughness = 1,
		value = 250,
		canVein = true,
		wantDirt = true,
	},
	dirt = {
		image = "dirt",
		name = "dirt",
		toughness = 1,
		wantDirt = true,
	},
}

return defs
