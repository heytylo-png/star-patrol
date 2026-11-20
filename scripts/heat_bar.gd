class_name HeatBar
extends Control
## Shows a FlameWarden's Heat. Put it in the UI CanvasLayer, about 260 x 28.
## A tick marks the high-Heat line (70), and the bar pulses red as Heat nears 100.

@export var player: FlameWarden   ## Drag your Player node here in the Inspector.
@export var tick_heat: float = 70.0                    ## Where the tick mark sits.
@export var fill_color: Color = Color(1.0, 0.45, 0.1)
@export var pulse_color: Color = Color(0.95, 0.1, 0.1)
@export var pulse_start_heat: float = 85.0             ## Pulsing starts here...
@export var pulse_min_speed: float = 2.0               ## ...this many pulses per second...
@export var pulse_max_speed: float = 7.0               ## ...speeding up to this at full Heat.
@export var overheat_speed: float = 10.0               ## Pulses per second while overheated.


func _process(_delta: float) -> void:
	queue_redraw()


## How strongly the bar is tinted red right now (0 = not at all, 1 = fully red).
func pulse_amount() -> float:
	if player == null:
		return 0.0
	var seconds: float = Time.get_ticks_msec() / 1000.0
	if player.overheated:
		return 0.6 + 0.4 * sin(seconds * TAU * overheat_speed)
	if player.heat < pulse_start_heat or player.max_heat <= pulse_start_heat:
		return 0.0
	var closeness: float = clampf((player.heat - pulse_start_heat)
			/ (player.max_heat - pulse_start_heat), 0.0, 1.0)
	var speed: float = lerpf(pulse_min_speed, pulse_max_speed, closeness)
	var wave: float = 0.5 + 0.5 * sin(seconds * TAU * speed)
	return wave * lerpf(0.35, 1.0, closeness)


func _draw() -> void:
	if player == null:
		return
	var fill: float = clampf(player.heat / player.max_heat, 0.0, 1.0)
	var pulse: float = pulse_amount()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * fill, size.y)), fill_color.lerp(pulse_color, pulse))
	if pulse > 0.0:
		var border := pulse_color
		border.a = pulse
		draw_rect(Rect2(Vector2.ZERO, size), border, false, 2.0)
	var tick_x: float = size.x * tick_heat / player.max_heat
	draw_line(Vector2(tick_x, 0), Vector2(tick_x, size.y), Color.WHITE, 2.0)
	var text: String = "OVERHEAT" if player.overheated else "HEAT %d" % int(player.heat)
	draw_string(ThemeDB.fallback_font, Vector2(8, size.y - 8), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
