
CloneClass( GroupAIStateBesiege )

Hooks:RegisterHook("GroupAIStateBesiegeInit")
function GroupAIStateBesiege.init(self)
	self.orig.init(self)
	Hooks:Call("GroupAIStateBesiegeInit", self)
end

--[[
function GroupAIStateBesiege:_assign_groups_to_retire(allowed_groups, suitable_grp_func)
	-- Never back down
end

function GroupAIStateBesiege:_upd_group_spawning()

	-- Print("Update spawn groups, num groups: ", #self._spawning_groups)
	for k, v in pairs( self._spawning_groups ) do
		self:_update_individual_group_spawning(k)
	end

end

function GroupAIStateBesiege:_queue_police_upd_task()
	self._police_upd_task_queued = true
	managers.enemy:queue_task("GroupAIStateBesiege._upd_police_activity", GroupAIStateBesiege._upd_police_activity, self, self._t + (next(self._spawning_groups) and 0.0166 or 2))
end

function GroupAIStateBesiege:_update_individual_group_spawning(id)

	local spawn_task = self._spawning_groups[id]
	if not spawn_task then
		return
	end
	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts
	local function _try_spawn_unit(u_type_name, spawn_entry)
		if nr_units_spawned >= GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS then
			return
		end
		local hopeless = true
		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]
			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() then
				hopeless = false
				if self._t > sp_data.delay_t then
					produce_data.name = category.units[math.random(#category.units)]
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective
					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)
						if not objective then
							spawned_unit:set_slot(0)
							return true
						end
						objective.grp_objective = spawn_task.group.objective
					end
					local u_data = self._police[u_key]
					self:set_enemy_assigned(objective.area, u_key)
					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}
						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end
					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)
					u_data.rank = spawn_entry.rank
					self:_add_group_member(spawn_task.group, u_key)
					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end
						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end
					nr_units_spawned = nr_units_spawned + 1
					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
					end
					sp_data.delay_t = self._t + sp_data.interval
					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end
					return true
				end
			end
		end
		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)
			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)
				if success then
					spawn_info.amount = spawn_info.amount - 1
				end
			end
		end
	end
	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)
			if success then
				spawn_info.amount = spawn_info.amount - 1
			end
		end
	end
	local complete = true
	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if 0 < spawn_info.amount then
			complete = false
		else
		end
	end
	if complete then
		Print("Finished spawning group: ", tostring( spawn_task.group.id ))
		spawn_task.group.has_spawned = true
		table.remove(self._spawning_groups, 1)
		if 0 >= spawn_task.group.size then
			self._groups[spawn_task.group.id] = nil
		end
	end
end

function GroupAIStateBesiege:_upd_recon_tasks()
	local task_data = self._task_data.recon.tasks[1]
	self:_assign_enemy_groups_to_recon()
	if not task_data then
		return
	end
	local t = self._t
	self:_assign_assault_groups_to_retire()
	local target_pos = task_data.target_area.pos
	local nr_wanted = self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.recon.force) - self:_count_police_force("recon")
	if nr_wanted <= 0 then
		return
	end
	local used_event, used_spawn_points, reassigned
	if task_data.use_spawn_event then
		task_data.use_spawn_event = false
		if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
			used_event = true
		end
	end

	local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, tweak_data.group_ai.besiege.recon.groups, nil, nil, callback(self, self, "_verify_anticipation_spawn_point"))
	if spawn_group then
		local grp_objective = {
			type = "recon_area",
			area = spawn_group.area,
			target_area = task_data.target_area,
			attitude = "engage",
			stance = "hos",
			moving_in = true,
			charge = true,
			open_fire = true,
		}
		self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)
	end

	if used_event or used_spawn_points or reassigned then
		table.remove(self._task_data.recon.tasks, 1)
		self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.recon.interval)) + math.random() * tweak_data.group_ai.besiege.recon.interval_variation
	end
end

function GroupAIStateBesiege:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks
	while i > 0 do
		local task_data = reenforce_tasks[i]
		local force_settings = task_data.target_area.factors.force
		local force_required = force_settings and force_settings.force
		if force_required then
			local force_occupied = 0
			for group_id, group in pairs(self._groups) do
				if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					force_occupied = force_occupied + (group.has_spawned and group.size or group.initial_size)
				end
			end
			local undershot = force_required - force_occupied
			if undershot > 0 and not self._task_data.regroup.active and self._task_data.assault.phase ~= "fade" and t > self._task_data.reenforce.next_dispatch_t and self:is_area_safe(task_data.target_area) then
				local used_event
				if task_data.use_spawn_event then
					task_data.use_spawn_event = false
					if self:_try_use_task_spawn_event(t, task_data.target_area, "reenforce") then
						used_event = true
					end
				end
				local used_group, spawning_groups

				local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, tweak_data.group_ai.besiege.reenforce.groups, nil, nil, nil)
				if spawn_group then
					local grp_objective = {
						type = "reenforce_area",
						area = spawn_group.area,
						target_area = task_data.target_area,
						attitude = "engage",
						stance = "hos",
						pose = "stand",
						moving_in = true,
						charge = true,
						open_fire = true,
					}
					self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)
					used_group = true
				end

			elseif undershot < 0 then
				local force_defending = 0
				for group_id, group in pairs(self._groups) do
					if group.objective.area == task_data.target_area and group.objective.type == "reenforce_area" then
						force_defending = force_defending + (group.has_spawned and group.size or group.initial_size)
					end
				end
				local overshot = force_defending - force_required
				if overshot > 0 then
					local closest_group, closest_group_size
					for group_id, group in pairs(self._groups) do
						if group.has_spawned then
							if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" and (not closest_group_size or closest_group_size < group.size) and overshot >= group.size then
								closest_group = group
								closest_group_size = group.size
							end
						end
					end
					if closest_group then
						self:_assign_group_to_retire(closest_group)
					end
				end
			end
		else
			for group_id, group in pairs(self._groups) do
				if group.has_spawned then
					if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
						self:_assign_group_to_retire(group)
					end
				end
			end
			reenforce_tasks[i] = reenforce_tasks[#reenforce_tasks]
			table.remove(reenforce_tasks)
		end
		i = i - 1
	end
	self:_assign_enemy_groups_to_reenforce()
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault
	if not task_data.active then
		return
	end
	local t = self._t
	self:_assign_recon_groups_to_retire()
	local force_pool = self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * self:_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)
	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + tweak_data.group_ai.besiege.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault()
			self:_set_rescue_state(false)
			task_data.phase = "build"
			task_data.phase_end_t = self._t + tweak_data.group_ai.besiege.assault.build_duration
			task_data.is_hesitating = nil
			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)
			if task_data.is_hesitating and self._t > task_data.voice_delay then
				if 0 < self._hostage_headcount then
					local best_group
					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end
					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + tweak_data.group_ai.besiege.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			task_data.phase = "sustain"
			task_data.phase_end_t = t + math.lerp(self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), self:_get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul)
		end
	elseif task_data.phase == "sustain" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + tweak_data.group_ai.besiege.assault.fade_duration
		elseif t > task_data.phase_end_t and not self._hunt_mode then
			task_data.phase = "fade"
			task_data.phase_end_t = t + tweak_data.group_ai.besiege.assault.fade_duration
		end
	else
		local enemies_left = self:_count_police_force("assault")
		if enemies_left < 7 or t > task_data.phase_end_t + 350 then
			if t > task_data.phase_end_t - 8 and not task_data.said_retreat then
				if self._drama_data.amount < tweak_data.drama.assault_fade_end then
					task_data.said_retreat = true
					self:_police_announce_retreat()
				end
			elseif t > task_data.phase_end_t and self._drama_data.amount < tweak_data.drama.assault_fade_end and self:_count_criminals_engaged_force(4) <= 3 then
				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end
				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()
				return
			end
		else
		end
	end
	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)
			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end
	local primary_target_area = task_data.target_areas[1]
	if self:is_area_safe(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)
				if not nearest_dis or nearest_dis > dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end
		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end
	local nr_wanted = task_data.force - self:_count_police_force("assault")
	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end
	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event
		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false
			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end

		local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, tweak_data.group_ai.besiege.assault.groups, nil, nil, nil)
		if spawn_group then
			local grp_objective = {
				type = "assault_area",
				area = spawn_group.area,
				coarse_path = {
					{
						spawn_group.area.pos_nav_seg,
						spawn_group.area.pos
					}
				},
				attitude = "engage",
				pose = "crouch",
				stance = "hos",
				moving_in = true,
				charge = true,
				open_fire = true,
			}
			self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
		end

	end
	if task_data.phase ~= "anticipation" then
		if t > task_data.use_smoke_timer then
			task_data.use_smoke = true
		end
		if self._smoke_grenade_queued and task_data.use_smoke and not self:is_smoke_grenade_active() then
			self:detonate_smoke_grenade(self._smoke_grenade_queued[1], self._smoke_grenade_queued[1], self._smoke_grenade_queued[2], self._smoke_grenade_queued[4])
			if self._smoke_grenade_queued[3] then
				self._smoke_grenade_ignore_control = true
			end
		end
	end
	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)

	local spawn_group_desc = tweak_data.group_ai.enemy_spawn_groups[spawn_group_type]
	local wanted_nr_units
	if type(spawn_group_desc.amount) == "number" then
		wanted_nr_units = spawn_group_desc.amount
	else
		wanted_nr_units = math.random(spawn_group_desc.amount[1], spawn_group_desc.amount[2])
	end
	local valid_unit_types = {}
	self._extract_group_desc_structure(spawn_group_desc.spawn, valid_unit_types)
	local function _get_special_unit_type_count(special_type)
		if not self._special_units[special_type] then
			return 0
		end
		return table.size(self._special_units[special_type])
	end

	local unit_categories = tweak_data.group_ai.unit_categories
	local total_wgt = 0
	local i = 1
	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		local cat_data = unit_categories[spawn_entry.unit]
		if not cat_data then
			debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)
			return
		elseif cat_data.special_type and tweak_data.group_ai.special_unit_spawn_limits[cat_data.special_type] then
			if _get_special_unit_type_count(cat_data.special_type) + (spawn_entry.amount_min or 0) > tweak_data.group_ai.special_unit_spawn_limits[cat_data.special_type] then
				spawn_group.delay_t = 0
				return
			end
		else
			total_wgt = total_wgt + spawn_entry.freq
			i = i + 1
		end
	end
	local spawn_task = {
		objective = not grp_objective.element and self._create_objective_from_group_objective(grp_objective),
		units_remaining = {},
		spawn_group = spawn_group,
		spawn_group_type = spawn_group_type,
		ai_task = ai_task
	}
	Print("Adding group to spawning queue: ", spawn_group_type)
	table.insert(self._spawning_groups, spawn_task)
	local function _add_unit_type_to_spawn_task(i, spawn_entry)
		local spawn_amount_mine = 1 + (spawn_task.units_remaining[spawn_entry.unit] and spawn_task.units_remaining[spawn_entry.unit].amount or 0)
		spawn_task.units_remaining[spawn_entry.unit] = {amount = spawn_amount_mine, spawn_entry = spawn_entry}
		wanted_nr_units = wanted_nr_units - 1
		if spawn_entry.amount_min then
			spawn_entry.amount_min = spawn_entry.amount_min - 1
		end
		if spawn_entry.amount_max then
			spawn_entry.amount_max = spawn_entry.amount_max - 1
			if spawn_entry.amount_max == 0 then
				table.remove(valid_unit_types, i)
				total_wgt = total_wgt - spawn_entry.freq
				return true
			end
		end
	end

	local i = 1
	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		if i <= #valid_unit_types and wanted_nr_units > 0 and spawn_entry.amount_min and 0 < spawn_entry.amount_min and (not spawn_entry.amount_max or 0 < spawn_entry.amount_max) then
			if not _add_unit_type_to_spawn_task(i, spawn_entry) then
				i = i + 1
			end
		else
			i = i + 1
		end
	end
	while wanted_nr_units > 0 and #valid_unit_types ~= 0 do
		local rand_wght = math.random() * total_wgt
		local rand_i = 1
		local rand_entry
		while true do
			rand_entry = valid_unit_types[rand_i]
			rand_wght = rand_wght - rand_entry.freq
			if rand_wght <= 0 then
				break
			else
				rand_i = rand_i + 1
			end
		end
		local cat_data = unit_categories[rand_entry.unit]
		if cat_data.special_type and tweak_data.group_ai.special_unit_spawn_limits[cat_data.special_type] and _get_special_unit_type_count(cat_data.special_type) >= tweak_data.group_ai.special_unit_spawn_limits[cat_data.special_type] then
			table.remove(valid_unit_types, rand_i)
			total_wgt = total_wgt - rand_entry.freq
		else
			_add_unit_type_to_spawn_task(rand_i, rand_entry)
		end
	end
	local group_desc = {type = spawn_group_type, size = 0}
	for u_name, spawn_info in pairs(spawn_task.units_remaining) do
		group_desc.size = group_desc.size + spawn_info.amount
	end
	local group = self:_create_group(group_desc)
	group.objective = grp_objective
	group.objective.moving_out = true
	group.team = self._teams[spawn_group.team_id or tweak_data.levels:get_default_team_ID("combatant")]
	spawn_task.group = group
	return group
end
]]
