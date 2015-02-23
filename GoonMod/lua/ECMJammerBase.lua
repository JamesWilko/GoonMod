
CloneClass( ECMJammerBase )

function ECMJammerBase:init(unit)

	UnitBase.init(self, unit, true)

	self._unit = unit
	self._position = self._unit:position()
	self._rotation = self._unit:rotation()
	self._g_glow_jammer_green = self._unit:get_object(Idstring("g_glow_func1_green"))
	self._g_glow_jammer_red = self._unit:get_object(Idstring("g_glow_func1_red"))
	self._g_glow_feedback_green = self._unit:get_object(Idstring("g_glow_func2_green"))
	self._g_glow_feedback_red = self._unit:get_object(Idstring("g_glow_func2_red"))
	self._max_battery_life = tweak_data.upgrades.ecm_jammer_base_battery_life
	self._battery_life = 0.01
	self._low_battery_life = tweak_data.upgrades.ecm_jammer_base_low_battery_life
	self._feedback_active = false
	self._jammer_active = false

	if Network:is_client() then
		self._validate_clbk_id = "ecm_jammer_validate" .. tostring(unit:key())
		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end

end

function ECMJammerBase:setup(battery_life_upgrade_lvl, owner)

	self._slotmask = managers.slot:get_mask("trip_mine_targets")
	self._max_battery_life = tweak_data.upgrades.ecm_jammer_base_battery_life * battery_life_upgrade_lvl
	self._battery_life = 0.01
	self._owner = owner
	self._owner_id = owner and managers.network:game():member_from_unit(owner):peer():id()

	self:spawn_workspace()

end

function ECMJammerBase:spawn_workspace()

	local w, h = 320, 320
	local scale = 1
	local scaled_w, scaled_h = w * scale, h * scale
	local pos, rot = self._position + Vector3((scaled_w / 2), -(scaled_h / 2), 1), self._rotation

	local new_gui = World:newgui()
	self._workspace = new_gui:create_world_workspace(w, h, pos, Vector3(-scaled_w, 0, 0):rotate_with(rot), Vector3(0, 0, -scaled_h):rotate_with(rot))

	self._circle_1 = CircleBitmapGuiObject:new(self._workspace:panel(), {
		use_bg = false,
		radius = self._workspace:panel():w() / 2,
		sides = 64,
		current = 64,
		total = 64,
		color = Color.white,
		alpha = 1,
		blend_mode = "add",
		image = "guis/textures/pd2/specialization/progress_ring",
		layer = 2
	})
	self._circle_1:set_current( 0.66 )
	self._circle_1_rotation = math.random(0, 360)
	self._circle_1._circle:set_rotation( self._circle_1_rotation )

end

function ECMJammerBase:set_battery_low()
end

function ECMJammerBase:set_feedback_active()

	if not managers.network:session() then
		return
	end

	if not ECMJammerBase._teleport_destination then
		ECMJammerBase._teleport_destination = self._position
	else
		self:teleport()
	end

end

function ECMJammerBase:teleport()

	local hit_pos = self._position
	local range = 400
	local slotmask = managers.slot:get_mask("explosion_targets")
	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)

	if not self._teleported_units then
		self._teleported_units = {}
	end

	for _, body in ipairs(bodies) do
		local character = body:unit()
		if character:carry_data() and body:collisions_enabled() then

			body:set_keyframed()
			-- body:set_collisions_enabled(false)
			character:set_position( ECMJammerBase._teleport_destination + Vector3(0, 0, 100) )

			table.insert( self._teleported_units, character )

		end
	end
	self._teleported_units_time = Application:time()

	ECMJammerBase._teleport_destination = nil

end

function ECMJammerBase:update(unit, t, dt)
	
	self.orig.update(self, unit, t, dt)

	self:update_teleported_units(unit, t, dt)
	self:update_rotations(unit, t, dt)

end

function ECMJammerBase:update_teleported_units(unit, t, dt)

	if self._teleported_units and Application:time() - self._teleported_units_time > 0.5 then

		local bounds = 1000000
		for k, v in pairs( self._teleported_units ) do
			v:set_dynamic()
			v:set_collisions_enabled(true)
			v:push(100, math.UP * 600)
		end
		self._teleported_units = nil

	end

end

function ECMJammerBase:update_rotations(unit, t, dt)

	if self._circle_1 then
		self._circle_1_rotation = self._circle_1_rotation + dt * 10
		self._circle_1._circle:set_rotation( self._circle_1_rotation )
	end

end
