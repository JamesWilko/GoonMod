
CloneClass( HintManager )

local blockedHints = {
	"trade_offered"
}

function HintManager._show_hint(this, id, time, params, customText, data)

	if customText ~= nil then
		managers.hud:show_hint({
			text = customText,
			time = time
		})
		return
	end

	for k, v in pairs(blockedHints) do
		if v == id then
			return
		end
	end

	this.orig._show_hint(this, id, time, params)

end
