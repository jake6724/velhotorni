class_name WorldMap
extends Node2D

@onready var level_buttons: Control = %LevelButtons
@onready var left_world_map_info_panel: WorldMapInfoPanel = %LeftWorldMapInfoPanel
@onready var right_world_map_info_panel: WorldMapInfoPanel = %RightWorldMapInfoPanel

func _ready():
	# Connect to level buttons
	for button: LevelButton in level_buttons.get_children():
		button.level_hovered.connect(on_level_hovered)

func on_level_hovered(_level_name: String, _region_name: String) -> void:
	left_world_map_info_panel.set_level_name(_level_name)
	right_world_map_info_panel.set_region(_region_name)
