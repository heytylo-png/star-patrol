@tool  # So SkillPad can lay the buttons out in the editor.
class_name SkillButton
extends Control
## Round on-screen button for one skill, or for the basic attack (skill_index = -1).
## Lit when it can be used, grey when it can't, with a dark sweep while cooling down.
## Inside a SkillPad, the pad sets its position and radius.

@export var player: Player        ## Drag your Player node here in the Inspector.
@export var skill_index: int = 0  ## -1 = basic attack, 0+ = the player's skills.
@export_multiline var label: String = "Skill"
@export var radius: float = 40.0:
	set(value):
		radius = value
		queue_redraw()
@export var ready_color: Color = Color(1.0, 0.5, 0.1, 0.75)
@export var disabled_color: Color = Color(0.4, 0.4, 0.4, 0.5)
@export var sweep_color: Color = Color(0, 0, 0, 0.6)


func _ready() -> void:
	# We read touches ourselves in _input, like the joystick does.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventScreenTouch and event.pressed and _is_inside(event.position):
		get_viewport().set_input_as_handled()  # So this tap doesn't also target an enemy.
		press()


## Same as tapping the button.
func press() -> void:
	if player == null:
		return
	if skill_index < 0:
		player.basic_attack()
	else:
		player.use_skill(skill_index)


func _is_inside(screen_pos: Vector2) -> bool:
	return screen_pos.distance_to(get_global_rect().get_center()) <= radius


func _draw() -> void:
	var middle: Vector2 = size / 2.0
	var usable: bool = true
	var cooldown: float = 0.0
	if Engine.is_editor_hint():
		pass  # In the editor, just show the button.
	elif player == null or player.is_dead:
		usable = false
	elif skill_index >= 0:
		usable = player.can_use_skill(skill_index)
		cooldown = player.skill_cooldown_ratio(skill_index)
	else:
		cooldown = player.attack_cooldown_ratio()
	draw_circle(middle, radius, ready_color if usable else disabled_color)
	if cooldown > 0.0:
		var width: float = radius * 0.3
		draw_arc(middle, radius - width / 2.0, -PI / 2.0, -PI / 2.0 + TAU * cooldown, 32,
				sweep_color, width)
	var font := ThemeDB.fallback_font
	var font_size: int = clampi(roundi(radius * 0.36), 12, 26)
	var lines := label.split("\n")
	var line_height: float = font_size * 1.1
	var top: float = middle.y - line_height * (lines.size() - 1) / 2.0 + font_size * 0.35
	for i in lines.size():
		var text_size: Vector2 = font.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1,
				font_size)
		draw_string(font, Vector2(middle.x - text_size.x / 2.0, top + i * line_height), lines[i],
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
