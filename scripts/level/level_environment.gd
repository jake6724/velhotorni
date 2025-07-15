class_name LevelEnvironment
extends Node2D

# # Child References
@onready var enemy_path: Path2D = $EnemyPath 
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var base: Base = $Base

# Export vars
@export var level_name: String
@export var initial_gold: int
@export var waves: Array[Wave]