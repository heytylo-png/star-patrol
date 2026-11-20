# Star Patrol — Step 2: Movement and tap-to-target

Made for Godot 4.x.

**This repository already includes the finished scene (`scenes/main.tscn`) and these settings in `project.godot`.**
Just import the project and press F5. The steps below explain how it's put together, in case you want to rebuild it or understand it.

Note: the scene uses simple colored shapes (Polygon2D) instead of `icon.svg` sprites, and sets each CharacterBody2D's
Motion Mode to **Floating**, which is the right mode for top-down movement.

## 1. Project settings

- **Project > Project Settings > Input Devices > Pointing**: turn on **Emulate Touch From Mouse**.
  This lets you test touch controls on your computer with the mouse.
- **Display > Window**: set Stretch Mode to **canvas_items** (keeps pixel art crisp at any phone size).
  Turn on **Advanced Settings** to see this option.

## 2. Build the test scene

Create a new scene and add these nodes:

```
Main (Node2D)                 <- attach main.gd
├── Player (CharacterBody2D)  <- attach player.gd
│   ├── Sprite2D              (texture: icon.svg, scale 0.25, as a placeholder)
│   ├── CollisionShape2D      (shape: CircleShape2D, radius 12)
│   └── Camera2D              (follows the player)
├── Enemy (CharacterBody2D)   <- attach enemy.gd
│   ├── Sprite2D              (icon.svg, scale 0.25, modulate red)
│   └── CollisionShape2D      (CircleShape2D, radius 12)
└── UI (CanvasLayer)
    └── Joystick (Control)    <- attach virtual_joystick.gd
```

- Move the Enemy about 150 pixels away from the Player.
- Duplicate the Enemy (Ctrl+D) to make a few more.
- **Joystick:** set its size to 240 x 240 and drag it to the bottom-left corner.
  In the Layout menu, choose anchor **Bottom Left** so it stays there on every screen.

## 3. Connect the pieces (Inspector)

- Select **Main**: drag the Player node into the **Player** slot.
- Select **Player**: drag the Joystick node into the **Joystick** slot.

## 4. Play (F5)

- Move with the on-screen joystick (click and drag), or with WASD / arrow keys.
- Click an enemy to target it: a red ring appears.
- Walk close to it: the player auto-attacks, the enemy flashes and its HP bar drops until it disappears.

## Optional: D-pad

Movement already listens to the actions `move_left`, `move_right`, `move_up` and `move_down`.
For a D-pad, add four **TouchScreenButton** nodes under the UI CanvasLayer, give each an arrow
texture, and set each one's **Action** property to one of those four names. No extra code needed.

## Numbers to tweak (Inspector)

| Node | Setting | Default |
| --- | --- | --- |
| Player | Move Speed | 120 |
| Player | Attack Range | 40 |
| Player | Attack Damage | 10 |
| Player | Attack Cooldown | 0.8 s |
| Player | Max HP | 100 |
| Enemy | Max HP / Move Speed / Aggro Range | 50 / 60 / 150 px |
| Enemy | Attack Range / Damage / Cooldown | 30 px / 4 / 1.5 s |
| Boss (`boss.tscn`) | Max HP / Damage / Cooldown | 160 / 8 / 1.6 s |
| RoomDirector | Heal Between Waves | on |
| Joystick | Radius | 80 |
| Main | Tap Radius | 32 |
| Player (Flame Warden) | Max Heat | 100 |
| Player (Flame Warden) | Heat Per Auto Attack | 10 |
| Player (Flame Warden) | Heat Decay Per Second / Delay | 5 / 3 s |
| Player (Flame Warden) | Strike Damage / Heat Gain / Cooldown | 25 / 25 / 4 s |
| Player (Flame Warden) | Ring Damage / Heat Cost / Radius / Cooldown | 20 / 40 / 70 px / 6 s |
| StrikeButton, RingButton | Skill Index / Label / Radius | 0 or 1 / text / 50 |

## Step 3: Flame Warden skills

The Player node now uses `flame_warden.gd`, which extends `player.gd`. Future classes follow the same
pattern: extend `Player` and override `use_skill`, `can_use_skill` and `skill_cooldown_ratio`.
The UI layer has a **HeatBar** (top-left) and two **SkillButton** nodes (bottom-right); each has a
**Player** slot pointing at the Player node.

## Step 4: Hollow Throne room

`scenes/hollow_throne.tscn` is now the main scene (`main.tscn` is kept as a sandbox).

- **Walls**: each wall is a `StaticBody2D` with `wall.gd`. Set **Size** and **Color** in the Inspector and
  drag it into place; it draws itself in the editor.
- **Waves**: under the **Waves** node, each child (`Wave1`, `Wave2`, ...) holds that wave's enemies.
  Add an enemy by instancing `enemy.tscn` or `boss.tscn` into a wave. Waves run in order; the last one
  is announced as the boss.
- **RoomDirector**: links the Player, the Waves node, the **Door** (removed when every wave is cleared),
  the **Exit** area beyond it, and the **Message** label.

## Step 5: Layered sprites

The player's look is a **CharacterSprite** node (`Player/Sprite`) that stacks one image per layer, bottom
to top: Body, Legs, Chest, Helmet, Shoulders, Weapon, Effects (the order from the design doc).

**Art rules** (from the design doc): every layer is a 32×48 PNG on the same canvas, lined up at the feet
(the soles sit on row 45), with a dark outline and colors from `art/palette.png`.

- **Change the starting gear:** select `Player/Sprite` and edit **Starting Gear**.
- **Add a gear piece:** in FileSystem, right-click `gear/` > **New > Resource > ArmorPiece**. Set its
  name, slot, tier (1 = Cloth … 9 = Legendary) and texture. Add it to the ArmorButton's **Pieces** list to
  try it in game.
- **Replace the placeholder art:** overwrite the PNGs in `art/characters/` with your own (same size and
  alignment). No code changes needed. To regenerate the placeholders instead, run
  `python3 tools/make_placeholder_art.py` (needs Pillow).

