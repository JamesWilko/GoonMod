
CloneClass( CivilianDamage )

local HOSTAGE_TRADE_TIMER = 180
local HOSTAGE_KILLED_TIMER = 180
local HOSTAGE_KILLED_FORGIVE_AMT = 2
local SCAM_CHANCE = 10
local SCAM_CHANCE_KILL_INC = 10
local SCAM_CHANCE_CAP = 40

function CivilianDamage.damage_melee(this, attack_data)

	local is_tied = this._unit:brain()._logic_data.is_tied

	-- Only run on tied up civilians
	if is_tied == nil then
		return this.orig.damage_melee(this, attack_data)
	end

	-- Don't allow multi trading on this civilian
	if this._unit:brain()._logic_data.has_been_traded ~= nil then
		return this.orig.damage_melee(this, attack_data)
	end
	this._unit:brain()._logic_data.has_been_traded = true

	-- Check if cops are angry we killed hostages
	local cops_angry = false
	if TradeManager._last_hostage_killed_time ~= nil then
		if TimerManager:game():time() - TradeManager._last_hostage_killed_time < HOSTAGE_KILLED_TIMER then
			cops_angry = true
		end
		if TradeManager._hostages_traded_streak ~= nil then
			if TradeManager._hostages_traded_streak > HOSTAGE_KILLED_FORGIVE_AMT then
				cops_angry = false
				TradeManager._last_hostage_killed_time = 0
			end
		end
	end

	Print("last: " .. tostring(TradeManager._last_hostage_killed_time) .. " / " .. tostring(TimerManager:game():time()))

	-- Normal trading if cops aren't angry, rapid-fire is cops are angry
	if not cops_angry then

		-- Check if we're trying to trade hostages too often
		if TradeManager._last_hostage_trade_time ~= nil then
			if TimerManager:game():time() - TradeManager._last_hostage_trade_time < HOSTAGE_TRADE_TIMER then
				managers.hint:_show_hint(nil, nil, nil, managers.localization:text("Hostage_TradeTime"))
				return
			end
		end
		TradeManager._last_hostage_trade_time = TimerManager:game():time()

		-- Random chance to get scammed by police
		if math.random(0, 100) < SCAM_CHANCE then
			managers.hint:_show_hint(nil, nil, nil, managers.localization:text("Hostage_TradeScammed"))
			return
		end

	end

	-- Give equipment if cops aren't angry
	if not cops_angry then

		local rand = math.random(0, 6)
		local equip, equip_friendly = nil, ""
		local num = 1
		while equip == nil do

			rand = math.random(0, 6)

			if rand == 1 then
				equip = "ammo_bag"
				equip_friendly = "an Ammo Bag"
				num = 1
			end
			if rand == 2 then
				equip = "ecm_jammer"
				equip_friendly = "an ECM Jammer"
				num = 1
			end
			if rand == 3 then
				equip = "trip_mine"
				equip_friendly = "some Trip Mines"
				num = 3
			end
			if rand == 4 then
				equip = "doctor_bag"
				equip_friendly = "a Doctor's Bag"
				num = 1
			end
			if rand == 5 then
				equip = "sentry_gun"
				equip_friendly = "a Sentry Gun"
				num = 1
			end

		end

		local t = managers.localization:text("Hostage_TradeForEquipment")
		t = string.gsub(t, "{0}", equip_friendly)
		managers.hint:_show_hint(nil, nil, nil, t)
		managers.player:add_equipment_amount(equip, num)

	end

	-- Begin trade logic
	local s, err = pcall(function()
		this._unit:brain():set_logic("trade")
		this._unit:brain():on_trade(nil)
	end)
	if not s then
		Print(err)
	end

	-- Increase success trade streak
	if TradeManager._hostages_traded_streak == nil then
		TradeManager._hostages_traded_streak = 0
	end
	TradeManager._hostages_traded_streak = TradeManager._hostages_traded_streak + 1

	-- Check cop responses
	if cops_angry then

		local streak = TradeManager._hostages_traded_streak
		if streak == 1 then
			managers.hint:_show_hint(nil, nil, nil, managers.localization:text("Hostage_TradeAngry"))
		end
		if streak == 2 then
			managers.hint:_show_hint(nil, nil, nil, managers.localization:text("Hostage_TradeLessAngry"))
		end
		if streak >= 3 then
			managers.hint:_show_hint(nil, nil, nil, managers.localization:text("Hostage_TradeAllowed"))
		end

	end

	-- Equipments
	-- ammo_bag
	-- ecm_jammer
	-- trip_mine
	-- doctor_bag
	-- sentry_gun

end

function CivilianDamage:_on_damage_received(damage_info)

	self:_call_listeners(damage_info)
	if damage_info.result.type == "death" then

		-- Killed a hostage, start penalty timer, reset trade streak
		TradeManager._last_hostage_killed_time = TimerManager:game():time()
		TradeManager._hostages_traded_streak = 0
		SCAM_CHANCE = SCAM_CHANCE + SCAM_CHANCE_KILL_INC
		if SCAM_CHANCE > SCAM_CHANCE_CAP then
			SCAM_CHANCE = SCAM_CHANCE_CAP
		end

		self:_unregister_from_enemy_manager(damage_info)
		if Network:is_client() then
			self._unit:interaction():set_active(false, false)
		end
	end

end
