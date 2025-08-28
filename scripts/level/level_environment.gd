class_name LevelEnvironment
extends Node2D

enum Region {NONE, TUTORIAL, WIND, EARTH, WATER, FIRE, DARK, LIGHT, FINAL}

# # Child References
@onready var enemy_path: Path2D = $EnemyPath 
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var level_mask_layer: TileMapLayer = $LevelMaskLayer
@onready var base: Base = $Base

# Export vars
@export var level_name: String
@export var region: Region
@export var initial_gold: int
@export var initial_token: int
@export var waves: Array[Wave]

var stars: int = 1 # Tracks the highest number of stars earned for this level
