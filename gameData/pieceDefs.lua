local pieceDefs = {
	{
		name = "r_3",
		tiles = {
			{0, 0},
			{0, 1},
			{1, 0},
		},
		carveStrength = 1,
	},
	{
		name = "l_3",
		tiles = {
			{-1, 0},
			{0, 0},
			{1, 0},
		},
		carveStrength = 1,
	},
	{
		name = "r_5",
		tiles = {
			{-1, 0},
			{0, -1},
			{0, 0},
			{0, 1},
			{1, -1},
		},
		carveStrength = 1,
	},
}

return pieceDefs
