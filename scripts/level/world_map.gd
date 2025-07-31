class_name WorldMap
extends Control

@onready var level_buttons: Control = $LevelButtons
@onready var level_name_label: RichTextLabel = $LevelNameLabel

func _ready():
	# Connect to level buttons
	for button: LevelButton in level_buttons.get_children():
		button.level_hovered.connect(on_level_hovered)

func on_level_hovered(_level_name) -> void:
	level_name_label.text = _level_name
 