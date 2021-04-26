local defs = {
	{
		name = "dirt_inner_ne",
	},
	{
		name = "dirt_inner_nw",
	},
	{
		name = "dirt_inner_se",
	},
	{
		name = "dirt_inner_sw",
	},
	{
		name = "dirt_outer_ne",
	},
	{
		name = "dirt_outer_nw",
	},
	{
		name = "dirt_outer_se",
	},
	{
		name = "dirt_outer_sw",
	},
	{
		name = "dirt_outer_n",
	},
	{
		name = "dirt_outer_w",
	},
	{
		name = "dirt_outer_e",
	},
	{
		name = "dirt_outer_e_1",
	},
	{
		name = "dirt_outer_e_2",
	},
	{
		name = "dirt_outer_e_3",
	},
	{
		name = "dirt_outer_e_4",
	},
	{
		name = "dirt_outer_s",
	},
	{
		name = "dirt_1",
	},
	{
		name = "dirt_2",
	},
	{
		name = "dirt_3",
	},
	{
		name = "dirt_4",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 32/400
	defs[i].yScale = 32/400
	defs[i].xOffset = defs[i].xOffset or 0
	defs[i].yOffset = defs[i].yOffset or 0
	defs[i].file = "resources/images/corners/" .. defs[i].name .. ".png"
end

return defs
