@tool
class_name Wall
extends StaticBody2D
## A solid rectangle that blocks movement. Set its Size and Color in the Inspector;
## it shows up in the editor too, so you can lay out rooms by dragging walls around.

@export var size: Vector2 = Vector2(64, 16):
	set(value):
		size = value
		_rebuild()
@export var color: Color = Color(0.35, 0.3, 0.42):
	set(value):
		color = value
		queue_redraw()


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return  # _ready() will build it.
	var shape_node := get_node_or_null("Shape") as CollisionShape2D
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "Shape"
		add_child(shape_node)  # Made in code, so it isn't saved into the scene.
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-size / 2.0, size), color)
