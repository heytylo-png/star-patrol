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
| Enemy | Max HP | 50 |
| Joystick | Radius | 80 |
| Main | Tap Radius | 32 |
