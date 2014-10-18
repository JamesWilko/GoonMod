----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( PrePlanningTweakData )

function PrePlanningTweakData._create_locations(this, tweak_data)

	this.orig._create_locations(this, tweak_data)

	this.locations.branchbank = {
		default_plans = {
			escape_plan = "escape_helicopter_loud",
			vault_plan = "vault_big_drill"
		},
		total_budget = 10,
		start_location = {
			group = "a",
			x = 1500,
			y = 1025,
			zoom = 1.5
		},
		{
			name_id = "menu_pp_big_loc_a",
			texture = "guis/textures/pd2/mission_briefing/assets/bank/assets_bank_blueprint",
			map_x = -1.1,
			map_y = 0.5,
			map_size = 1,
			x1 = -250,
			y1 = -3000,
			x2 = 5750,
			y2 = 3000,
			rotation = 0,
			custom_points = {}
		}
	}

end

-- END OF FILE
