GoonHUD
=======
Lua mod for Payday 2

Installation
=======
Put all files into your Payday 2 installation folder. (Next to payday2_win32_release.exe)

Customization
=======
The keybindings for the custom waypoints can be changed by modifying the lines under KeyBindings in PD2Hook.yml.
F1 and F2 are the default keys for placing and removing your waypoint.
If you want to change the keybindings look at the Windows Virtual-Key codes. (http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731)

The corpse limit has been massively increased, from 8 to 256. This can be changed in the GoonHUD/options.lua file.
Set the line Options.EnemyManager.MaxCorpses to your prefered amount.
You can see the current limit and toggle between the default and your custom amount ingame using the GoonHUD Options menu on the main menu. (Not available on the multiplayer menu yet.)
