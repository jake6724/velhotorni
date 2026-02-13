class_name WorldMapInfoPanel
extends PanelContainer

@export var slide_pos: Vector2

@onready var level_name: Label = %LevelName
@onready var region_name: Label = %RegionName

@onready var star_1: TextureRect = %Star1
@onready var star_2: TextureRect = %Star2
@onready var star_3: TextureRect = %Star3

var stars: Array[TextureRect] = []

var original_pos: Vector2


func _ready():
	original_pos = global_position
	stars = [star_1, star_2, star_3]

func set_level_name(_level_name: String) -> void:
	level_name.text = _level_name

func set_region(_region_name: String) -> void:
	region_name.text = _region_name

func set_stars(count: int) -> void:

	for star: TextureRect in stars:
		star.texture.region = Rect2(0,0,16,16)

	for i in range(count-1):
		stars[i].texture.region = Rect2(16,0,16,16)