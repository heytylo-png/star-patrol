class_name Enemy
extends CharacterBody2D
## A basic enemy with HP. Chases the player once they come close (or once hit),
## and attacks when next to them. Draws its own HP bar and a red ring when targeted.

signal died

@export var max_hp: int = 50
@export var move_speed: float = 60.0          ## Pixels per second while chasing.
@export var aggro_range: float = 150.0        ## Starts chasing when the player is this close.
@export var attack_range: float = 30.0        ## Hits the player when this close.
@export var attack_damage: int = 4
@export var attack_cooldown: float = 1.5      ## Seconds between hits.

@export_group("Hit feedback")
@export var flash_duration: float = 0.1        ## White flash when hit, in seconds.
@export var knockback_strength: float = 140.0  ## Push speed when hit (pixels per second).
@export var knockback_friction: float = 900.0  ## How fast the push slows down.

@export_group("Look")
@export var bar_width: float = 32.0           ## HP bar width (bigger for bosses).
@export var bar_offset: float = 28.0          ## How far above the center the HP bar sits.
@export var ring_radius: float = 18.0         ## Size of the red target ring.

var hp: int
var _targeted: bool = false
var _aggro: bool = false
var _attack_timer: float = 0.0
var _player: Player = null
var _knockback: Vector2 = Vector2.ZERO
var _flash: HitFlash
var _stun_left: float = 0.0
var _burn_ticks: int = 0
var _burn_damage: int = 0
var _burn_interval: float = 0.5
var _burn_next: float = 0.0
var _burn_source: Node2D = null


func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")  # The tap-to-target code looks for this group.
	_flash = HitFlash.new(self)


func _physics_process(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_update_burn(delta)
	if _knockback != Vector2.ZERO:
		# Being pushed back: no chasing or attacking until the push ends.
		velocity = _knockback
		move_and_slide()
		_knockback = _knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
		return
	if _stun_left > 0.0:
		_stun_left -= delta
		if _stun_left <= 0.0:
			queue_redraw()
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Player
		if _player == null:
			return
	if _player.is_dead or hp <= 0:
		return
	var distance: float = global_position.distance_to(_player.global_position)
	if not _aggro and distance <= aggro_range:
		_aggro = true
	if not _aggro:
		return
	if distance > attack_range:
		velocity = global_position.direction_to(_player.global_position) * move_speed
		move_and_slide()
	elif _attack_timer <= 0.0:
		_attack_timer = attack_cooldown
		_player.take_damage(attack_damage, self)


## Damage with no attacker (no knockback).
func take_damage(amount: int) -> void:
	take_hit(amount, null)


## Damage from `source`: white flash, knockback away from the source, and a short hit-stop.
## Set `feedback` to false for small repeated damage (like burning) to skip knockback and hit-stop.
## `crit` shows the damage number as a critical hit.
func take_hit(amount: int, source: Node2D = null, feedback: bool = true,
		crit: bool = false) -> void:
	if hp <= 0:
		return  # Already dying (removal happens at the end of the frame).
	_aggro = true  # Getting hit always makes it fight back.
	hp -= amount
	var kind := CombatFeel.NumberKind.CRIT if crit else CombatFeel.NumberKind.NORMAL
	if not feedback and not crit:
		kind = CombatFeel.NumberKind.BURN
	CombatFeel.damage_number(global_position + Vector2(0, -bar_offset - 2.0), amount, kind)
	queue_redraw()
	_flash.play(flash_duration)
	if feedback:
		if source:
			_knockback = source.global_position.direction_to(global_position) * knockback_strength
		CombatFeel.hit_stop()
	if hp <= 0:
		died.emit()
		queue_free()


## Can't move or attack for `seconds`.
func stun(seconds: float) -> void:
	_stun_left = maxf(_stun_left, seconds)
	queue_redraw()


## Makes it come after the player right away.
func taunt() -> void:
	_aggro = true


## Takes `damage` every `interval` seconds, `ticks` times (replaces any current burn).
func apply_burn(damage: int, ticks: int, interval: float, source: Node2D = null) -> void:
	_burn_damage = damage
	_burn_ticks = ticks
	_burn_interval = interval
	_burn_next = interval
	_burn_source = source


func _update_burn(delta: float) -> void:
	if _burn_ticks <= 0 or hp <= 0:
		return
	_burn_next -= delta
	if _burn_next <= 0.0:
		_burn_next += _burn_interval
		_burn_ticks -= 1
		var source: Node2D = _burn_source if is_instance_valid(_burn_source) else null
		take_hit(_burn_damage, source, false)


func set_targeted(on: bool) -> void:
	_targeted = on
	queue_redraw()


func _draw() -> void:
	# Red ring under the enemy when it's the player's target.
	if _targeted:
		draw_arc(Vector2(0, ring_radius * 0.45), ring_radius, 0.0, TAU, 32, Color.RED, 2.0)
	# Stun stars above the head.
	if _stun_left > 0.0:
		for i in 3:
			var star := Vector2(-8.0 + i * 8.0, -bar_offset - 8.0)
			draw_rect(Rect2(star - Vector2(1.5, 1.5), Vector2(3, 3)), Color(1.0, 0.9, 0.3))
	# HP bar above the enemy.
	var fill: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	draw_rect(Rect2(-bar_width / 2.0, -bar_offset, bar_width, 4.0), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(-bar_width / 2.0, -bar_offset, bar_width * fill, 4.0), Color(0.3, 0.9, 0.3))
