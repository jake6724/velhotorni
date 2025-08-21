class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var player_controller: PlayerController = %PlayerController
@onready var coin_drop_manager: CoinDropManager = %CoinDropManager
@onready var camera: Camera2D = $Camera2D
@onready var fps_label: Label = %FPSLabel

var active_level: LevelEnvironment

func _ready():
	# Configure with data from LevelManager
	LevelManager.configure_level(self)
	active_level = LevelManager.active_level
	add_child(active_level)

	# Configure other singletons
	WorldGrid.configure_level(LevelManager.active_level)
	EnemySpawner.configure_level(LevelManager.active_level)
	WaveManager.configure_level(LevelManager.active_level)
	TowerGlobalData.reset()

	# Configure PlayerController
	player_controller.setup()

	# Configure CoinDrop Manager
	EnemySpawner.enemy_spawned_with_ref.connect(coin_drop_manager.on_enemy_spawned)

	# Configure Camera
	active_level.base.damaged.connect(camera.apply_shake)

	# Configure TowerGlobalData
	TowerGlobalData.reset()

# func _process(_delta):
# 	fps_label.text = str(Telemetry.fps)

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