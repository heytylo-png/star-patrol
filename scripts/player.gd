class_name Player
extends CharacterBody2D
## The player character: moves with the joystick (or D-pad / keyboard),
## and auto-attacks whatever enemy is targeted once it's in range.
## Class specializations (like FlameWarden) extend this script and add skills.

signal died

@export var max_hp: int = 100
@export var hp_bar_offset: float = 28.0  ## How far above the origin the HP bar sits.
@export var move_speed: float = 120.0      ## Pixels per second.
@export var attack_range: float = 40.0     ## How close the target must be to hit it.
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.8   ## Seconds between auto-attacks.
@export_range(0.0, 1.0) var crit_chance: float = 0.15  ## Chance for any hit to be critical.
@export var crit_multiplier: float = 1.75  ## Critical hits deal this much more damage.
@export var joystick: TouchJoystick        ## Drag your joystick node here in the Inspector.

@export_group("Hit feedback")
@export var flash_duration: float = 0.1       ## White flash when hit, in seconds.
@export var knockback_strength: float = 80.0  ## Push speed when hit (pixels per second).
@export var knockback_friction: float = 900.0 ## How fast the push slows down.

var target: Enemy = null
var hp: int
var is_dead: bool = false
var _attack_timer: float = 0.0
var _knockback: Vector2 = Vector2.ZERO
var _flash: HitFlash


func _ready() -> void:
	hp = max_hp
	add_to_group("player")  # Enemies find the player through this group.
	_flash = HitFlash.new(self)


func _physics_process(delta: float) -> void:
	_move(delta)
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_try_auto_attack()


func _move(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if joystick and joystick.output != Vector2.ZERO:
		direction = joystick.output
	else:
		# D-pad buttons and keyboard (WASD / arrow keys) both feed these actions.
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
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
	if not has_target_in_range():
		return  # Too far away: walk closer with the joystick.
	if _attack_timer > 0.0:
		return  # Still cooling down.
	_attack_timer = attack_cooldown
	hit_enemy(target, attack_damage)
	_on_auto_attack_hit(target)


## Hits `enemy` for `base_damage`, rolling for a critical hit. Returns true on a crit.
## Crits and `heavy` hits (big skill blows) shake the screen a little.
func hit_enemy(enemy: Enemy, base_damage: int, feedback: bool = true,
		heavy: bool = false) -> bool:
	var crit: bool = randf() < crit_chance
	var amount: int = roundi(base_damage * crit_multiplier) if crit else base_damage
	enemy.take_hit(amount, self, feedback, crit)
	if feedback and (crit or heavy):
		CombatFeel.shake_heavy()
	return crit


## Called when an enemy hits the player. `source` (the attacker) sets the knockback direction.
func take_damage(amount: int, source: Node2D = null) -> void:
	if is_dead:
		return
	hp = maxi(hp - amount, 0)
	queue_redraw()
	CombatFeel.damage_number(global_position + Vector2(0, -hp_bar_offset - 2.0), amount,
			CombatFeel.NumberKind.HURT)
	_flash.play(flash_duration)
	if source:
		_knockback = source.global_position.direction_to(global_position) * knockback_strength
	CombatFeel.hit_stop()
	if hp == 0:
		is_dead = true
		velocity = Vector2.ZERO
		set_physics_process(false)
		modulate = Color(0.4, 0.4, 0.4)
		died.emit()


func heal_full() -> void:
	if is_dead:
		return
	hp = max_hp
	queue_redraw()


func has_target_in_range() -> bool:
	if target == null or not is_instance_valid(target):
		return false
	return global_position.distance_to(target.global_position) <= attack_range


# --- Skill hooks. The base player has no skills; specializations override these. ---

## Called after each auto-attack lands.
func _on_auto_attack_hit(_enemy: Enemy) -> void:
	pass


## Try to use skill number `index` (0 = first skill button).
func use_skill(_index: int) -> void:
	pass


## Whether skill `index` can be used right now (off cooldown, enough resource, in range).
func can_use_skill(_index: int) -> bool:
	return false


## How much of skill `index`'s cooldown is left, from 1.0 (just used) to 0.0 (ready).
func skill_cooldown_ratio(_index: int) -> float:
	return 0.0


func _draw() -> void:
	# HP bar above the player.
	var bar_width: float = 32.0
	var fill: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	draw_rect(Rect2(-bar_width / 2.0, -hp_bar_offset, bar_width, 4.0), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-bar_width / 2.0, -hp_bar_offset, bar_width * fill, 4.0), Color(0.3, 0.6, 1.0))
