local defs = {
	bomb = {
		tileFunc = function (tile)
			tile.imageFile = "bomb"
			tile.explosionRadius = 1
			return tile
		end,
		pieceFunc = function (piece)
			piece.desc = "Contains explosives that destroy dirt, rocks and, unfortunately, resources."
			return piece
		end,
		specialCostMult = 1.2,
	},
	nuke = {
		tileFunc = function (tile)
			tile.imageFile = "nuke"
			tile.explosionRadius = 2
			return tile
		end,
		pieceFunc = function (piece)
			piece.desc = "The war on rocks just went nuclear. Point away from gold and/or face."
			return piece
		end,
		specialCostMult = 2.6,
		specialCostBoost = 300,
	},
	moneyMult = {
		tileFunc = function (tile)
			tile.imageFile = "money_mult"
			tile.moneyMult = 2
			return tile
		end,
		pieceFunc = function (piece)
			piece.desc = "Double the money gained for resources mined by golden tiles."
			return piece
		end,
		specialCostMult = 1.2,
	},
	vortex = {
		tileFunc = function (tile)
			tile.imageFile = "blackhole"
			tile.vortex = true
			return tile
		end,
		pieceFunc = function (piece)
			piece.desc = "Opens a vortex that annihilates both this piece and the next to touch it."
			return piece
		end,
		specialCostMult = 0.9,
	},
	cutter = {
		tileFunc = function (tile)
			tile.imageFile = "diamond"
			return tile
		end,
		pieceFunc = function (piece)
			piece.carveStrength = piece.carveStrength + 1
			if piece.carveStrength > 2 then
				piece.desc = "With Diamond Drills you can cut through anything!"
			else
				piece.desc = "Rocks, what rocks? The Diamond Drill cuts through (most) rocks like butter!"
			end
			return piece
		end,
		specialCostMult = 1.1,
		atLeastTwoSpecialCostBoost = 450,
	},
}

return defs
