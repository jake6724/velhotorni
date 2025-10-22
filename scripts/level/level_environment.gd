class_name LevelEnvironment
extends Node2D

enum Region {NONE, TUTORIAL, WIND, EARTH, WATER, FIRE, DARK, LIGHT, FINAL}

# # Child References
# @onready var tilemap: TileMapLayer = $TileMapLayer
@onready var level_mask_layer: TileMapLayer = $LevelMaskLayer
@onready var base: Base = $Base
@onready var weather_scroll = $WeatherScroll

@onready var path_parent: Node = $PathParent
@onready var enemy_paths: Array[Path2D] = []
@onready var portal_parent: Node = $PortalParent
@onready var enemy_portals: Array[EnemyPortal] = []

@onready var flying_spawn_parent: Node = $FlyingSpawnParent
@onready var flying_spawn_points: Array[Vector2] = []

@onready var player_spawn_point = %PlayerSpawnPoint
@onready var tower_mana_breakables_parent: Node = %TowerManaBreakablesParent
var tower_mana_breakables: Array[Breakable] = []

# Export vars
@export var level_name: String
@export var region: Region
@export var boss_name: String = "Boss"
@export var initial_gold: int
@export var initial_token: int
@export var waves: Array[Wave]
@export var max_towers: int = 10

var stars: int = 1 # Tracks the highest number of stars earned for this level

func _ready():
	""" *** Z INDEXES ARE NOW PAINTED IN THE TILESET ITSELF *** """
	# tilemap.z_index = Constants.z_index_map["bg"]
	# level_mask_layer.z_index = Constants.z_index_map["bg"]
	weather_scroll.z_index = Constants.z_index_map["weather_scroll"]

	for child in path_parent.get_children():
		if child is Path2D:
			enemy_paths.append(child)

	for child in portal_parent.get_children():
		if child is EnemyPortal:
			enemy_portals.append(child)

	for child in flying_spawn_parent.get_children():
		if child is Node2D:
			flying_spawn_points.append(child.global_position)

	configure_tower_mana_breakables()

func configure_tower_mana_breakables() -> void:
	for child: Breakable in tower_mana_breakables_parent.get_children():
		tower_mana_breakables.append(child)

# # Set the `z_index` of each tile based on its `z_index_map_key` custom data value. This value is painted onto
# # the tile in the editor.
# func set_tilemap_z_indexes() -> void:
# 	for tile_index: Vector2i in tilemap.get_used_cells():
# 		var tile_data: TileData = tilemap.get_cell_tile_data(tile_index)
# 		if tile_data:
# 			tilemap.set_cell_
# 			tile_data.z_index = Constants.z_index_map[tile_data.get_custom_data("z_index_map_key")]
