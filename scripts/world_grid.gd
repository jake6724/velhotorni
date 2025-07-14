extends Node

@export var debug: bool = false

var height: int = 25
var width: int = 25

## Should always be indexed with Grid Coordinates
var data: Dictionary[Vector2, bool] # true = can be placed here, false cannot

# Temp for development
var tile_inidicator: PackedScene = preload("res://scenes/placeholders/TileIndicator.tscn")

var active_tilemap: TileMapLayer

var valid_atlas_coords: Array[Vector2i] = [ # Tiles that towers CAN be placed on; defined by tileset atlas coordinates
	Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),Vector2i(6,0),
	Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),Vector2i(6,1),
	Vector2i(0,2),Vector2i(1,2),Vector2i(2,2),
	Vector2i(0,3),Vector2i(1,3),
	Vector2i(0,4),Vector2i(1,4),
	Vector2i(5,7),Vector2i(6,7),
	Vector2i(2,8),Vector2i(3,8),Vector2i(4,8),Vector2i(5,8),Vector2i(6,8),
	Vector2i(0,9),Vector2i(1,9),Vector2i(2,9),Vector2i(3,9),Vector2i(4,9),Vector2i(5,9),
	Vector2i(0,10),Vector2i(1,10),Vector2i(2,10),Vector2i(3,10),Vector2i(4,10),Vector2i(5,10),
	Vector2i(0,11),Vector2i(1,11),Vector2i(2,11),Vector2i(3,11),Vector2i(4,11), Vector2i(5,11),
	Vector2i(0,12),Vector2i(3,12),Vector2i(4,12),Vector2i(5,12),
	Vector2i(3,13),Vector2i(4,13), 
	Vector2i(3,14),Vector2i(4,14),
]


func generate_grid() -> void:
	# Reset values
	data = {}

	for y in range(height):
		for x in range(width):
			var grid_pos = Vector2(x,y)
			var world_pos = GameManager.grid_to_world(grid_pos)
			data[grid_pos] = true

			if debug:
				spawn_placeholder(world_pos)


func configure_tilemap(tilemap: TileMapLayer) -> void:
	active_tilemap = tilemap

	for tile_coords: Vector2i in tilemap.get_used_cells():
		var atlas_coords: Vector2i = tilemap.get_cell_atlas_coords(tile_coords) 
		if atlas_coords in valid_atlas_coords:
			data[Vector2(tile_coords)] = true
		else:
			data[Vector2(tile_coords)] = false 

func spawn_placeholder(pos: Vector2) -> void:
	var p: Sprite2D
	p = tile_inidicator.instantiate()
	p.position = pos
	add_child(p)
