class_name LevelInfoPanel
extends PanelContainer

@onready var level_name_label: Label = %LevelNameLabel
@onready var biome_label: Label  = %BiomeLabel

func set_level_name(_level_name: String) -> void:
	level_name_label.text = _level_name