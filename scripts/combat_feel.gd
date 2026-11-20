extends Node
## Global combat polish, available everywhere as `CombatFeel` (an autoload).
## Open scenes/combat_feel.tscn to tune the numbers in the Inspector.

@export_group("Hit-stop")
@export var hit_stop_duration: float = 0.05     ## Seconds the game freezes on each hit.
@export var hit_stop_time_scale: float = 0.05   ## Game speed during the freeze (0 = full stop).

var _stop_until_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if Engine.time_scale != 1.0 and Time.get_ticks_msec() >= _stop_until_msec:
		Engine.time_scale = 1.0


## Freezes the game briefly. Overlapping calls extend the freeze instead of stacking it.
func hit_stop(duration: float = -1.0) -> void:
	if duration < 0.0:
		duration = hit_stop_duration
	if duration <= 0.0:
		return
	_stop_until_msec = maxi(_stop_until_msec, Time.get_ticks_msec() + int(duration * 1000.0))
	Engine.time_scale = hit_stop_time_scale
