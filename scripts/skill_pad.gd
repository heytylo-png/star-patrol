@tool
class_name SkillPad
extends Control
## Lays out the combat buttons in the bottom-right corner, sized for thumbs:
## a big Attack button in the corner, the skill buttons on an arc around it,
## and the ultimate a little further out. Anchor this Control to the bottom-right.
##
## Children are SkillButtons: skill_index -1 = Attack, 0-3 = the arc (in order),
## and any higher index (the ultimate) goes to the ultimate spot.

@export var attack_radius: float = 66.0:
	set(value):
		attack_radius = value
		_layout()
@export var skill_radius: float = 40.0:
	set(value):
		skill_radius = value
		_layout()
@export var arc_distance: float = 150.0:   ## From the Attack center to each skill center.
	set(value):
		arc_distance = value
		_layout()
@export var arc_start_degrees: float = 175.0:   ## 180 = straight left of Attack.
	set(value):
		arc_start_degrees = value
		_layout()
@export var arc_end_degrees: float = 275.0:     ## 270 = straight above Attack.
	set(value):
		arc_end_degrees = value
		_layout()
@export var ultimate_radius: float = 36.0:
	set(value):
		ultimate_radius = value
		_layout()
@export var ultimate_distance: float = 245.0:
	set(value):
		ultimate_distance = value
		_layout()
@export var ultimate_degrees: float = 225.0:    ## Up and to the left, outside the arc.
	set(value):
		ultimate_degrees = value
		_layout()
@export var margin: float = 24.0:              ## Gap from the screen edges.
	set(value):
		margin = value
		_layout()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_layout)
	_layout()


func _layout() -> void:
	if not is_inside_tree():
		return
	var attack_center := Vector2(size.x - margin - attack_radius, size.y - margin - attack_radius)
	var arc_buttons: Array[SkillButton] = []
	for child in get_children():
		var button := child as SkillButton
		if button == null:
			continue
		if button.skill_index < 0:
			_place(button, attack_center, attack_radius)
		elif button.skill_index <= 3:
			arc_buttons.append(button)
		else:
			var angle := deg_to_rad(ultimate_degrees)
			_place(button, attack_center + Vector2.from_angle(angle) * ultimate_distance,
					ultimate_radius)
	arc_buttons.sort_custom(func(a: SkillButton, b: SkillButton) -> bool:
		return a.skill_index < b.skill_index)
	for i in arc_buttons.size():
		var t: float = 0.5 if arc_buttons.size() == 1 else float(i) / (arc_buttons.size() - 1)
		var angle := deg_to_rad(lerpf(arc_start_degrees, arc_end_degrees, t))
		_place(arc_buttons[i], attack_center + Vector2.from_angle(angle) * arc_distance,
				skill_radius)


func _place(button: SkillButton, center: Vector2, button_radius: float) -> void:
	button.radius = button_radius
	button.size = Vector2.ONE * button_radius * 2.0
	button.position = center - button.size / 2.0
