----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

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

-- END OF FILE
