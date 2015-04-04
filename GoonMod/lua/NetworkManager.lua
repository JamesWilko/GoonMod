
CloneClass( NetworkManager )

function NetworkManager:session()
	return self._started and self._session or nil
end

function NetworkManager:game()
	return self._started and self._game or nil
end

function NetworkManager.stop_network( self, clean )
	if self._started then
		self._game:on_network_stopped()
		self._started = false
		if clean and self._session then
			local peers = self._session:peers()
			for k, peer in pairs(peers) do
				local rpc = peer:rpc()
				if rpc then
					Network:reset_connection(rpc)
					Network:remove_client(rpc)
				end
			end
		end
		self._handlers = nil
		self._shared_handler_data = nil
		self._session:destroy()

		-- TODO: Find the part in PlayerManager that is attempting to use the session after it's already been destroyed
		-- until then, don't set it to nil and hope that changing levels cleans it up properly
		-- FATAL ERROR: [string "lib/managers/playermanager.lua"]:1818: attempt to index a nil value
		-- self._session = nil

		self._game = nil
		self._stop_network = nil
		self._stop_next_frame = nil
		self._network_bound = nil
		Network:unbind()
		Network:set_disconnected()
		if not Application:editor() then
			Network:set_multiplayer(false)
		end
		cat_print("multiplayer_base", "[NetworkManager:stop_network]")
		print("---------------------------------------------------------")
	end
end
