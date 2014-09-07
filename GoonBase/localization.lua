
_G.GoonBase.Localization = {}
local Localization = _G.GoonBase.Localization

Localization.GoonBaseOptionsName = "GoonBase"
Localization.GoonBaseOptionsDesc = "Change your GoonBase preferences"

Localization.OptionsMenu_CorpseToggle = "Use Custom Corpse Amount"
Localization.OptionsMenu_CorpseToggleDesc = "Use the custom amount of corpses instead of the default amount (8)"
Localization.OptionsMenu_CorpseAmount = "Corpse Amount"
Localization.OptionsMenu_CorpseAmountDesc = "Maximum number of corpses allowed (Current: " .. math.floor(GoonBase.Options.EnemyManager.CurrentMaxCorpses) .. ")"
Localization.OptionsMenu_GrenadeMarker = "Show Markers on Flashbangs"
Localization.OptionsMenu_GrenadeMarkerDesc = "Show a HUD marker when a flashbang is deployed"

Localization.Ironman_Toggle = "Ironman Mode"
Localization.Ironman_ToggleDesc = "Enable ironman mode on heists. If you are killed, you are killed for good."
Localization.Ironman_HeistExperience = "Ironman Bonus"
Localization.Ironman_NoTradeTitle = "Ironman Mode"
Localization.Ironman_NoTrade = "No Trading"
Localization.Ironman_NoRespawn = "No Respawning"

Localization.Hostage_Toggle = "Enabled Advanced Hostage Trading"
Localization.Hostage_ToggleDesc = "Allow trading hostages for equipment, money, and favors."
Localization.Hostage_TradeForEquipment = "The police are trading for {0}."
Localization.Hostage_TradeTime = "The police aren't willing to negotiate again yet."
Localization.Hostage_TradeAngry = "The police are slightly more willing to negotiate."
Localization.Hostage_TradeLessAngry = "The police are more willing to negotiate."
Localization.Hostage_TradeAllowed = "The police are willing to negotiate again."
