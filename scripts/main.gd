class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var player_controller: PlayerController = %PlayerController

func _ready():
	# Configure with data from LevelManager
	LevelManager.configure_level(self)
	add_child(LevelManager.active_level)

	# Configure other singletons
	WorldGrid.configure_level(LevelManager.active_level)
	EnemySpawner.configure_level(LevelManager.active_level)
	WaveManager.configure_level(LevelManager.active_level)
	TowerGlobalData.reset()

	# Configure PlayerController
	player_controller.setup()

func _input(_event):
	if Input.is_action_just_pressed("escape"):
		pause_game_with_menu()

# TODO: This could go in a TimeManager ? 
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
