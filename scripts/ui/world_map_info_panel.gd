class_name WorldMapInfoPanel
extends PanelContainer

@onready var level_name: Label = %LevelName
@onready var region_name: Label = %RegionName

func set_level_name(_level_name: String) -> void:
	level_name.text = _level_name

func set_region(_region_name: String) -> void:
	region_name.text = _region_name
