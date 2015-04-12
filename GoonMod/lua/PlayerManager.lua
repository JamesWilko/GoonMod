
CloneClass( PlayerManager )

function PlayerManager.verify_carry(self, peer_id, carry_id)
	if self._force_verify_carry and self._force_verify_carry > 0 then
		self._force_verify_carry = self._force_verify_carry - 1
		return true
	end
	return self.orig.verify_carry(self, peer_id, carry_id)
end

function PlayerManager:force_verify_carry()
	if not self._force_verify_carry then
		self._force_verify_carry = 0
	end
	self._force_verify_carry = self._force_verify_carry + 1
end

function PlayerManager.get_my_carry_data(self)
	if managers.network:session() then
		local peer_id = managers.network:session():local_peer():id()
		return self._global.synced_carry[peer_id]
	end
	return nil
end
