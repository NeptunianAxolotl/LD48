local defs = {
	bomb = function (tile)
		tile.imageFile = "bomb"
		tile.explosionRadius = 1
		return tile
	end,
	moneyMult = function (tile)
		tile.imageFile = "money_mult"
		tile.moneyMult = 2
		return tile
	end,
}

return defs
