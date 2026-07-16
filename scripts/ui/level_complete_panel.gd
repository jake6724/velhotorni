class_name LevelCompletePanel
extends NinePatchRect

@onready var star_1: TextureRect = %Star1
@onready var star_2: TextureRect = %Star2
@onready var star_3: TextureRect = %Star3
@onready var world_map: NinePatchRect = %WorldMap
@onready var next_level: NinePatchRect = %NextLevel
@onready var world_map_button: Button = %WorldMapButton
@onready var next_level_button: Button = %NextLevelButton
var stars: Array[TextureRect] = []
# var world_map_scene: PackedScene = load("res://scenes/level/world_map/WorldMap.tscn")

func _ready():
	# world_map_button.pressed.connect(on_world_map_button_pressed)
	next_level_button.pressed.connect(on_next_level_button_pressed)
	stars = [star_1, star_2, star_3]

	world_map_button.mouse_entered.connect(highlight_ui_element.bind(world_map))
	world_map_button.mouse_exited.connect(un_highlight_ui_element.bind(world_map))
	next_level_button.mouse_entered.connect(highlight_ui_element.bind(next_level))
	next_level_button.mouse_exited.connect(un_highlight_ui_element.bind(next_level))

func set_stars(count: int) -> void:
	count -= 1 # offset 
	for star:TextureRect in stars:
		star.texture.region = Rect2(0, 0, 16, 16)

	for i in range(count):
		stars[i].texture.region = Rect2(16, 0, 16, 16)

# func on_world_map_button_pressed() -> void:
# 	SceneTransition.change_scene(world_map_scene)

func on_next_level_button_pressed() -> void:
	LevelManager.exit_level()

func highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color(Constants.ui_color_select)

func un_highlight_ui_element(ui_element: Control) -> void:
	ui_element.self_modulate = Color.WHITE
