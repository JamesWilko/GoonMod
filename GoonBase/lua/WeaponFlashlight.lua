----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( WeaponFlashLight )

Hooks:RegisterHook("WeaponFlashLightInit")
function WeaponFlashLight.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call( "WeaponFlashLightInit", self, unit )
end

Hooks:RegisterHook("WeaponFlashLightCheckState")
function WeaponFlashLight._check_state(self)
	self.orig._check_state(self)
	Hooks:Call( "WeaponFlashLightCheckState", self )
end

-- TODO: This is a messy hack-fix. Fix this up proper sometime.
function WeaponFlashLight:overkill_update(unit, t, dt)

	t = Application:time()
	self._light_speed = self._light_speed or 1
	self._light_speed = math.step(self._light_speed, 1, dt * (math.random(4) + 2))
	-- self._light:set_rotation(self._light:rotation() * Rotation(dt * -50 * self._light_speed, 0))
	self:update_flicker(t, dt)
	self:update_laughter(t, dt)
	if not self._kittens_timer then
		self._kittens_timer = t + 25
	end
	if t > self._kittens_timer then
		if math.rand(1) < 0.75 then
			self:run_net_event(self.HALLOWEEN_FLICKER)
			self._kittens_timer = t + math.random(10) + 5
		elseif math.rand(1) < 0.35 then
			self:run_net_event(self.HALLOWEEN_WARP)
			self._kittens_timer = t + math.random(12) + 3
		elseif math.rand(1) < 0.25 then
			self:run_net_event(self.HALLOWEEN_LAUGHTER)
			self._kittens_timer = t + math.random(5) + 8
		elseif math.rand(1) < 0.15 then
			self:run_net_event(self.HALLOWEEN_SPOOC)
			self._kittens_timer = t + math.random(2) + 3
		else
			self._kittens_timer = t + math.random(5) + 3
		end
	end

end
-- END OF FILE
