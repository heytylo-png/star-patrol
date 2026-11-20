@tool
class_name CharacterSprite
extends Node2D
## Paper-doll character: one Sprite2D per layer, stacked bottom to top as in the design doc:
## Body, Legs, Chest, Helmet, Shoulders, Weapon, Effects.
## Every layer image is a 32x48 canvas lined up at the feet, and the feet sit on this node's origin.

const LAYER_ORDER: Array[String] = [
	"Body", "Legs", "Chest", "Helmet", "Shoulders", "Weapon", "Effects",
]
## Moves each 32x48 image so the soles (row 45) land on the origin.
const FEET_OFFSET := Vector2(-16, -46)

@export var body_texture: Texture2D:
	set(value):
		body_texture = value
		if _layers.has("Body"):
			_layers["Body"].texture = value
## Gear worn at the start (ArmorPiece resources).
@export var starting_gear: Array = []

var _layers: Dictionary = {}     # Layer name -> Sprite2D
var _equipped: Dictionary = {}   # ArmorPiece.Slot -> ArmorPiece


func _ready() -> void:
	for layer_name in LAYER_ORDER:
		var sprite := get_node_or_null(layer_name) as Sprite2D
		if sprite == null:
			sprite = Sprite2D.new()
			sprite.name = layer_name
			add_child(sprite)  # Made in code, so it isn't saved into the scene.
		sprite.centered = false
		sprite.offset = FEET_OFFSET
		_layers[layer_name] = sprite
	_layers["Body"].texture = body_texture
	for piece in starting_gear:
		if piece is ArmorPiece:
			equip(piece)


## Wear `piece`, replacing whatever was in its slot.
func equip(piece: ArmorPiece) -> void:
	var layer := _layers.get(piece.layer_name()) as Sprite2D
	if layer == null:
		return
	layer.texture = piece.texture
	_equipped[piece.slot] = piece


## Take off whatever is in `slot`.
func unequip(slot: ArmorPiece.Slot) -> void:
	_equipped.erase(slot)
	var layer := _layers.get(ArmorPiece.LAYER_NAMES[slot]) as Sprite2D
	if layer:
		layer.texture = null


## What is worn in `slot`, or null.
func get_equipped(slot: ArmorPiece.Slot) -> ArmorPiece:
	return _equipped.get(slot) as ArmorPiece
