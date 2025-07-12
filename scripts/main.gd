class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu

func _ready():
	GameManager.configure_level()

func _input(_event):
	if Input.is_action_just_pressed("escape"):
		pause_game_with_menu()

func pause_game():
	get_tree().paused = true

func unpause_game():
	get_tree().paused = false

func pause_game_with_menu():
	pause_menu.show()
	get_tree().paused = true

func unpause_game_with_menu():
	pause_menu.hide()
	get_tree().paused = false
