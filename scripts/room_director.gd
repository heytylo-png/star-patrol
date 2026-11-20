class_name RoomDirector
extends Node
## Runs a dungeon room: waves of enemies, then the door opens and the exit ends the run.
##
## Waves: put each wave's enemies inside its own Node2D under the Waves node, in order.
## Only the first wave is in the room at the start; the next one appears when it's cleared.
## The last wave is announced as the boss.

@export var player: Player
@export var waves_root: Node2D           ## The node holding Wave1, Wave2, ...
@export var door: Node2D                 ## Removed when the last wave is cleared.
@export var exit_area: Area2D            ## Walking in here (after the door opens) wins.
@export var message: Label               ## Big text in the middle of the screen.
@export var heal_between_waves: bool = true
@export var boss_text: String = "The Throne Guardian awakens!"
@export var win_text: String = "Hollow Throne cleared!"

var _waves: Array[Node2D] = []
var _current: int = -1
var _alive: int = 0
var _door_open: bool = false
var _finished: bool = false
var _message_id: int = 0


func _ready() -> void:
	# Wait one frame so every node in the room has finished setting up.
	_setup.call_deferred()


func _setup() -> void:
	for child in waves_root.get_children():
		var wave := child as Node2D
		if wave:
			_waves.append(wave)
	# Take later waves out of the room until it's their turn.
	for i in range(1, _waves.size()):
		waves_root.remove_child(_waves[i])
	player.died.connect(_on_player_died)
	exit_area.body_entered.connect(_on_exit_body_entered)
	if _waves.is_empty():
		_open_door()
	else:
		_start_wave(0)


func _exit_tree() -> void:
	# Free waves that never got their turn (they're not in the tree, so nothing else will).
	for wave in _waves:
		if is_instance_valid(wave) and not wave.is_inside_tree():
			wave.free()


func _start_wave(index: int) -> void:
	if player.is_dead:
		return
	_current = index
	var wave: Node2D = _waves[index]
	if not wave.is_inside_tree():
		waves_root.add_child(wave)
	_alive = 0
	for child in wave.get_children():
		var enemy := child as Enemy
		if enemy:
			_alive += 1
			enemy.died.connect(_on_enemy_died)
	var is_boss: bool = index == _waves.size() - 1 and _waves.size() > 1
	_show(boss_text if is_boss else "Wave %d" % (index + 1))
	if _alive == 0:
		_on_wave_cleared()


func _on_enemy_died() -> void:
	_alive -= 1
	if _alive <= 0:
		_on_wave_cleared()


func _on_wave_cleared() -> void:
	if player.is_dead:
		return
	if heal_between_waves:
		player.heal_full()
	if _current + 1 < _waves.size():
		_show("Wave cleared!")
		get_tree().create_timer(2.0).timeout.connect(_start_wave.bind(_current + 1))
	else:
		_open_door()


func _open_door() -> void:
	_door_open = true
	_show("The door is open. Head north!")
	if door:
		var tween := door.create_tween()
		tween.tween_property(door, "modulate:a", 0.0, 0.6)
		tween.tween_callback(door.queue_free)


func _on_exit_body_entered(body: Node2D) -> void:
	if body != player or not _door_open or _finished:
		return
	_finished = true
	_show(win_text, 0.0)
	get_tree().create_timer(4.0).timeout.connect(_restart)


func _on_player_died() -> void:
	if _finished:
		return
	_finished = true
	_show("You fell...", 0.0)
	get_tree().create_timer(3.0).timeout.connect(_restart)


func _restart() -> void:
	get_tree().reload_current_scene()


## Shows `text` in the middle of the screen; hides it after `seconds` (0 = keep it).
func _show(text: String, seconds: float = 2.5) -> void:
	_message_id += 1
	var id: int = _message_id
	message.text = text
	message.show()
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds).timeout
	if id == _message_id:
		message.hide()
