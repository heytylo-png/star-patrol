class_name DamageNumber
extends Node2D
## A floating pixel number that rises and fades. Spawned by CombatFeel.damage_number().

const DIGITS: Texture2D = preload("res://art/ui/damage_digits.png")
const CELL := Vector2(5, 7)    # One digit cell in damage_digits.png.
const SPACING := 4.0           # Cells overlap by one outline pixel.

var amount: int = 0
var color: Color = Color.WHITE
var pixel_scale: float = 2.0   # World pixels per digit pixel.
var rise: float = 18.0         # How far it floats up.
var duration: float = 0.7      # Seconds until it disappears.
var pop: float = 1.0           # Starting size multiplier (crits start bigger and shrink).

var _time: float = 0.0
var _start: Vector2


func _ready() -> void:
	z_index = 20
	_start = position


func _process(delta: float) -> void:
	_time += delta
	var t: float = clampf(_time / duration, 0.0, 1.0)
	position = _start + Vector2(0, -rise * (1.0 - pow(1.0 - t, 2.0)))   # Ease out.
	scale = Vector2.ONE * lerpf(pop, 1.0, minf(t * 4.0, 1.0))
	modulate.a = 1.0 if t < 0.6 else 1.0 - (t - 0.6) / 0.4
	if t >= 1.0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var text := str(amount)
	var width: float = (SPACING * (text.length() - 1) + CELL.x) * pixel_scale
	var x: float = -width / 2.0
	for ch in text:
		var digit := int(ch)
		var src := Rect2(digit * CELL.x, 0, CELL.x, CELL.y)
		var dst := Rect2(x, -CELL.y * pixel_scale, CELL.x * pixel_scale, CELL.y * pixel_scale)
		draw_texture_rect_region(DIGITS, dst, src, color)
		x += SPACING * pixel_scale
