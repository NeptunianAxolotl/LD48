local defs = {
	{
		name = "edge_n",
	},
	{
		name = "edge_s",
	},
	{
		name = "edge_w",
	},
	{
		name = "edge_e",
	},
	{
		name = "edge_nw_inner",
	},
	{
		name = "edge_sw_inner",
	},
	{
		name = "edge_ne_inner",
	},
	{
		name = "edge_se_inner",
	},
	{
		name = "edge_nw_outer",
	},
	{
		name = "edge_sw_outer",
	},
	{
		name = "edge_ne_outer",
	},
	{
		name = "edge_se_outer",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 32/400
	defs[i].yScale = 32/400
	defs[i].xOffset = 0
	defs[i].yOffset = 0
	defs[i].file = "resources/images/edging/" .. defs[i].name .. ".png"
end

return defs
