local defs = {
	bomb = {
		tileFunc = function (tile)
			tile.imageFile = "bomb"
			tile.explosionRadius = 1
			return tile
		end,
	},
	nuke = {
		tileFunc = function (tile)
			tile.imageFile = "nuke"
			tile.explosionRadius = 2
			return tile
		end,
	},
	moneyMult = {
		tileFunc = function (tile)
			tile.imageFile = "money_mult"
			tile.moneyMult = 2
			return tile
		end,
	},
	vortex = {
		tileFunc = function (tile)
			tile.imageFile = "blackhole"
			tile.vortex = true
			return tile
		end,
	},
	cutter = {
		tileFunc = function (tile)
			tile.imageFile = "diamond"
			return tile
		end,
		pieceFunc = function (piece)
			piece.carveStrength = 2
			return piece
		end,
	},
}

return defs
