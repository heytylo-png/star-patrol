class_name Enemy
extends CharacterBody2D
## A basic enemy with HP. Draws its own HP bar and a red ring when targeted.

signal died

@export var max_hp: int = 50

var hp: int
var _targeted: bool = false


func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")  # The tap-to-target code looks for this group.


func take_damage(amount: int) -> void:
	hp -= amount
	queue_redraw()
	_flash()
	if hp <= 0:
		died.emit()
		queue_free()


func set_targeted(on: bool) -> void:
	_targeted = on
	queue_redraw()


func _flash() -> void:
	modulate = Color(1, 0.4, 0.4)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _draw() -> void:
	# Red ring under the enemy when it's the player's target.
	if _targeted:
		draw_arc(Vector2(0, 8), 18.0, 0.0, TAU, 32, Color.RED, 2.0)
	# HP bar above the enemy.
	var bar_width: float = 32.0
	var fill: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	draw_rect(Rect2(-bar_width / 2.0, -28.0, bar_width, 4.0), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-bar_width / 2.0, -28.0, bar_width * fill, 4.0), Color(0.3, 0.9, 0.3))
