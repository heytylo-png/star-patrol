# Star Patrol

A co-op pixel-art action RPG for mobile, for 1–4 players, set in a world where sci-fi and dark fantasy blend. Players start as a blank recruit in the Star Patrol, a guild of fortune hunters, pick one of 6 classes and raid the ruins of a fallen star empire for loot.

Built with **Godot 4** (GDScript).

## Status: prototype, step 2

Working so far (placeholder shapes, no art yet):

- On-screen joystick movement (WASD / arrow keys also work on a computer)
- Tap or click an enemy to target it (red ring)
- Auto-attack when the target is in range; enemies flash, lose HP and disappear

## Running it

1. Install [Godot 4](https://godotengine.org/download) (the standard version, not .NET).
2. Clone or download this repository.
3. In Godot's Project Manager, click **Import** and choose this folder's `project.godot`.
4. Press **F5** to play. Drag the joystick in the bottom-left with the mouse, and click enemies to target them.

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
2. **Movement and combat** (joystick, tap-to-target, auto-attack), done
3. Warrior skills and the Flame Warden's Heat gauge
4. One Hollow Throne dungeon room
5. Layered sprites (base body plus one swappable armor piece)
6. 2-player online co-op
