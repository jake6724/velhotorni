class_name LevelEnvironment
extends Node2D

enum Region {NONE, TUTORIAL, WIND, EARTH, WATER, FIRE, DARK, LIGHT, FINAL}

# # Child References
@onready var enemy_paths: Array[Path2D] = []
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var level_mask_layer: TileMapLayer = $LevelMaskLayer
@onready var base: Base = $Base
@onready var weather_scroll = $WeatherScroll

@onready var path_parent: Node = $PathParent

# Export vars
@export var level_name: String
@export var region: Region
@export var boss_name: String = "Boss"
@export var initial_gold: int
@export var initial_token: int
@export var waves: Array[Wave]

var stars: int = 1 # Tracks the highest number of stars earned for this level

func _ready():
	tilemap.z_index = Constants.z_index_map["background"]
	level_mask_layer.z_index = Constants.z_index_map["background"]
	weather_scroll.z_index = Constants.z_index_map["weather_scroll"]

	for child in path_parent.get_children():
		if child is Path2D:
			enemy_paths.append(child)
