class_name FlameWarden
extends Player
## Warrior specialization: builds Heat by fighting and spends it on fire skills.
##
## Heat (0 to max_heat):
## - Auto-attacks and Flame Strike add Heat.
## - After a few seconds without fighting, Heat slowly cools down.
##
## Skills:
## 0. Flame Strike: a heavy hit on your target. Free, builds Heat, short cooldown.
## 1. Ember Ring: burns every enemy around you. Costs Heat.

@export_group("Heat")
@export var max_heat: float = 100.0
@export var heat_per_auto_attack: float = 10.0
@export var heat_decay_per_second: float = 5.0   ## How fast Heat cools when not fighting.
@export var heat_decay_delay: float = 3.0        ## Seconds without fighting before Heat cools.

@export_group("Flame Strike")
@export var strike_damage: int = 25
@export var strike_heat_gain: float = 25.0
@export var strike_cooldown: float = 4.0

@export_group("Ember Ring")
@export var ring_damage: int = 20
@export var ring_heat_cost: float = 40.0
@export var ring_radius: float = 70.0            ## Pixels around the player.
@export var ring_cooldown: float = 6.0

var heat: float = 0.0
var _cooldowns: Array[float] = [0.0, 0.0]        # Seconds left, per skill.
var _time_since_combat: float = 0.0
var _ring_effect: float = 0.0                    # Ember Ring animation, 0 to 1.


func _physics_process(delta: float) -> void:
	super(delta)
	for i in _cooldowns.size():
		_cooldowns[i] = maxf(_cooldowns[i] - delta, 0.0)
	_time_since_combat += delta
	if _time_since_combat >= heat_decay_delay and heat > 0.0:
		_set_heat(heat - heat_decay_per_second * delta)


func _on_auto_attack_hit(_enemy: Enemy) -> void:
	_gain_heat(heat_per_auto_attack)


func use_skill(index: int) -> void:
	if not can_use_skill(index):
		return
	match index:
		0:
			_flame_strike()
		1:
			_ember_ring()


func can_use_skill(index: int) -> bool:
	if is_dead:
		return false
	if index < 0 or index >= _cooldowns.size() or _cooldowns[index] > 0.0:
		return false
	match index:
		0:
			return has_target_in_range()
		1:
			return heat >= ring_heat_cost
	return false


func skill_cooldown_ratio(index: int) -> float:
	if index < 0 or index >= _cooldowns.size():
		return 0.0
	var total: float = strike_cooldown if index == 0 else ring_cooldown
	return _cooldowns[index] / total if total > 0.0 else 0.0


func _flame_strike() -> void:
	_cooldowns[0] = strike_cooldown
	target.take_hit(strike_damage, self)
	_gain_heat(strike_heat_gain)


func _ember_ring() -> void:
	_cooldowns[1] = ring_cooldown
	_set_heat(heat - ring_heat_cost)
	_time_since_combat = 0.0
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy and global_position.distance_to(enemy.global_position) <= ring_radius:
			enemy.take_hit(ring_damage, self)
	# Expanding fire ring, drawn in _draw().
	var tween := create_tween()
	tween.tween_method(_set_ring_effect, 0.0, 1.0, 0.35)
	tween.tween_callback(_set_ring_effect.bind(0.0))


func _gain_heat(amount: float) -> void:
	_time_since_combat = 0.0
	_set_heat(heat + amount)


func _set_heat(value: float) -> void:
	heat = clampf(value, 0.0, max_heat)


func _set_ring_effect(value: float) -> void:
	_ring_effect = value
	queue_redraw()


func _draw() -> void:
	super()  # HP bar.
	if _ring_effect > 0.0:
		var color := Color(1.0, 0.5, 0.1, 1.0 - _ring_effect)
		draw_arc(Vector2.ZERO, ring_radius * _ring_effect, 0.0, TAU, 48, color, 4.0)
