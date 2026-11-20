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
## Optional: fill the wall with a tile from a sheet instead of the flat color.
@export var tile_texture: Texture2D:
	set(value):
		tile_texture = value
		queue_redraw()
@export var tile_region: Rect2 = Rect2(0, 0, 16, 16):   ## Which part of the sheet to repeat.
	set(value):
		tile_region = value
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
	var rect := Rect2(-size / 2.0, size)
	if tile_texture == null or tile_region.size.x <= 0.0 or tile_region.size.y <= 0.0:
		draw_rect(rect, color)
		return
	# Repeat the tile across the wall, cropping the last row/column to fit.
	var y := rect.position.y
	while y < rect.end.y:
		var h: float = minf(tile_region.size.y, rect.end.y - y)
		var x := rect.position.x
		while x < rect.end.x:
			var w: float = minf(tile_region.size.x, rect.end.x - x)
			draw_texture_rect_region(tile_texture, Rect2(x, y, w, h),
					Rect2(tile_region.position, Vector2(w, h)))
			x += tile_region.size.x
		y += tile_region.size.y
