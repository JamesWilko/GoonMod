
CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerSetMouseSensitivity" )
function MenuManager.set_mouse_sensitivity(self, zoomed)
	self.orig.set_mouse_sensitivity(self, zoomed)
	Hooks:Call( "MenuManagerSetMouseSensitivity", self, zoomed )
end

-- Start game delaying
Hooks:RegisterHook("MenuCallbackHandlerPreStartTheGame")
function MenuCallbackHandler.start_the_game(self)

	if not self._start_the_game then
		self._start_the_game = function(self)
			self.orig.start_the_game(self)
		end
	end

	local r = Hooks:ReturnCall("MenuCallbackHandlerPreStartTheGame", self)
	if r then
		self._delayed_start_game = true
		return nil
	end

	return self.orig.start_the_game(self)

end

Hooks:RegisterHook("MenuCallbackHandlerPreIncreaseInfamous")
function MenuCallbackHandler._increase_infamous( self )
	Hooks:Call("MenuCallbackHandlerPreIncreaseInfamous", self)
	return self.orig._increase_infamous( self )
end

function MenuCallbackHandler:_process_start_game_delay( t, dt )

	if self._delayed_start_game and #self._start_delays == 0 then
		self._delayed_start_game = false
		if self._start_the_game then
			self:_start_the_game()
		end
	end

end

function MenuCallbackHandler:delay_game_start( id )

	self._delayed_start_game = true

	if not self._start_delays then
		self._start_delays = {}
	end
	table.insert( self._start_delays, id ) 

end

function MenuCallbackHandler:release_game_start_delay( id )

	for i = #self._start_delays, 0, -1 do
		if self._start_delays[i] == id then
			table.remove( self._start_delays, i )
		end
	end

end

Hooks:Add("MenuUpdate", "MenuUpdate_MenuManager", function(t, dt)
	MenuCallbackHandler._process_start_game_delay(MenuCallbackHandler, t, dt)
end)

-- Lobby permissions
Hooks:RegisterHook("MenuCallbackHandlerPreChoseLobbyPermission")
function MenuCallbackHandler.choice_lobby_permission(self, item)
	local r = Hooks:ReturnCall("MenuCallbackHandlerPreChoseLobbyPermission", self, item)
	if r then
		return
	end
	self.orig.choice_lobby_permission(self, item)
end

Hooks:RegisterHook("MenuCallbackHandlerPreCrimeNetChoseLobbyPermission")
function MenuCallbackHandler.choice_crimenet_lobby_permission(self, item)
	local r = Hooks:ReturnCall("MenuCallbackHandlerPreCrimeNetChoseLobbyPermission", self, item)
	if r then
		return
	end
	self.orig.choice_crimenet_lobby_permission(self, item)
end
