class_name SpawnButton
extends Control
## Test tool: spawns an enemy near the player that comes straight for them.
## Tap it, or press E on a computer. Put it in the UI CanvasLayer, about 90 x 90.

const TRIES := 16   # Random spots to try before giving up.

@export var player: Player                         ## The Player node.
@export var enemy_scene: PackedScene               ## What to spawn (enemy.tscn).
@export var min_distance: float = 110.0            ## Closest spawn spot to the player.
@export var max_distance: float = 170.0            ## Farthest spawn spot.
@export var max_alive: int = 20                    ## Stops spawning past this many enemies.
@export var come_at_once: bool = true              ## Spawned enemies chase right away.
@export var radius: float = 40.0
@export var color: Color = Color(0.55, 0.25, 0.6, 0.75)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and _is_inside(event.position):
		get_viewport().set_input_as_handled()
		spawn()
	elif event.is_action_pressed("spawn_enemy"):
		spawn()


## Spawns one enemy in a free spot around the player. Returns it, or null if none fit.
func spawn() -> Enemy:
	if player == null or enemy_scene == null or player.is_dead:
		return null
	if get_tree().get_nodes_in_group("enemies").size() >= max_alive:
		return null
	var spot: Variant = _free_spot()
	if spot == null:
		return null
	var enemy := enemy_scene.instantiate() as Enemy
	if enemy == null:
		return null
	enemy.global_position = spot
	player.get_parent().add_child(enemy)
	if come_at_once:
		enemy.taunt()
	return enemy


# A random spot around the player that isn't inside a wall or another body, and that the
# player can see (so it's on the same side of the walls, not outside the room).
func _free_spot() -> Variant:
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	query.shape = circle
	for i in TRIES:
		var offset := Vector2.from_angle(randf() * TAU) * randf_range(min_distance, max_distance)
		var spot: Vector2 = player.global_position + offset
		query.transform = Transform2D(0.0, spot)
		if not space.intersect_shape(query, 1).is_empty():
			continue
		var ray := PhysicsRayQueryParameters2D.create(player.global_position, spot)
		ray.exclude = [player.get_rid()]
		if space.intersect_ray(ray).is_empty():
			return spot
	return null


func _is_inside(screen_pos: Vector2) -> bool:
	return screen_pos.distance_to(get_global_rect().get_center()) <= radius


func _draw() -> void:
	var middle: Vector2 = size / 2.0
	draw_circle(middle, radius, color)
	var font := ThemeDB.fallback_font
	var text := "Spawn"
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(font, middle + Vector2(-text_size.x / 2.0, 6.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
