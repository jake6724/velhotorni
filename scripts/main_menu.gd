class_name MainMenu
extends Control

@onready var start_button: Button = %PlayButton
var main_scene: PackedScene = load("res://scenes/Main.tscn")

func _ready() -> void:
	# Connect to signals
	start_button.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed() -> void:
	SFXPlayer.play_sfx("click_1")
	GameManager.level_index = 0
	GameManager.configure_active_level()
	SceneTransition.change_scene(main_scene)