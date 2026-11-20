class_name HitFlash
extends RefCounted
## White hit flash for a character and everything drawn under it.
## Call HitFlash.new(self) in _ready(), then play(duration) on each hit.

const SHADER: Shader = preload("res://shaders/hit_flash.gdshader")

var _node: CanvasItem
var _material: ShaderMaterial
var _tween: Tween


func _init(node: CanvasItem) -> void:
	_node = node
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	node.material = _material
	# Children (body polygon, sprite layers) draw with the same material.
	for child in node.find_children("*", "CanvasItem", true, false):
		child.use_parent_material = true


func play(duration: float) -> void:
	if _tween:
		_tween.kill()
	_material.set_shader_parameter("flash", 1.0)
	_tween = _node.create_tween()
	_tween.tween_method(_set_flash, 1.0, 0.0, duration)


func _set_flash(value: float) -> void:
	_material.set_shader_parameter("flash", value)
