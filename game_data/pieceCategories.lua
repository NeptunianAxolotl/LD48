
local COST_MULT = 0.9

local cats = {
	tiny = {
		list = {
			"1I",
			"2I",
		},
		size = 2,
		cost = 50 * COST_MULT,
		specialCost = 75 * COST_MULT,
		specialExtraCost = 40 * COST_MULT,
		desc = "Ideal for those hard-to-reach places.",
		plainRedraw = true,
	},
	small = {
		list = {
		"3I",
		"3L",
		},
		size = 3,
		cost = 80 * COST_MULT,
		specialCost = 100 * COST_MULT,
		specialExtraCost = 40 * COST_MULT,
		desc = "Your bog-standard three-block.",
		plainRedraw = true,
	},
	smallFour = {
		list = {
			"4S",
			"4Z",
			"4O",
			"4T",
		},
		size = 4,
		cost = 120 * COST_MULT,
		specialCost = 160 * COST_MULT,
		specialExtraCost = 40 * COST_MULT,
		desc = "Easy to control, easy to profit.",
		plainRedraw = true,
	},
	longFour = {
		list = {
			"4I",
			"4L",
			"4J",
		},
		size = 4,
		cost = 140 * COST_MULT,
		specialCost = 160 * COST_MULT,
		specialExtraCost = 35 * COST_MULT,
		desc = "Decent reach for a low price, and not too hard to position.",
		plainRedraw = true,
	},
	stumpyFive = {
		list = {
			"5X",
			"5PR",
			"5PL",
			"5U",
		},
		size = 5,
		cost = 180 * COST_MULT,
		specialCost = 150 * COST_MULT,
		specialExtraCost = 35 * COST_MULT,
		desc = "If you want a lot of tiles in a small space, look no further.",
	},
	mediumFive = {
		list = {
			"5RL",
			"5RR",
			"5W",
			"5V",
		},
		size = 5,
		cost = 190 * COST_MULT,
		specialCost = 150 * COST_MULT,
		specialExtraCost = 30 * COST_MULT,
		desc = "Don't let it fool you, this piece means mischief.",
	},
	bigFive = {
		list = {
			"5SL",
			"5SR",
			"5ZL",
			"5ZR",
		},
		size = 5,
		cost = 200 * COST_MULT,
		specialCost = 150 * COST_MULT,
		specialExtraCost = 30 * COST_MULT,
		desc = "A simple way to zig a lot of zag.",
	},
	longFive = {
		list = {
			"5O",
			"5L",
			"5J",
			"5YL",
			"5YR",
		},
		size = 5,
		cost = 220 * COST_MULT,
		specialCost = 150 * COST_MULT,
		specialExtraCost = 35 * COST_MULT,
		desc = "Extremely long, but tends to get caught on rocks.",
	},
}

return cats
