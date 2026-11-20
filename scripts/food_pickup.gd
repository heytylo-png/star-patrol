class_name FoodPickup
extends Node2D
## A food item on the floor that heals the player when they walk over it.
## Not picked up at full HP (it waits for you). Blinks, then disappears after `lifetime`.
## Enemies drop these (see Enemy's "Drops" settings); you can also place one in a scene.

const SHEET: Texture2D = preload("res://art/items/food.png")
const ICON_SIZE := 16
const ICON_COUNT := 64      # food.png is an 8 x 8 grid.

@export var heal_amount: int = 15
@export_range(-1, 63) var icon: int = -1        ## Which food (0-63); -1 picks one at random.
@export var pickup_radius: float = 16.0          ## How close the player's feet must come.
@export var lifetime: float = 20.0               ## Seconds before it disappears (0 = never).
@export var blink_time: float = 3.0              ## Blinks during its last seconds.
@export var bob_height: float = 2.0              ## Gentle up-and-down float, in pixels.

var _age: float = 0.0
var _sprite: Sprite2D


func _ready() -> void:
	z_index = -1   # Above the floor, under characters.
	if icon < 0:
		icon = randi() % ICON_COUNT
	_sprite = Sprite2D.new()
	_sprite.texture = SHEET
	_sprite.region_enabled = true
	_sprite.region_rect = Rect2((icon % 8) * ICON_SIZE, (icon / 8) * ICON_SIZE, ICON_SIZE, ICON_SIZE)
	_sprite.offset = Vector2(0, -ICON_SIZE / 2.0)
	add_child(_sprite)


func _physics_process(delta: float) -> void:
	_age += delta
	_sprite.position.y = -absf(sin(_age * 3.0)) * bob_height
	if lifetime > 0.0:
		if _age >= lifetime:
			queue_free()
			return
		if _age >= lifetime - blink_time:
			_sprite.visible = fmod(_age, 0.25) < 0.15
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead or player.hp >= player.max_hp:
		return
	if global_position.distance_to(player.global_position) <= pickup_radius:
		player.heal(heal_amount)
		queue_free()
