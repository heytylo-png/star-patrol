# Star Patrol

A pixel-art action RPG for mobile with planned 1–4 player co-op, set in a world where sci-fi and dark fantasy blend. Players start as a blank recruit in the Star Patrol, a guild of fortune hunters, pick one of 6 classes and raid the ruins of a fallen star empire for loot.

Built with **Godot 4** (GDScript).

![The prototype running: joystick, player (blue) and three enemies (red) with HP bars](docs/screenshot.png)

## Status: prototype, step 3 next

Working so far (placeholder shapes, no art yet):

- On-screen joystick movement (WASD / arrow keys also work on a computer)
- Tap or click an enemy to target it (red ring)
- Auto-attack when the target is in range; enemies flash, lose HP and disappear

## Running it

1. Install [Godot 4.7 or newer](https://godotengine.org/download) (the standard version, not .NET).
2. Clone or download this repository.
3. In Godot's Project Manager, click **Import** and choose this folder's `project.godot`.
4. Press **F5** to play. Drag the joystick in the bottom-left with the mouse, and click an enemy to target it, then walk up to it to auto-attack.

### With the Godot editor on Android

1. Install **Godot Editor** from the Play Store.
2. On GitHub, tap **Code > Download ZIP**.
3. In Godot's Project Manager, tap **Import**, go up to `/storage/emulated/0`, open **Download** and pick the ZIP. Choose a folder to extract it to.
   If the Download folder looks empty, allow Godot to manage all files in **Android Settings > Apps > Godot Editor > Permissions**.
4. Open the project and tap **▶** (top right).

### Testing on an Android phone

1. In Godot, open **Editor > Manage Export Templates** and download the templates for your version.
2. Install Java (JDK 17) and the Android SDK, then set their paths in **Editor > Editor Settings > Export > Android**.
3. Add an Android preset in **Project > Export**. (`export_presets.cfg` is git-ignored, so each computer sets this up once.)
4. Turn on USB debugging on the phone and plug it in. Godot's **Remote Deploy** button (top right) then installs and runs the game on it.

## Project layout

```
project.godot          Project settings (mobile renderer, touch emulation, pixel-art filtering)
scenes/main.tscn       Test scene: player, 3 enemies, joystick
scripts/player.gd      Movement and auto-attack
scripts/enemy.gd       HP, damage flash, HP bar and target ring
scripts/virtual_joystick.gd  Multitouch on-screen joystick
scripts/main.gd        Tap-to-target and default movement keys
docs/SETUP.md          How the scene is built, D-pad setup and tunable numbers
```

## Prototype roadmap

1. ~~Learn the basics~~
2. ~~Movement and combat (joystick, tap-to-target, auto-attack)~~
3. **Warrior skills and the Flame Warden's Heat gauge** (next)
4. One Hollow Throne dungeon room
5. Layered sprites (base body plus one swappable armor piece)
6. 2-player online co-op

## Glossary

- **Flame Warden**: a Warrior specialization built around heat and fire.
- **Heat gauge**: the Flame Warden's class resource, which builds up in combat and powers their skills.
- **Hollow Throne**: a ruined dungeon from the fallen star empire, used for the first test room.

## License

Copyright © 2026 heytylo-png. All rights reserved.

The source is public so you can read it and follow development, but you may not copy, modify, redistribute or publish it, or its art, story or names, without written permission.
