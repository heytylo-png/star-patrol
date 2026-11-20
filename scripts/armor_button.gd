class_name ArmorButton
extends Control
## Test button that swaps one gear slot through a list of pieces (and "nothing").
## Tap it, or press T on a computer. Put it in the UI CanvasLayer, about 110 x 110.

@export var character: CharacterSprite   ## The player's CharacterSprite node.
@export var pieces: Array = []           ## ArmorPiece resources to cycle through.
@export var radius: float = 40.0

var _index: int = 0   # Position in pieces; pieces.size() means "nothing".


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Start on whatever the character is already wearing in that slot.
	if character and not pieces.is_empty() and pieces[0] is ArmorPiece:
		var worn := character.get_equipped(pieces[0].slot)
		var found: int = pieces.find(worn)
		_index = found if found >= 0 else pieces.size()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and _is_inside(event.position):
		get_viewport().set_input_as_handled()
		_next()
	elif event.is_action_pressed("swap_armor"):
		_next()


func _next() -> void:
	if character == null or pieces.is_empty():
		return
	_index = (_index + 1) % (pieces.size() + 1)
	if _index < pieces.size():
		character.equip(pieces[_index])
	elif pieces[0] is ArmorPiece:
		character.unequip(pieces[0].slot)
	queue_redraw()


func _current_name() -> String:
	if _index < pieces.size() and pieces[_index] is ArmorPiece:
		return pieces[_index].display_name
	return "None"


func _is_inside(screen_pos: Vector2) -> bool:
	return screen_pos.distance_to(get_global_rect().get_center()) <= radius


func _draw() -> void:
	var middle: Vector2 = size / 2.0
	draw_circle(middle, radius, Color(0.35, 0.45, 0.7, 0.7))
	var font := ThemeDB.fallback_font
	for line in [["Armor", -4.0, 16], [_current_name(), 14.0, 12]]:
		var text: String = line[0]
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, line[2])
		draw_string(font, middle + Vector2(-text_size.x / 2.0, line[1]), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, line[2], Color.WHITE)
