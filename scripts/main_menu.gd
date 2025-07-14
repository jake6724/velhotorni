class_name MainMenu
extends Control

@onready var start_button: Button = %PlayButton
@onready var credits_button: Button = %CreditsButton
@onready var tutorial_button: Button = %TutorialButton
var main_scene: PackedScene = load("res://scenes/Main.tscn")

func _ready() -> void:
	# Connect to signals
	start_button.pressed.connect(_on_play_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)

func _on_play_button_pressed() -> void:
	GameManager.level_index = 2
	GameManager.configure_active_level()
	SceneTransition.change_scene(main_scene)
	

func _on_tutorial_button_pressed() ->void :
	GameManager.level_index = 0
	GameManager.configure_active_level()
	SceneTransition.change_scene(main_scene)

func _on_credits_button_pressed() -> void:
	$Credits.show()
	hide()

func _on_go_back_button_pressed() -> void:
	$Credits.hide()
	$MainMenu.show()
