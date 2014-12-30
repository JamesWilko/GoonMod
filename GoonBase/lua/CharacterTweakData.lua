----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CharacterTweakData )

Hooks:RegisterHook("CharacterTweakDataPostMultiplyAllSpeeds")
function CharacterTweakData._multiply_all_speeds(this, walk_mul, run_mul)
	this.orig._multiply_all_speeds(this, walk_mul, run_mul)
	Hooks:Call("CharacterTweakDataPostMultiplyAllSpeeds", this, walk_mul, run_mul)
end

Hooks:RegisterHook("CharacterTweakDataPostInitSecurity")
function CharacterTweakData._init_security(this, presets)
	this.orig._init_security(this, presets)
	Hooks:Call("CharacterTweakDataPostInitSecurity", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitGenSec")
function CharacterTweakData._init_gensec(this, presets)
	this.orig._init_gensec(this, presets)
	Hooks:Call("CharacterTweakDataPostInitGenSec", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitCop")
function CharacterTweakData._init_cop(this, presets)
	this.orig._init_cop(this, presets)
	Hooks:Call("CharacterTweakDataPostInitCop", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitFBI")
function CharacterTweakData._init_fbi(this, presets)
	this.orig._init_fbi(this, presets)
	Hooks:Call("CharacterTweakDataPostInitFBI", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitSWAT")
function CharacterTweakData._init_swat(this, presets)
	this.orig._init_swat(this, presets)
	Hooks:Call("CharacterTweakDataPostInitSWAT", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitHeavySWAT")
function CharacterTweakData._init_heavy_swat(this, presets)
	this.orig._init_heavy_swat(this, presets)
	Hooks:Call("CharacterTweakDataPostInitHeavySWAT", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitFBISWAT")
function CharacterTweakData._init_fbi_swat(this, presets)
	this.orig._init_fbi_swat(this, presets)
	Hooks:Call("CharacterTweakDataPostInitFBISWAT", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitFBIHeavySWAT")
function CharacterTweakData._init_fbi_heavy_swat(this, presets)
	this.orig._init_fbi_heavy_swat(this, presets)
	Hooks:Call("CharacterTweakDataPostInitFBIHeavySWAT", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitCitySWAT")
function CharacterTweakData._init_city_swat(this, presets)
	this.orig._init_city_swat(this, presets)
	Hooks:Call("CharacterTweakDataPostInitCitySWAT", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitSniper")
function CharacterTweakData._init_sniper(this, presets)
	this.orig._init_sniper(this, presets)
	Hooks:Call("CharacterTweakDataPostInitSniper", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitTank")
function CharacterTweakData._init_tank(this, presets)
	this.orig._init_tank(this, presets)
	Hooks:Call("CharacterTweakDataPostInitTank", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitCloaker")
function CharacterTweakData._init_spooc(this, presets)
	this.orig._init_spooc(this, presets)
	Hooks:Call("CharacterTweakDataPostInitCloaker", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitShield")
function CharacterTweakData._init_shield(this, presets)
	this.orig._init_shield(this, presets)
	Hooks:Call("CharacterTweakDataPostInitShield", this, presets)
end

Hooks:RegisterHook("CharacterTweakDataPostInitTaser")
function CharacterTweakData._init_taser(this, presets)
	this.orig._init_taser(this, presets)
	Hooks:Call("CharacterTweakDataPostInitTaser", this, presets)
end
-- END OF FILE
