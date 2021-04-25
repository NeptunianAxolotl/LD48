local defs = {
	bomb = function (tile)
		tile.imageFile = "bomb"
		tile.explosionRadius = 1
		return tile
	end,
}

return defs
