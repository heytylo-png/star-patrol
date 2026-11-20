extends Node2D
## The test scene's root script.
## - Taps on an enemy make it the player's target (Inotia-style).
## - Keys 1 and 2 use the player's skills on a computer.
## - Creates the movement and skill input actions if you haven't set them up yet.

@export var player: Player          ## Drag your Player node here in the Inspector.
@export var tap_radius: float = 32.0  ## How close a tap must be to an enemy to select it.


func _ready() -> void:
	_ensure_input_actions()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_1"):
		player.use_skill(0)
	elif event.is_action_pressed("skill_2"):
		player.use_skill(1)
	# Joystick touches are already marked handled, so they never reach here.
	if event is InputEventScreenTouch and event.pressed:
		var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		var enemy: Enemy = _find_enemy_near(world_pos)
		if enemy:
			player.set_target(enemy)


func _find_enemy_near(pos: Vector2) -> Enemy:
	var best: Enemy = null
	var best_distance: float = tap_radius
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		var distance: float = pos.distance_to(enemy.global_position)
		if distance <= best_distance:
			best_distance = distance
			best = enemy
	return best


func _ensure_input_actions() -> void:
	# Adds movement (WASD + arrow keys) and skill keys (1, 2), unless they already exist.
	var keys := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"skill_1": [KEY_1],
		"skill_2": [KEY_2],
	}
	for action in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for code in keys[action]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = code
			InputMap.action_add_event(action, key_event)
