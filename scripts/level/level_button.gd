class_name LevelButton
extends Button

@export var level_scene: PackedScene
var level_name: String

signal level_hovered

func _ready():
	pressed.connect(on_pressed)
	mouse_entered.connect(on_mouse_hovered)

	var state = level_scene.get_state()
	for node_idx in range(state.get_node_count()):
		for prop_idx in range(state.get_node_property_count(node_idx)):
			var prop_name = state.get_node_property_name(node_idx, prop_idx)
			var prop_value = state.get_node_property_value(node_idx, prop_idx)

			if prop_name == "level_name":
				level_name = prop_value

func on_pressed() -> void:
	LevelManager.load_specific_level(level_scene)

func on_mouse_hovered() -> void: 
	level_hovered.emit(level_name)