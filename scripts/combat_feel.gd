extends Node
## Global combat polish, available everywhere as `CombatFeel` (an autoload).
## Open scenes/combat_feel.tscn to tune the numbers in the Inspector.

enum NumberKind { NORMAL, CRIT, HURT, BURN, HEAL }

@export_group("Hit-stop")
@export var hit_stop_duration: float = 0.05     ## Seconds the game freezes on each hit.
@export var hit_stop_time_scale: float = 0.05   ## Game speed during the freeze (0 = full stop).

@export_group("Damage numbers")
@export var number_color: Color = Color(1, 1, 1)           ## Normal hits on enemies.
@export var crit_color: Color = Color(1.0, 0.82, 0.25)     ## Critical hits.
@export var hurt_color: Color = Color(1.0, 0.3, 0.3)       ## Damage the player takes.
@export var burn_color: Color = Color(1.0, 0.55, 0.15)     ## Burning damage over time.
@export var heal_color: Color = Color(0.4, 1.0, 0.45)      ## Healing.
@export var number_scale: float = 2.0                      ## World pixels per digit pixel.
@export var crit_number_scale: float = 3.0
@export var crit_pop: float = 1.6                          ## Crits start this much bigger.
@export var number_rise: float = 18.0                      ## How far numbers float up.
@export var number_duration: float = 0.7                   ## Seconds on screen.
@export var number_jitter: float = 6.0                     ## Random sideways offset.


@export_group("Screen shake")
@export var heavy_shake_strength: float = 2.5   ## Pixels, for crits and heavy skill hits.
@export var heavy_shake_duration: float = 0.15
@export var vent_shake_strength: float = 5.0    ## Pixels, for Heat vents.
@export var vent_shake_duration: float = 0.3

var _stop_until_msec: int = 0
var _shake_strength: float = 0.0
var _shake_start_msec: int = 0
var _shake_duration: float = 0.0
var _shake_camera: Camera2D = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if Engine.time_scale != 1.0 and Time.get_ticks_msec() >= _stop_until_msec:
		Engine.time_scale = 1.0
	_update_shake()


## Freezes the game briefly. Overlapping calls extend the freeze instead of stacking it.
func hit_stop(duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = hit_stop_duration
	if duration <= 0.0:
		return
	_stop_until_msec = maxi(_stop_until_msec, Time.get_ticks_msec() + int(duration * 1000.0))
	Engine.time_scale = hit_stop_time_scale


## Shows a floating damage number at `world_position` (usually just above a character's head).
func damage_number(world_position: Vector2, amount: int,
		kind: NumberKind = NumberKind.NORMAL) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var number := DamageNumber.new()
	number.amount = amount
	number.rise = number_rise
	number.duration = number_duration
	match kind:
		NumberKind.CRIT:
			number.color = crit_color
			number.pixel_scale = crit_number_scale
			number.pop = crit_pop
		NumberKind.HURT:
			number.color = hurt_color
			number.pixel_scale = number_scale
		NumberKind.BURN:
			number.color = burn_color
			number.pixel_scale = number_scale
		NumberKind.HEAL:
			number.color = heal_color
			number.pixel_scale = number_scale
		_:
			number.color = number_color
			number.pixel_scale = number_scale
	number.position = world_position + Vector2(randf_range(-number_jitter, number_jitter), 0)
	scene.add_child(number)


## Small shake for crits and heavy skill hits.
func shake_heavy() -> void:
	shake(heavy_shake_strength, heavy_shake_duration)


## Bigger shake for Heat vents.
func shake_vent() -> void:
	shake(vent_shake_strength, vent_shake_duration)


## Shakes the current camera. A weaker shake never cuts a stronger one short.
func shake(strength: float, duration: float) -> void:
	var remaining: float = _shake_strength * _shake_left()
	if strength < remaining:
		return
	_shake_camera = get_viewport().get_camera_2d()
	_shake_strength = strength
	_shake_duration = maxf(duration, 0.001)
	_shake_start_msec = Time.get_ticks_msec()


# 1.0 right after a shake starts, falling to 0.0 when it ends (real time, ignores hit-stop).
func _shake_left() -> float:
	if _shake_strength <= 0.0:
		return 0.0
	var elapsed: float = (Time.get_ticks_msec() - _shake_start_msec) / 1000.0
	return clampf(1.0 - elapsed / _shake_duration, 0.0, 1.0)


func _update_shake() -> void:
	if _shake_strength <= 0.0:
		return
	if _shake_camera == null or not is_instance_valid(_shake_camera):
		_shake_strength = 0.0
		return
	var left: float = _shake_left()
	if left <= 0.0:
		_shake_camera.offset = Vector2.ZERO
		_shake_strength = 0.0
		return
	var amount: float = _shake_strength * left
	_shake_camera.offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))

