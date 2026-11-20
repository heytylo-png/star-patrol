class_name SkillButton
extends Control
## Round on-screen skill button. Put it in the UI CanvasLayer, about 110 x 110.
## Lit up when the skill can be used, grey when it can't, with a dark sweep while cooling down.

@export var player: Player        ## Drag your Player node here in the Inspector.
@export var skill_index: int = 0  ## 0 = first skill, 1 = second skill.
@export var label: String = "Skill"
@export var radius: float = 50.0


func _ready() -> void:
	# We read touches ourselves in _input, like the joystick does.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and _is_inside(event.position):
		get_viewport().set_input_as_handled()  # So this tap doesn't also target an enemy.
		if player:
			player.use_skill(skill_index)


func _is_inside(screen_pos: Vector2) -> bool:
	return screen_pos.distance_to(get_global_rect().get_center()) <= radius


func _draw() -> void:
	var middle: Vector2 = size / 2.0
	var usable: bool = player != null and player.can_use_skill(skill_index)
	var fill := Color(1.0, 0.5, 0.1, 0.7) if usable else Color(0.4, 0.4, 0.4, 0.5)
	draw_circle(middle, radius, fill)
	var cooldown: float = player.skill_cooldown_ratio(skill_index) if player else 0.0
	if cooldown > 0.0:
		draw_arc(middle, radius - 6.0, -PI / 2.0, -PI / 2.0 + TAU * cooldown, 32,
				Color(0, 0, 0, 0.6), 12.0)
	var font := ThemeDB.fallback_font
	var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	draw_string(font, middle + Vector2(-text_size.x / 2.0, 6.0), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
