class_name MainMenu
extends Control

@onready var start_button: Button = %PlayButton
var main_scene: PackedScene = load("res://scenes/Main.tscn")
var world_map: PackedScene = preload("res://scenes/level/world_map/WorldMap.tscn")

func _ready() -> void:
	# Connect to signals
	start_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed() -> void:
	SceneTransition.change_scene(world_map)
	SFXPlayer.play_sfx("click_1")