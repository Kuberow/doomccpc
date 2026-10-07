# DOOMCCPC

A native Lua port of the original DOOM engine for CraftOS-PC graphics mode.

- Target: CraftOS-PC
- Language: Lua
- Audio: disabled
- Game data: user-provided `DOOM1.WAD`
- Engine source: based on the GPL-licensed id Software DOOM source

This repository is under active development.


## Current engine components
- Native CraftOS-PC 256-color framebuffer
- WAD and classic map lump parsing
- BSP traversal
- PLAYPAL/PNAMES/TEXTURE1/TEXTURE2 decoding
- Wall texture composition from WAD patches
- Billboard sprite patches
- 35 Hz simulation loop
- Player movement and basic line collision
- Map-object spawning, pickups, monster pursuit, melee damage, and hitscan shooting
- Native HUD/crosshair

The project intentionally does not contain DOOM WAD data.
