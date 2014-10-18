----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

core:import("CoreMenuInput")

CloneClass( CoreMenuInput.MenuInput )
local MenuInput = CoreMenuInput.MenuInput

function MenuInput.input_slider(self, item, controller)

	local slider_delay_down = 0.1
	local slider_delay_pressed = 0.2

	if self:menu_right_input_bool() then
		
		item:increase()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)
		if self:menu_right_pressed() then
			local percentage = item:percentage()
			if percentage > 0 and percentage < 100 then
				self:post_event("slider_increase")
			end
			self:set_axis_x_timer(slider_delay_pressed)
		end

	elseif self:menu_left_input_bool() then

		item:decrease()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)
		if self:menu_left_pressed() then
			self:set_axis_x_timer(slider_delay_pressed)
			local percentage = item:percentage()
			if percentage > 0 and percentage < 100 then
				self:post_event("slider_decrease")
			end
		end

	end

end

-- END OF FILE
