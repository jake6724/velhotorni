class_name RoundInfo
extends Control

@onready var level_label: Label = %LevelLabel
@onready var wave_label: Label = %WaveLabel

func show_level_complete():
	level_label.show()
	level_label.text = "Level Complete!"

func show_game_complete():
	level_label.show()
	level_label.text = "You win!"
