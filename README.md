# GoonMod for Payday [BETA]
----
## What is GoonMod?
GoonMod is a Lua modification for Payday 2 that adds new gameplay features. Most of GoonMod is able to be selectively enabled, so you can play with all of the individual mods that GoonMod comes with or only a single one.

## Beta?
This is not a complete modification yet. There will be bugs, there might be crashes. None of this should affect your Payday 2 save, as everything in GoonMod is designed to be saved externally so that it doesn't interfere with, or leave garbage data in your Payday 2 file if you uninstall it. **However, you should [backup your Payday 2 save file](http://steamcommunity.com/sharedfiles/filedetails/?id=170416480) if you are worried about using this mod.**

## How do I install GoonMod?
Download a ready-to-go version of GoonMod from the [releases page](https://github.com/JamesWilko/GoonMod/releases), or by downloading the [master archive](https://github.com/JamesWilko/GoonMod/archive/master.zip).
You will then want to extract all of the files in the zip archive to your Payday 2 Steam installation folder. So that the files and folders from the archive are in the same folder as your payday2_win32_release.exe executable.

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

### What Open-Source License does this use?
The MIT License, see the LICENSE.md.

### Is this compatible with HoxHud/PocoHud?
Not explicitly, although it may work with them. Any other Lua mods for Payday 2 can cause problems with each other. However if your mods all use the PD2Hook.yml file, you will need to add all the mods to this, and maintain this file yourself.
