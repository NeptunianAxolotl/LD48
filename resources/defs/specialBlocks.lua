local defs = {
	{
		name = "bomb",
	},
	{
		name = "money_mult",
	},
	{
		name = "diamond",
	},
	{
		name = "blackhole",
	},
	{
		name = "nuke",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 0.2
	defs[i].yScale = 0.2
	defs[i].xOffset = 0.19
	defs[i].yOffset = 0.19
	defs[i].file = "resources/images/pieceblocks/" .. defs[i].name .. ".png"
end

return defs
