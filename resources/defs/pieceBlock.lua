local defs = {
	{
		name = "1I",
	},
	{
		name = "2I",
	},
	{
		name = "3I",
	},
	{
		name = "3L",
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
		name = "4L",
	},
	{
		name = "4J",
	},
	{
		name = "4O",
	},
	{
		name = "4T",
	},
	{
		name = "5O",
	},
	{
		name = "5P",
	},
	{
		name = "5Q",
	},
	{
		name = "5L",
	},
	{
		name = "5J",
	},
	{
		name = "5RL",
	},
	{
		name = "5RR",
	},
	{
		name = "5SL",
	},
	{
		name = "5SR",
	},
	{
		name = "5T",
	},
	{
		name = "5U",
	},
	{
		name = "5V",
	},
	{
		name = "5W",
	},
	{
		name = "5X",
	},
	{
		name = "5YL",
	},
	{
		name = "5YR",
	},
	{
		name = "5ZL",
	},
	{
		name = "5ZR",
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
