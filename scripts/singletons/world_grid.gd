extends Node

@export var debug: bool = false

var height: int = 25
var width: int = 25

## Should always be indexed with Grid Coordinates
var data: Dictionary[Vector2, bool] # true = can be placed here, false cannot

# Dev only
var tile_inidicator: PackedScene = preload("res://scenes/placeholders/TileIndicator.tscn")

var active_tilemap: TileMapLayer

var valid_atlas_coords: Array[Vector2i] = [Vector2i(2,0)] # Green tiles in atl_level_mask

## Intended to be called manually by `LevelManager`.
func configure_level(active_level: LevelEnvironment) -> void:
	generate_grid()
	configure_tilemap(active_level.level_mask_layer)

func generate_grid() -> void:
	# Reset values
	data = {}

	for y in range(height):
		for x in range(width):
			var grid_pos = Vector2(x,y)
			var world_pos = WorldGrid.grid_to_world(grid_pos)
			data[grid_pos] = true

			if debug:
				spawn_placeholder(world_pos)

func configure_tilemap(tilemap: TileMapLayer) -> void:
	active_tilemap = tilemap

	for tile_coords: Vector2i in active_tilemap.get_used_cells():
		var atlas_coords: Vector2i = active_tilemap.get_cell_atlas_coords(tile_coords) 
		if atlas_coords in valid_atlas_coords:
			data[Vector2(tile_coords)] = true
		else:
			data[Vector2(tile_coords)] = false 

func spawn_placeholder(pos: Vector2) -> void:
	var p: Sprite2D
	p = tile_inidicator.instantiate()
	p.position = pos
	add_child(p)

func grid_to_world(_pos: Vector2) -> Vector2:
	return _pos * Constants.CELL_SIZE

func world_to_grid(_pos: Vector2) -> Vector2:
	return floor(_pos / Constants.CELL_SIZE)
