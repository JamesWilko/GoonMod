
CloneClass( HUDBlackScreen )

Hooks:RegisterHook( "HUDBlackScreenSetJobData" )
function HUDBlackScreen.set_job_data(self)

	Hooks:PCall("HUDBlackScreenSetJobData", self)

	if not managers.job:has_active_job() then
		return
	end

	local job_panel = self._blackscreen_panel:panel({
		visible = true,
		name = "job_panel",
		y = 0,
		valign = "grow",
		halign = "grow",
		layer = 1
	})
	local risk_panel = job_panel:panel({})
	local last_risk_level
	local blackscreen_risk_textures = tweak_data.gui.blackscreen_risk_textures
	for i = 1, managers.job:current_difficulty_stars() do
		local difficulty_name = tweak_data.difficulties[i + 2]
		local texture = blackscreen_risk_textures[difficulty_name] or "guis/textures/pd2/risklevel_blackscreen"
		last_risk_level = risk_panel:bitmap({
			texture = texture,
			color = (GoonHUD.Ironman:IsEnabled() and tweak_data.screen_colors.important_1) or tweak_data.screen_colors.risk
		})
		last_risk_level:move((i - 1) * last_risk_level:w(), 0)
	end

	if last_risk_level then
		risk_panel:set_size(last_risk_level:right(), last_risk_level:bottom())
		risk_panel:set_center(job_panel:w() / 2, job_panel:h() / 2)
		risk_panel:set_position(math.round(risk_panel:x()), math.round(risk_panel:y()))
		local risk_text = job_panel:text({
			text = managers.localization:to_upper_text(tweak_data.difficulty_name_id),
			font = tweak_data.menu.pd2_large_font,
			font_size = tweak_data.menu.pd2_small_large_size,
			align = "center",
			vertical = "bottom",
			color = (GoonHUD.Ironman:IsEnabled() and tweak_data.screen_colors.important_1) or tweak_data.screen_colors.risk
		})
		risk_text:set_bottom(risk_panel:top())
		risk_text:set_center_x(risk_panel:center_x())
	else
		risk_panel:set_size(64, 64)
		risk_panel:set_center_x(job_panel:w() / 2)
		risk_panel:set_bottom(job_panel:h() / 2)
		risk_panel:set_position(math.round(risk_panel:x()), math.round(risk_panel:y()))
	end

	do return end
	local contact_data = managers.job:current_contact_data()
	local job_data = managers.job:current_job_data()
	if self._blackscreen_panel:child("job_panel") then
		self._blackscreen_panel:remove(self._blackscreen_panel:child("job_panel"))
	end

	local job_panel = self._blackscreen_panel:panel({
		visible = true,
		name = "job_panel",
		y = 0,
		valign = "grow",
		halign = "grow",
		layer = 0
	})
	job_panel:hide()
	job_panel:text({
		name = "title",
		text = managers.localization:text(job_data.name_id),
		layer = 1,
		align = "center",
		vertical = "top",
		font_size = tweak_data.hud.default_font_size,
		font = tweak_data.hud.medium_font,
		w = job_panel:w(),
		h = 32
	})
	local contact_name = job_panel:text({
		name = "contact_name",
		text = managers.localization:text(contact_data.name_id),
		layer = 1,
		align = "left",
		vertical = "top",
		font_size = tweak_data.hud.default_font_size,
		font = tweak_data.hud.medium_font,
		w = job_panel:w(),
		h = 32,
		y = 50
	})
	local portrait = job_panel:bitmap({
		name = "portrait",
		texture = contact_data.image,
		y = contact_name:bottom()
	})
	job_panel:text({
		name = "payout",
		text = "Payout: $1.000.000",
		layer = 1,
		align = "left",
		vertical = "top",
		font_size = tweak_data.hud.default_font_size,
		font = tweak_data.hud.medium_font,
		w = job_panel:w(),
		h = 32,
		y = portrait:bottom() + 32
	})
	self:_create_stages()
	local level_data = managers.job:current_level_data()
	local objective_title = job_panel:text({
		name = "objective_title",
		text = managers.localization:text("hud_objectives"),
		layer = 1,
		align = "left",
		vertical = "top",
		font_size = tweak_data.hud.default_font_size,
		font = tweak_data.hud.medium_font,
		w = job_panel:w(),
		h = 32,
		y = job_panel:h() / 2
	})
	local objective_text = job_panel:text({
		name = "objective_text",
		text = managers.localization:text(level_data.briefing_id),
		layer = 1,
		align = "left",
		vertical = "top",
		font_size = tweak_data.hud.small_font_size,
		font = tweak_data.hud.small_font,
		w = job_panel:w(),
		h = 32,
		y = job_panel:h() / 2 + 50,
		wrap = true,
		word_wrap = true
	})

end
