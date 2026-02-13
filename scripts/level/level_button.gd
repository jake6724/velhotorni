class_name LevelButton
extends Button

@onready var star: TextureRect = %Star

@export var level_scene: PackedScene
var level_name: String
var region_name: String

var stars: int

signal level_hovered
signal level_unhovered
signal level_button_pressed

func _ready():
	pressed.connect(on_pressed)
	mouse_entered.connect(on_mouse_hovered)
	mouse_exited.connect(on_mouse_unhovered)

	var state = level_scene.get_state()
	for node_idx in range(state.get_node_count()):
		for prop_idx in range(state.get_node_property_count(node_idx)):
			var prop_name = state.get_node_property_name(node_idx, prop_idx)
			var prop_value = state.get_node_property_value(node_idx, prop_idx)

			if prop_name == "level_name":
				level_name = prop_value

			if prop_name == "region":
				match prop_value:
					LevelEnvironment.Region.TUTORIAL: region_name = "Shores"
					LevelEnvironment.Region.WIND: region_name = "Meadowlands"
					LevelEnvironment.Region.EARTH: region_name = "Great Forest"
					LevelEnvironment.Region.WATER: region_name = "ICE Mountain"
					LevelEnvironment.Region.FIRE: region_name = "Lava Caverns"
					LevelEnvironment.Region.DARK: region_name = "Corrupt"
					LevelEnvironment.Region.LIGHT: region_name = "The Holy City"
					LevelEnvironment.Region.FINAL: region_name = "Chaos Realm"
					_: pass

	set_star()

func set_star() -> void:
	var count: int = StarRegistry.stars[level_scene]
	stars = count
	var x: int = count * 16
	star.texture.region = Rect2(x, 0, 16, 16)

func on_pressed() -> void:
	if stars > 0:
		level_button_pressed.emit(level_scene)

func on_mouse_hovered() -> void: 
	level_hovered.emit(level_name, region_name)

func on_mouse_unhovered() -> void:
	level_unhovered.emit()
