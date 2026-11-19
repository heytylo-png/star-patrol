class_name VirtualJoystick
extends Control
## On-screen joystick for touch screens.
## Put this on a Control node inside a CanvasLayer, sized about 240 x 240,
## anchored to the bottom-left of the screen.
## Other scripts read `output`: a Vector2 from (-1, -1) to (1, 1).

@export var radius: float = 80.0      ## How far the knob can move, in pixels.
@export var deadzone: float = 0.15    ## Ignore tiny thumb wobbles (0 to 1).

var output: Vector2 = Vector2.ZERO

var _touch_index: int = -1            # Which finger is holding the joystick (-1 = none).
var _knob_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# We read touches ourselves in _input, so the Control shouldn't eat them.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and _is_inside(event.position):
			# A finger landed on the joystick: claim it.
			_touch_index = event.index
			_update_knob(event.position)
			get_viewport().set_input_as_handled()  # So this tap doesn't also target an enemy.
		elif not event.pressed and event.index == _touch_index:
			# That finger lifted: reset.
			_touch_index = -1
			_knob_offset = Vector2.ZERO
			output = Vector2.ZERO
			queue_redraw()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)
		get_viewport().set_input_as_handled()


func _center() -> Vector2:
	return get_global_rect().get_center()


func _is_inside(screen_pos: Vector2) -> bool:
	# A little larger than the knob area so it's easy to grab.
	return screen_pos.distance_to(_center()) <= radius * 1.5


func _update_knob(screen_pos: Vector2) -> void:
	_knob_offset = (screen_pos - _center()).limit_length(radius)
	var strength: Vector2 = _knob_offset / radius
	output = strength if strength.length() > deadzone else Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	var middle: Vector2 = size / 2.0
	draw_circle(middle, radius, Color(1, 1, 1, 0.15))                      # Base
	draw_circle(middle + _knob_offset, radius * 0.4, Color(1, 1, 1, 0.5))  # Knob
