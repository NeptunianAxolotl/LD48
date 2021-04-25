local defs = {
	{
		name = "3L",
	},
	{
		name = "3I",
	},
	{
		name = "4I",
	},
	{
		name = "4S",
	},
	{
		name = "4Z",
	},
	{
		name = "5R",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 0.25
	defs[i].yScale = 0.25
	defs[i].xOffset = 0
	defs[i].yOffset = 0
	defs[i].file = "resources/images/pieceblocks/" .. defs[i].name .. ".png"
end

return defs
