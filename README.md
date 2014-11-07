# GoonMod for Payday [BETA]
----
## What is GoonMod?
GoonMod is a Lua modification for Payday 2 that adds new gameplay features. Most of GoonMod is able to be selectively enabled, so you can play with all of the individual mods that GoonMod comes with or only a single one.

## Beta?
This is not a complete modification yet. There will be bugs, there might be crashes. None of this should affect your Payday 2 save, as everything in GoonMod is designed to be saved externally so that it doesn't interfere with, or leave garbage data in your Payday 2 file if you uninstall it. **However, you should [backup your Payday 2 save file](http://steamcommunity.com/sharedfiles/filedetails/?id=170416480) if you are worried about using this mod.**

## Mod List
These are the mods which are currently packaged with GoonMod:  
**Corpse Delimiter:** Raise the number of corpses allowed to astronomical levels. Also include options to despawn shields after they are killed.  
**Crime.net Cargo:** Send and receive weapons, weapon mods, masks, and mask parts between your friends and other players.  
**Mutators:** Micro-gameplay mods that add new give you new gameplay modes and experiences.  
**Extended Inventory:** Allows mods to add new items to your inventory.  
**Gage Coins:** Gage will give you a coin for every courier package you complete. (Requires Extended Inventory)  
**Gage Mod Shop:** Gage is opening up to new business opportunities. You can now buy weapon mods, masks, and mask parts using Gage Coins. (Requires Extended Inventory and Gage Coins)  
**Separate Train Heist:** Don't worry about accidentally grabbing the train intel again, picking up the intel will allow you to visit the Train Heist on your own time. (Requires Extended Inventory)   
**Custom Waypoints:** Set a marker for your buddies, and co-ordinate with them much easier and faster.  
**Grenade Indicator:** Tired of surprise flashbangs? Adds an indicator shortly before they detonate to give you a chance to react.  
**Custom Weapon Laser and Lights:** Customize the colour of your weapon laser and flashlight attachments, or have you own personal rave with a disco-laser.  
**Custom World Lasers:** Customize the lasers in game, like the ones in GO Bank or Framing Frame, to your own liking.  
**Normalized Ironsights:** Your sensitivity will drop the futher you zoom in with ironsights to allow you to aim better.  
**Remember Gadget State:** Gadgets on your weapons will remember if they were on or off when you put them away and pull them back out.  
**Push-to-Interact:** Push the button and wait. No more holding the key down.  

## How do I install GoonMod?
Download a ready-to-go version of GoonMod from the [releases page](https://github.com/JamesWilko/GoonMod/releases), or by downloading the [master archive](https://github.com/JamesWilko/GoonMod/archive/master.zip).
You will then want to extract all of the files in the zip archive to your Payday 2 Steam installation folder. So that the files and folders from the archive are in the same folder as your payday2_win32_release.exe executable.
If you use the master archive version, you can safely delete the files 'LICENSE.md', 'README.md', 'update_list.txt', and 'update_version.txt'.

![GoonBase Installation](http://payday.jameswilko.com/github/goonmod_installation.jpg "GoonBase Installation")

## I installed GoonMod, now what?
Once GoonMod has been installed, you need to enable the modifications which you want to play with. You can do this by going to your options menu in Payday 2 and selecting the GoonMod option. From here, select Modifications.

Once in the modifications menu, you can selectively enable and disable mods as you please. The help bar at the top of the Payday 2 window will give you a description of the mod as you select them.

![GoonBase Mods List](http://payday.jameswilko.com/github/goonmod_modsmenu.jpg "GoonBase Mods List")

Some mods may be greyed out, which indicates that the particular mod needs another mod to be enabled before it can be used, or it may be incompatible with a mod that is currently enabled. The help bar at the top of the game will tell you which mods need to be enabled or disabled before it can be used. This also applies to Mutators.

Once you have chosen which mods you wish to enable, restart your Payday 2 game so that all components of the mods can be loaded. If you go back into the GoonMod options menu, depending on your mod choices, you may have multiple new options which can be used to configure any additional options.

![GoonBase Options](http://payday.jameswilko.com/github/goonmod_menu.jpg "GoonBase Options")

## My game is crashing!
If you are having problems with your game crashing, first make sure you are running the latest version of GoonMod. Also make sure that you are not using any other Lua mods with your Payday 2. If you are using other mods such as HoxHud or PocoHud, try disabling them first before reporting any errors.

![GoonBase Log File](http://payday.jameswilko.com/github/goonmod_logfile.jpg "GoonBase Log File")

If you are sure your game is crashing, then send the GoonBase.log file from your Payday 2 folder to me via email (listed below). As well as what heist (and what day of the heist) you were playing, when and what you were doing when you crashed. Crash logs and detailed instructions will help me get an understanding of why the game is crashing, and will let me get it fixed ASAP for you.

## Contact Information
If you are experiencing crashes, want to ask a few questions, talk, send me a suggestion, tell me to stop modding your game, or anything else, you can find me at one of the contact methods below.

Email: [jw(at)jameswilko(dot)com](mailto:jw@jameswilko.com)  
Website: [http://jameswilko.com/](http://jameswilko.com/)  
Twitter: @_[JamesWilko](http://twitter.com/_JamesWilko) 

## FAQ
### Do I need to join a Steam Group to use or download this?
No.

### Is this compatible with PocoHud?
Probably! Go read this quick guide made by SA member Kikas: [http://payday.jameswilko.com/goonmod-pocohud](http://payday.jameswilko.com/goonmod-pocohud)

### Is this compatible with HoxHud?
Maybe! I'm trying to make sure everything works properly, but there are probably going to be bugs. Complain to me, complain to the HoxHud devs, complain to everybody!

### How do I make my PD2Hook file work with this and other mods?
If you are trying to use two or more mods which use the PD2Hook file you will have to manually edit this file to get them to work.
Simply copy and paste everything between, and including, the '# GOONBASE' and '# END' lines into the file underneath 'PostRequireScripts:'. This will allow you to run GoonMod with other lua mods such as PocoHud.  
GoonMod will automatically merge its own changes with your current file after the initial installation, so you will only have to set the file up once.  

### What Open-Source License does this use?
The MIT License, see the LICENSE.md.
