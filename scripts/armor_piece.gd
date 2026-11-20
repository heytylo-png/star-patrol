@tool  # So CharacterSprite can show gear in the editor.
class_name ArmorPiece
extends Resource
## One piece of gear that shows on the character: its name, slot, tier and layer image.
## Make a new piece with right-click in FileSystem > New > Resource > ArmorPiece.
## The image must use the same 32x48 canvas as the body, lined up at the feet.

enum Slot { LEGS, CHEST, HELMET, SHOULDERS, WEAPON }

## The CharacterSprite layer each slot draws on, in the same order as Slot.
const LAYER_NAMES: Array[String] = ["Legs", "Chest", "Helmet", "Shoulders", "Weapon"]

@export var display_name: String = ""
@export var slot: Slot = Slot.CHEST
@export_range(1, 9) var tier: int = 1  ## 1 = Cloth up to 9 = Legendary (see the design doc).
@export var texture: Texture2D


func layer_name() -> String:
	return LAYER_NAMES[slot]
