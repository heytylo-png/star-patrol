class_name FlameWarden
extends Player
## Warrior subclass from the design doc: the four Warrior starting skills in their fire versions,
## Heat built by skills, overheat at 100, and Inferno Vent to dump Heat as an explosion.
##
## Skills (index: name):
## 0. Cleave: arc attack in front of you; builds Heat.
## 1. Shield Bash: stuns your target; when the stun ends it explodes in fire.
## 2. Charge: dash to your target and hit it.
## 3. War Cry: taunts nearby enemies and sets them burning.
## 4. Inferno Vent (ultimate): needs 50+ Heat; dumps it all as an explosion that scales with it.

enum Skill { CLEAVE, SHIELD_BASH, CHARGE, WAR_CRY, INFERNO_VENT }

const SKILL_NAMES: Array[String] = ["Cleave", "Shield Bash", "Charge", "War Cry", "Inferno Vent"]

@export_group("Heat")
@export var max_heat: float = 100.0
@export var heat_per_auto_attack: float = 0.0    ## The design doc builds Heat from skills only.
@export var heat_decay_per_second: float = 5.0   ## How fast Heat cools when not fighting.
@export var heat_decay_delay: float = 3.0        ## Seconds without fighting before Heat cools.
@export var burning_heat: float = 70.0           ## The design doc's "high Heat" line.

@export_group("Overheat")
@export var overheat_damage_percent: float = 0.05  ## Share of max HP lost per second.
@export var overheat_duration: float = 3.0
@export var overheat_reset_heat: float = 60.0    ## Heat after an overheat ends.

@export_group("Cleave")
@export var cleave_damage: int = 14
@export var cleave_range: float = 52.0
@export var cleave_arc_degrees: float = 120.0
@export var cleave_heat: float = 10.0
@export var cleave_cooldown: float = 3.0

@export_group("Shield Bash")
@export var bash_damage: int = 10
@export var bash_stun: float = 1.2               ## Seconds the target is stunned.
@export var bash_explosion_damage: int = 20      ## Fire explosion when the stun ends.
@export var bash_explosion_radius: float = 40.0
@export var bash_heat: float = 15.0
@export var bash_cooldown: float = 8.0

@export_group("Charge")
@export var charge_range: float = 180.0          ## Farthest target you can charge.
@export var charge_speed: float = 520.0
@export var charge_max_time: float = 0.45        ## Gives up if it hasn't arrived by then.
@export var charge_damage: int = 16
@export var charge_heat: float = 15.0
@export var charge_cooldown: float = 10.0

@export_group("War Cry")
@export var war_cry_radius: float = 140.0
@export var war_cry_burn_damage: int = 3         ## Per tick.
@export var war_cry_burn_ticks: int = 6
@export var war_cry_burn_interval: float = 0.5
@export var war_cry_heat: float = 20.0
@export var war_cry_cooldown: float = 15.0

@export_group("Inferno Vent")
@export var vent_min_heat: float = 50.0
@export var vent_base_damage: int = 10
@export var vent_damage_per_heat: float = 0.5    ## Extra damage per point of Heat spent.
@export var vent_radius: float = 90.0
@export var vent_cooldown: float = 60.0

var heat: float = 0.0
var overheated: bool = false
var _cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]   # Seconds left, per skill.
var _time_since_combat: float = 0.0
var _overheat_left: float = 0.0
var _overheat_tick: float = 0.0
var _charge_target: Enemy = null
var _charge_time: float = 0.0
var _effects: Array[Dictionary] = []   # Short-lived drawings: rings and arcs.


func _physics_process(delta: float) -> void:
	super(delta)
	for i in _cooldowns.size():
		_cooldowns[i] = maxf(_cooldowns[i] - delta, 0.0)
	_update_heat(delta)
	_update_effects(delta)


func _on_auto_attack_hit(_enemy: Enemy) -> void:
	_gain_heat(heat_per_auto_attack)


# --- Skills ---

func use_skill(index: int) -> void:
	if not can_use_skill(index):
		return
	_cooldowns[index] = skill_cooldown(index)
	_time_since_combat = 0.0
	match index:
		Skill.CLEAVE:
			_cleave()
		Skill.SHIELD_BASH:
			_shield_bash()
		Skill.CHARGE:
			_charge()
		Skill.WAR_CRY:
			_war_cry()
		Skill.INFERNO_VENT:
			_inferno_vent()


func can_use_skill(index: int) -> bool:
	if is_dead or index < 0 or index >= _cooldowns.size() or _cooldowns[index] > 0.0:
		return false
	if _charge_target != null:
		return false  # Mid-charge.
	match index:
		Skill.SHIELD_BASH:
			return has_target_in_range()
		Skill.CHARGE:
			return _has_live_target() \
					and global_position.distance_to(target.global_position) <= charge_range
		Skill.INFERNO_VENT:
			return heat >= vent_min_heat
	return true


func skill_cooldown(index: int) -> float:
	match index:
		Skill.CLEAVE:
			return cleave_cooldown
		Skill.SHIELD_BASH:
			return bash_cooldown
		Skill.CHARGE:
			return charge_cooldown
		Skill.WAR_CRY:
			return war_cry_cooldown
		Skill.INFERNO_VENT:
			return vent_cooldown
	return 0.0


func skill_cooldown_ratio(index: int) -> float:
	if index < 0 or index >= _cooldowns.size():
		return 0.0
	var total: float = skill_cooldown(index)
	return _cooldowns[index] / total if total > 0.0 else 0.0


func _cleave() -> void:
	var aim: Vector2 = facing
	if _has_live_target():
		aim = global_position.direction_to(target.global_position)
	var half_arc: float = deg_to_rad(cleave_arc_degrees) / 2.0
	for enemy in _enemies_within(cleave_range):
		var to_enemy: Vector2 = global_position.direction_to(enemy.global_position)
		if absf(aim.angle_to(to_enemy)) <= half_arc:
			hit_enemy(enemy, cleave_damage)
	_gain_heat(cleave_heat)
	_add_effect({"kind": "arc", "pos": global_position, "radius": cleave_range,
			"angle": aim.angle(), "arc": half_arc * 2.0, "time": 0.15,
			"color": Color(1.0, 0.55, 0.15)})


func _shield_bash() -> void:
	var enemy: Enemy = target
	hit_enemy(enemy, bash_damage)
	enemy.stun(bash_stun)
	_gain_heat(bash_heat)
	get_tree().create_timer(bash_stun).timeout.connect(_bash_explosion.bind(enemy))


func _bash_explosion(enemy: Enemy) -> void:
	if not is_instance_valid(enemy) or is_dead:
		return
	var center: Vector2 = enemy.global_position
	for other in get_tree().get_nodes_in_group("enemies"):
		var e := other as Enemy
		if e and center.distance_to(e.global_position) <= bash_explosion_radius:
			hit_enemy(e, bash_explosion_damage, true, true)  # Heavy.
	_add_effect({"kind": "ring", "pos": center, "radius": bash_explosion_radius, "time": 0.3,
			"color": Color(1.0, 0.45, 0.1)})


func _charge() -> void:
	_charge_target = target
	_charge_time = 0.0


# Called by Player._move() every physics frame; returns true while charging.
func _custom_move(delta: float) -> bool:
	if _charge_target == null:
		return false
	_charge_time += delta
	if not is_instance_valid(_charge_target) or _charge_time > charge_max_time:
		_charge_target = null
		return false
	if global_position.distance_to(_charge_target.global_position) <= attack_range:
		hit_enemy(_charge_target, charge_damage, true, true)  # Heavy.
		_gain_heat(charge_heat)
		_charge_target = null
		return false
	velocity = global_position.direction_to(_charge_target.global_position) * charge_speed
	move_and_slide()
	return true


func _war_cry() -> void:
	for enemy in _enemies_within(war_cry_radius):
		enemy.taunt()
		enemy.apply_burn(war_cry_burn_damage, war_cry_burn_ticks, war_cry_burn_interval, self)
	_gain_heat(war_cry_heat)
	_add_effect({"kind": "ring", "pos": global_position, "radius": war_cry_radius, "time": 0.4,
			"color": Color(1.0, 0.8, 0.3)})


func _inferno_vent() -> void:
	var spent: float = heat
	var damage: int = vent_base_damage + roundi(spent * vent_damage_per_heat)
	for enemy in _enemies_within(vent_radius):
		hit_enemy(enemy, damage)
	_set_heat(0.0)
	overheated = false
	_overheat_left = 0.0
	CombatFeel.shake_vent()
	_add_effect({"kind": "ring", "pos": global_position, "radius": vent_radius, "time": 0.45,
			"color": Color(1.0, 0.35, 0.1)})


# --- Heat ---

func _update_heat(delta: float) -> void:
	if overheated:
		_overheat_left -= delta
		_overheat_tick -= delta
		if _overheat_tick <= 0.0:
			_overheat_tick += 1.0
			take_damage(maxi(1, ceili(max_hp * overheat_damage_percent)), null, false)
		if _overheat_left <= 0.0:
			overheated = false
			_set_heat(overheat_reset_heat)
		return
	_time_since_combat += delta
	if _time_since_combat >= heat_decay_delay and heat > 0.0:
		_set_heat(heat - heat_decay_per_second * delta)


func _gain_heat(amount: float) -> void:
	_time_since_combat = 0.0
	if overheated or amount <= 0.0:
		return
	_set_heat(heat + amount)
	if heat >= max_heat:
		overheated = true
		_overheat_left = overheat_duration
		_overheat_tick = 0.0   # First self-damage tick right away.


func _set_heat(value: float) -> void:
	heat = clampf(value, 0.0, max_heat)


# --- Helpers ---

func _has_live_target() -> bool:
	return target != null and is_instance_valid(target) and target.hp > 0


func _enemies_within(radius: float) -> Array[Enemy]:
	var found: Array[Enemy] = []
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy and enemy.hp > 0 and global_position.distance_to(enemy.global_position) <= radius:
			found.append(enemy)
	return found


func _add_effect(effect: Dictionary) -> void:
	effect["left"] = effect["time"]
	_effects.append(effect)


func _update_effects(delta: float) -> void:
	if _effects.is_empty():
		return
	for effect in _effects:
		effect["left"] -= delta
	_effects = _effects.filter(func(e: Dictionary) -> bool: return e["left"] > 0.0)
	queue_redraw()


func _draw() -> void:
	super()  # HP bar.
	for effect in _effects:
		var t: float = 1.0 - effect["left"] / effect["time"]   # 0 -> 1 over the effect.
		var color: Color = effect["color"]
		color.a = 1.0 - t
		var center: Vector2 = to_local(effect["pos"])
		if effect["kind"] == "ring":
			draw_arc(center, effect["radius"] * (0.3 + 0.7 * t), 0.0, TAU, 48, color, 4.0)
		else:
			var half: float = effect["arc"] / 2.0
			draw_arc(center, effect["radius"] * (0.6 + 0.4 * t), effect["angle"] - half,
					effect["angle"] + half, 24, color, 6.0)
