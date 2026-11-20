extends SceneTree
## Builds the tile resources for the Hollow Throne from art/tiles/textures_16.png:
##   tiles/textures_16_tileset.tres        TileSet: every non-empty 16x16 tile; wall tiles are solid
##   scenes/rooms/hollow_throne_tiles.tscn Floor + Walls TileMapLayers for the first room
## Run once (it overwrites both files):
##   godot --headless --path . --script res://tools/build_hollow_throne_tiles.gd
## After that you can paint the room by hand in the editor instead.

const SHEET := "res://art/tiles/textures_16.png"
const TILESET_PATH := "res://tiles/textures_16_tileset.tres"
const ROOM_PATH := "res://scenes/rooms/hollow_throne_tiles.tscn"

# Atlas coordinates (column, row) in textures_16.png.
const FLOOR := Vector2i(9, 1)                                  # Dark slate cobbles.
const FLOOR_VARIANTS: Array[Vector2i] = [Vector2i(8, 1), Vector2i(10, 1), Vector2i(11, 1)]
const CORRIDOR_FLOOR := Vector2i(13, 10)                       # Darker ship plating.
const WALL := Vector2i(1, 4)                                   # Navy brick.
const PILLAR := Vector2i(7, 4)                                 # Pale stone blocks.
const SOLID: Array[Vector2i] = [
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(5, 4),
	Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 4),
]

# Room layout in tile coordinates (tile (0, 0) covers pixels 0..16).
const INTERIOR := Rect2i(-25, -16, 50, 32)        # Pixels -400..400 by -256..256.
const DOOR_COLUMNS := Vector2i(-3, 2)              # Gap in the north wall (pixels -48..48).
const CORRIDOR := Rect2i(-3, -23, 6, 6)            # Corridor floor north of the door.
const PILLARS: Array[Rect2i] = [Rect2i(-13, -4, 2, 2), Rect2i(11, -4, 2, 2)]


func _initialize() -> void:
	var tileset := _build_tileset()
	var err := ResourceSaver.save(tileset, TILESET_PATH)
	print("tileset saved: ", error_string(err))
	var room := _build_room(load(TILESET_PATH) as TileSet)
	var packed := PackedScene.new()
	packed.pack(room)
	err = ResourceSaver.save(packed, ROOM_PATH)
	print("room saved: ", error_string(err))
	room.free()
	quit()


func _build_tileset() -> TileSet:
	var texture := load(SHEET) as Texture2D
	var image := texture.get_image()
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(16, 16)
	tileset.add_source(source, 0)
	var count := 0
	for y in image.get_height() / 16:
		for x in image.get_width() / 16:
			if image.get_region(Rect2i(x * 16, y * 16, 16, 16)).is_invisible():
				continue
			source.create_tile(Vector2i(x, y))
			count += 1
	var square := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
	for coords in SOLID:
		var data := source.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, square)
	print("tiles: ", count, " (", SOLID.size(), " solid)")
	return tileset


func _build_room(tileset: TileSet) -> Node2D:
	var root := Node2D.new()
	root.name = "RoomTiles"
	var floor_layer := TileMapLayer.new()
	floor_layer.name = "Floor"
	floor_layer.tile_set = tileset
	floor_layer.z_index = -10
	var walls := TileMapLayer.new()
	walls.name = "Walls"
	walls.tile_set = tileset
	for layer in [floor_layer, walls]:
		root.add_child(layer)
		layer.owner = root

	var rng := RandomNumberGenerator.new()
	rng.seed = 7   # Same "random" floor every time the tool runs.
	for y in range(INTERIOR.position.y, INTERIOR.end.y):
		for x in range(INTERIOR.position.x, INTERIOR.end.x):
			var tile := FLOOR
			if rng.randf() < 0.2:
				tile = FLOOR_VARIANTS[rng.randi() % FLOOR_VARIANTS.size()]
			floor_layer.set_cell(Vector2i(x, y), 0, tile)
	for y in range(CORRIDOR.position.y, CORRIDOR.end.y + 1):   # +1: under the doorway too.
		for x in range(CORRIDOR.position.x, CORRIDOR.end.x):
			floor_layer.set_cell(Vector2i(x, y), 0, CORRIDOR_FLOOR)

	# Outer walls, leaving the doorway open (a Door node closes it until the room is cleared).
	var left := INTERIOR.position.x - 1
	var right := INTERIOR.end.x
	var top := INTERIOR.position.y - 1
	var bottom := INTERIOR.end.y
	for x in range(left, right + 1):
		if x < DOOR_COLUMNS.x or x > DOOR_COLUMNS.y:
			walls.set_cell(Vector2i(x, top), 0, WALL)
		walls.set_cell(Vector2i(x, bottom), 0, WALL)
	for y in range(top, bottom + 1):
		walls.set_cell(Vector2i(left, y), 0, WALL)
		walls.set_cell(Vector2i(right, y), 0, WALL)
	# Corridor sides and end.
	for y in range(CORRIDOR.position.y - 1, top):
		walls.set_cell(Vector2i(CORRIDOR.position.x - 1, y), 0, WALL)
		walls.set_cell(Vector2i(CORRIDOR.end.x, y), 0, WALL)
	for x in range(CORRIDOR.position.x - 1, CORRIDOR.end.x + 1):
		walls.set_cell(Vector2i(x, CORRIDOR.position.y - 1), 0, WALL)
	for pillar in PILLARS:
		for y in range(pillar.position.y, pillar.end.y):
			for x in range(pillar.position.x, pillar.end.x):
				walls.set_cell(Vector2i(x, y), 0, PILLAR)
	return root
