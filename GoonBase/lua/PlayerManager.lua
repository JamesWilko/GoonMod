
CloneClass( PlayerManager )

local IRONMAN_INSTA_DEATH = 1
local IRONMAN_ONE_DOWN = 2

Hooks:RegisterHook( "PlayerManagerOnSetup" )
function PlayerManager._setup(this)
	this.orig._setup(this)
	Hooks:Call("PlayerManagerOnSetup", this)
end

function PlayerManager:_add_equipment(params)

	local equipment = params.equipment
	local tweak_data = tweak_data.equipments[equipment]
	local amount = params.amount or (tweak_data.quantity or 0) + self:equiptment_upgrade_value(equipment, "quantity")
	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

	table.insert(self._equipment.selections, {
		equipment = equipment,
		amount = Application:digest_value(0, true),
		use_function = use_function,
		action_timer = tweak_data.action_timer
	})

	self._equipment.selected_index = self._equipment.selected_index or 1
	self:update_deployable_equipment_amount_to_peers(equipment, amount)
	managers.hud:add_item({amount = amount, icon = icon})
	self:add_equipment_amount(equipment, amount)

end

Hooks:Add("PlayerManagerOnSetup", "PlayerManagerOnSetup_PlayerManagerIronman", function(this)

	-- Ironman mode revives
	if GoonHUD.Ironman:IsEnabled() then
		for k, v in pairs(this:players()) do
			v.character_damage()._revives = Application:digest_value(IRONMAN_ONE_DOWN, true)
		end
	end

end)

Hooks:Add("PlayerDamageOnRegenerated", "PlayerDamageOnRegenerated_PlayerManagerIronman", function(playerDamage, no_messiah)
	playerDamage._revives = Application:digest_value(IRONMAN_ONE_DOWN, true)
end)
