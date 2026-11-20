class_name HeatBar
extends Control
## Shows a FlameWarden's Heat. Put it in the UI CanvasLayer, about 260 x 28.
## The white tick marks how much Heat Ember Ring needs.

@export var player: FlameWarden   ## Drag your Player node here in the Inspector.


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if player == null:
		return
	var fill: float = clampf(player.heat / player.max_heat, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * fill, size.y)), Color(1.0, 0.45, 0.1))
	var tick_x: float = size.x * player.ring_heat_cost / player.max_heat
	draw_line(Vector2(tick_x, 0), Vector2(tick_x, size.y), Color.WHITE, 2.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(8, size.y - 8), "HEAT %d" % int(player.heat),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
