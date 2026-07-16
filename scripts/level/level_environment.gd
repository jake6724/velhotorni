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

@onready var boss_spawn_point = %BossSpawnPoint

@onready var wave_info_panel_parent: Node = %WaveInfoPanelParent

@onready var tall_grass_parent: Node2D = %TallGrassParent

# Export vars
@export var level_name: String
@export var region: Region
@export var boss_name: String = "Boss"
@export var initial_gold: int
@export var initial_token: int
@export var waves: Array[Wave]
@export var max_towers: int = 10
@export var music_data: MusicData
@export var show_pause_menu_restart: bool = true
@export var minimap_camera_marker: Marker2D
@export var exits_to_main_menu: bool = false

@export var start_first_wave_immediately: bool = false

# Can prevent wave banner, path alerts
@export var show_level_details: bool = true

var stars: int = 1 # Tracks the highest number of stars earned for this level
var can_start_wave: bool = true # Used so that levels can disable wave start, specifically in the tutorial

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
	configure_wave_info_panels()

	WaveManager.wave_completed.connect(populate_wave_info_panels)
	WaveManager.wave_started.connect(hide_wave_info_panels)
	WaveManager.wave_started.connect(on_wave_started_start_breakables)

	child_custom_ready()

## Allows for inheriting classes to extends _ready()'s functionality (such as TutorialLevelEnvironment)
## Called as the final step of _ready()
func child_custom_ready() -> void:
	pass

func configure_tower_mana_breakables() -> void:
	for child: Breakable in tower_mana_breakables_parent.get_children():
		tower_mana_breakables.append(child)

func on_wave_started_start_breakables() -> void:
	for breakable: Breakable in tower_mana_breakables:
		breakable.start_grow()

func configure_wave_info_panels() -> void:
	for child in wave_info_panel_parent.get_children():
		var wave_info_panel: WaveInfoPanel = child as WaveInfoPanel
		if wave_info_panel:
			wave_info_panel.first_activation = true
			wave_info_panel.get_path_enemy_info(self)

	populate_wave_info_panels()

func populate_wave_info_panels() -> void:
	for child in wave_info_panel_parent.get_children():
		var wave_info: WaveInfoPanel = child as WaveInfoPanel
		if wave_info:
			wave_info.populate_unit_wave_info(WaveManager.wave_index, show_level_details)

func hide_wave_info_panels() -> void:
	for child in wave_info_panel_parent.get_children():
		var wave_info: WaveInfoPanel = child as WaveInfoPanel
		if wave_info:
			wave_info.hide()

# # Set the `z_index` of each tile based on its `z_index_map_key` custom data value. This value is painted onto
# # the tile in the editor.
# func set_tilemap_z_indexes() -> void:
# 	for tile_index: Vector2i in tilemap.get_used_cells():
# 		var tile_data: TileData = tilemap.get_cell_tile_data(tile_index)
# 		if tile_data:
# 			tilemap.set_cell_
# 			tile_data.z_index = Constants.z_index_map[tile_data.get_custom_data("z_index_map_key")]
