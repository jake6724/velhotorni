extends Node

@export var debug: bool = false

enum TileType {OCCUPIED, UNOCCUPIED, PATH}

var dimensions: Vector2i 

## Should always be indexed with Grid Coordinate
var data: Dictionary[Vector2, TileType] # true = unoccupied
var data_valid_points: Array[Vector2]

# Dev only
var tile_inidicator: PackedScene = preload("res://scenes/placeholders/TileIndicator.tscn")
var active_tilemap: TileMapLayer
var valid_atlas_coords: Array[Vector2i] = [Vector2i(2,0)] # Green tiles in atl_level_mask
var traversable_coords: Array[Vector2i] = [Vector2i(1,0)] # Any tiles that can be traversed, and are NOT green tiles

## Intended to be called manually by `LevelManager`.
func configure_level(active_level: LevelEnvironment) -> void:
	generate_grid(active_level.level_mask_layer)
	configure_tilemap(active_level.level_mask_layer)

func generate_grid(tilemap: TileMapLayer) -> void:
	# Reset values between loading level
	data = {}
	dimensions = tilemap.get_used_rect().size

	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var grid_pos = Vector2(x,y)
			var world_pos = WorldGrid.grid_to_world(grid_pos)
			data[grid_pos] = TileType.UNOCCUPIED

			if debug:
				spawn_placeholder(world_pos)

func configure_tilemap(tilemap: TileMapLayer) -> void:
	active_tilemap = tilemap # This is the levelmask layer

	for tile_coords: Vector2i in active_tilemap.get_used_cells():
		var atlas_coords: Vector2i = active_tilemap.get_cell_atlas_coords(tile_coords) 
		if atlas_coords in valid_atlas_coords:
			data[Vector2(tile_coords)] = TileType.UNOCCUPIED
			data_valid_points.append(Vector2(tile_coords))
			#spawn_placeholder(grid_to_world(tile_coords))

		elif atlas_coords in traversable_coords:
			data[Vector2(tile_coords)] = TileType.PATH
			#spawn_placeholder(grid_to_world(tile_coords))

		else:
			data[Vector2(tile_coords)] = TileType.OCCUPIED

func spawn_placeholder(pos: Vector2) -> void:
	var p: Sprite2D
	p = tile_inidicator.instantiate()
	p.position = pos
	add_child(p)

func grid_to_world(_pos: Vector2) -> Vector2:
	return _pos * Constants.CELL_SIZE

func world_to_grid(_pos: Vector2) -> Vector2:
	return floor(_pos / Constants.CELL_SIZE)

func get_closest_valid_point(_global_pos: Vector2) -> Vector2: # TODO: Potentially to expensive, as used in coin_drop_manager.gd
	var min_distance: float = INF
	var closest_point: Vector2
	for point in data_valid_points:
		point = grid_to_world(point)
		var distance: float = _global_pos.distance_squared_to(point)
		if distance < min_distance:
			closest_point = point
			min_distance = distance
	return closest_point
