
CloneClass( HUDStageEndScreen )

local make_fine_text = function(text)
	local x, y, w, h = text:text_rect()
	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
	return x, y, w, h
end

function HUDStageEndScreen.init(this, hud, workspace)
	local temp = tweak_data.screen_colors.risk
	tweak_data.screen_colors.risk = (GoonHUD.Ironman:IsEnabled() and tweak_data.screen_colors.important_1) or tweak_data.screen_colors.risk
	this.orig.init(this, hud, workspace)
	tweak_data.screen_colors.risk = temp
end

function HUDStageEndScreen:stage_init(t, dt)

	local success, err = pcall(function()

	local data = self._data
	self._lp_text:show()
	self._lp_circle:show()
	self._lp_backpanel:child("bg_progress_circle"):show()
	self._lp_forepanel:child("level_progress_text"):show()
	if managers.experience:reached_level_cap() then
		self._lp_text:set_text(tostring(data.start_t.level))
		self._lp_circle:set_color(Color(1, 1, 1))
		managers.menu_component:post_event("box_tick")
		self:step_stage_to_end()
		return
	end

	self._lp_circle:set_alpha(0)
	self._lp_backpanel:child("bg_progress_circle"):set_alpha(0)
	self._lp_text:set_alpha(0)
	self._bonuses_panel = self._lp_forepanel:panel({
		x = self._lp_xp_gained:x(),
		y = 10,
		w = self._lp_forepanel:w() - self._lp_xp_gained:left() - 10,
		h = self._lp_xp_gained:top() - 10
	})
	self._anim_exp_bonus = nil
	local bonus_params = {
		panel = self._bonuses_panel,
		color = tweak_data.screen_colors.text
	}
	bonus_params.title = managers.localization:to_upper_text("menu_experience")
	bonus_params.bonus = 0
	local exp = self:_create_bonus(bonus_params)
	exp:child("sign"):hide()
	self._experience_text_panel = exp
	self._experience_text_panel:set_alpha(0)
	self._experience_added = 0
	bonus_params.title = managers.localization:to_upper_text("menu_es_base_xp_stage")
	bonus_params.bonus = data.bonuses.stage_xp
	local stage = self:_create_bonus(bonus_params)
	stage:set_right(0)
	stage:set_top(exp:bottom())
	self._bonuses = {}
	table.insert(self._bonuses, {
		stage,
		bonus_params.bonus
	})
	local job
	if data.bonuses.last_stage and data.bonuses.job_xp ~= 0 then
		bonus_params.title = managers.localization:to_upper_text("menu_es_base_xp_job")
		bonus_params.bonus = data.bonuses.job_xp
		job = self:_create_bonus(bonus_params)
		job:set_right(0)
		job:set_top(exp:bottom())
		table.insert(self._bonuses, {
			job,
			bonus_params.bonus
		})
	end

	local heat_xp = self._bonuses.heat_xp or 0
	local heat = managers.job:last_known_heat() or managers.job:current_job_id() and managers.job:get_job_heat(managers.job:current_job_id()) or 0
	local heat_color = managers.job:get_heat_color(heat)
	local bonuses_list = {
		"bonus_days",
		"bonus_low_level",
		"bonus_risk",
		"bonus_failed",
		"in_custody",
		"bonus_num_players",
		"bonus_skill",
		"bonus_infamy",
		"bonus_gage_assignment",
		"bonus_extra",
		"bonus_ghost",
		"heat_xp",
		"bonus_ironman"
	}
	local bonuses_params = {}
	bonuses_params.bonus_days = {
		color = tweak_data.screen_colors.text,
		title = managers.localization:to_upper_text("menu_es_day_bonus")
	}
	bonuses_params.bonus_low_level = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_alive_low_level_bonus")
	}
	bonuses_params.bonus_risk = {
		color = tweak_data.screen_colors.risk,
		title = managers.localization:to_upper_text("menu_es_risk_bonus")
	}
	bonuses_params.bonus_failed = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_alive_failed_bonus")
	}
	bonuses_params.in_custody = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_in_custody_reduction")
	}
	bonuses_params.bonus_num_players = {
		color = tweak_data.screen_colors.risk,
		title = managers.localization:to_upper_text("menu_es_alive_players_bonus")
	}
	bonuses_params.bonus_skill = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_skill_bonus")
	}
	bonuses_params.bonus_infamy = {
		color = tweak_data.lootdrop.global_values.infamy.color,
		title = managers.localization:to_upper_text("menu_es_infamy_bonus")
	}
	bonuses_params.bonus_gage_assignment = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_gage_assignment_bonus")
	}
	bonuses_params.bonus_extra = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_extra_bonus")
	}
	bonuses_params.bonus_ghost = {
		color = tweak_data.screen_colors.ghost_color,
		title = managers.localization:to_upper_text("menu_es_ghost_bonus")
	}
	bonuses_params.heat_xp = {
		color = heat_color,
		title = managers.localization:to_upper_text(heat >= 0 and "menu_es_heat_bonus" or "menu_es_heat_reduction")
	}
	bonuses_params.bonus_ironman = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("Ironman_HeistExperience")
	}

	if GoonHUD.Ironman:IsEnabled() then

		local total_exp = 0
		for k, v in pairs(data.bonuses) do
			if type(v) == "number" then
				total_exp = total_exp + v
			end
		end
		data.bonuses["bonus_ironman"] = math.ceil(total_exp * 0.2)

	end

	for k, func_name in ipairs(bonuses_list) do

		local bonus = data.bonuses[func_name] or 0
		if bonus ~= 0 then
			bonus_params.color = bonuses_params[func_name] and bonuses_params[func_name].color or Color.purple
			bonus_params.title = bonuses_params[func_name] and bonuses_params[func_name].title or "ERR: " .. func_name
			bonus_params.bonus = bonus
			local b = self:_create_bonus(bonus_params)
			b:set_right(0)
			b:set_top(exp:bottom())
			table.insert(self._bonuses, {
				b,
				bonus_params.bonus
			})
		end

	end

	local delay = 0.8
	local y = 0
	if SystemInfo:platform() == Idstring("WIN32") then
	end

	local sum_text = self._lp_forepanel:text({
		name = "sum_text",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		text = "= ",
		align = "right",
		alpha = 1
	})
	make_fine_text(sum_text)
	sum_text:set_righttop(self._lp_xp_gain:left(), self._lp_xp_gain:top())
	sum_text:hide()
	self._sum_text = sum_text
	self._lp_circle:set_color(Color(data.start_t.current / data.start_t.total, 1, 1))
	self._wait_t = t + 0.5
	self._start_ramp_up_t = 1
	self._ramp_up_timer = 0
	managers.menu_component:post_event("box_tick")
	self:step_stage_up()

	end)

	if not success then
		Print(err)
	end

end
