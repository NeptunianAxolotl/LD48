local defs = {
	rock = {
		image = "rock_3",
		name = "rock",
		imageBase = "rock_",
		backImage = "dirt",
		toughness = 2,
		hitPoints = 3,
		canVein = true,
		wantDirt = true,
		spawnHealth = "rockSpawnHealth",
	},
	hard_rock = {
		image = "hard_rock_6",
		name = "hard_rock",
		imageBase = "hard_rock_",
		backImage = "dirt",
		toughness = 3,
		hitPoints = 6,
		canVein = true,
		wantDirt = true,
		spawnHealth = "hardRockSpawnHealth",
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
	space = {
		name = "space",
		toughness = 0,
		noBackground = true,
		isSpace = true
	},
}

return defs
