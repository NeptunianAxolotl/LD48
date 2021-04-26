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
		name = "dirt_outer_s",
	},
	{
		name = "dirt",
	},
}

local defMults = {}
for i = 1, #defs do
	for j = 1, 4 do
		defMults[#defMults + 1] = {
			name = defs[i].name .. "_" .. j,
			form = "image",
			xScale = 32/400,
			yScale = 32/400,
			xOffset = defs[i].xOffset or 0,
			yOffset = defs[i].yOffset or 0,
			file = "resources/images/corners/" .. defs[i].name .. "_" .. j .. ".png",
		}
	end
end

return defMults
