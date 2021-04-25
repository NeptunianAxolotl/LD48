local defs = {
	bomb = function (tile)
		tile.imageFile = "bomb"
		tile.explosionRadius = 1
		return tile
	end,
	nuke = function (tile)
		tile.imageFile = "nuke"
		tile.explosionRadius = 2
		return tile
	end,
	moneyMult = function (tile)
		tile.imageFile = "money_mult"
		tile.moneyMult = 2
		return tile
	end,
	vortex = function (tile)
		tile.imageFile = "blackhole"
		tile.vortex = true
		return tile
	end,
	cutter = function (tile)
		tile.imageFile = "diamond"
		tile.carveStrength = 2
		return tile
	end,
}

return defs
