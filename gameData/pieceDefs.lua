local pieceDefs = {
	{
		name = "r_3",
		tiles = {
			{0, 0},
			{0, 1},
			{1, 0},
		},
		border = {
			{-1, 0},
			{-1, 1},
			{0, -1},
			{1, -1},
			{0, 2},
			{2, 0},
			{1, 1},
		},
		carveStrength = 1,
		offsetX = 1,
		offsetY = 1,
	},
	{
		name = "l_3",
		tiles = {
			{-1, 0},
			{0, 0},
			{1, 0},
		},
		border = {
			{-2, 0},
			{2, 0},
			{-1, -1},
			{0, -1},
			{1, -1},
			{-1, 1},
			{0, 1},
			{1, 1},
		},
		carveStrength = 1,
		offsetX = 0.5,
		offsetY = 0.5,
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
		border = {
			{-2, 0},
			{-1, -1},
			{-1, 1},
			{0, -2},
			{1, -2},
			{2, -1},
			{1, 0},
			{1, 1},
			{0, 2},
		},
		carveStrength = 1,
		offsetX = 0.5,
		offsetY = 0.5,
	},
}

return pieceDefs
