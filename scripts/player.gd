class_name Player
extends CharacterBody2D
## The player character: moves with the joystick (or D-pad / keyboard),
## and auto-attacks whatever enemy is targeted once it's in range.

@export var move_speed: float = 120.0      ## Pixels per second.
@export var attack_range: float = 40.0     ## How close the target must be to hit it.
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.8   ## Seconds between auto-attacks.
@export var joystick: VirtualJoystick      ## Drag your joystick node here in the Inspector.

var target: Enemy = null
var _attack_timer: float = 0.0


func _physics_process(delta: float) -> void:
	_move()
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_try_auto_attack()


func _move() -> void:
	var direction: Vector2 = Vector2.ZERO
	if joystick and joystick.output != Vector2.ZERO:
		direction = joystick.output
	else:
		# D-pad buttons and keyboard (WASD / arrow keys) both feed these actions.
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()


func set_target(enemy: Enemy) -> void:
	if target and is_instance_valid(target):
		target.set_targeted(false)
	target = enemy
	if target:
		target.set_targeted(true)


func _try_auto_attack() -> void:
	if target == null:
		return
	if not is_instance_valid(target):
		target = null  # The enemy died and was removed.
		return
	if global_position.distance_to(target.global_position) > attack_range:
		return  # Too far away: walk closer with the joystick.
	if _attack_timer > 0.0:
		return  # Still cooling down.
	_attack_timer = attack_cooldown
	target.take_damage(attack_damage)
