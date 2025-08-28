class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var player_controller: PlayerController = %PlayerController
@onready var coin_drop_manager: CoinDropManager = %CoinDropManager
@onready var camera: Camera2D = $Camera2D
@onready var fps_label: Label = %FPSLabel

var active_level: LevelEnvironment

var can_pause: bool = false

func _ready():
	SceneTransition.scene_transition_complete.connect(set_can_pause.bind(true))
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
	coin_drop_manager.reward_completed.connect(player_controller.on_reward_complete)

	# Configure CoinDrop Manager and Coin Collector
	EnemySpawner.enemy_spawned_with_ref.connect(coin_drop_manager.on_enemy_spawned)
	player_controller.coin_collector.reward_collected.connect(coin_drop_manager.decrement_reward_remaining)

	# Configure Camera
	active_level.base.damaged.connect(camera.apply_shake)

	# Configure TowerGlobalData
	TowerGlobalData.reset()

	# Configure PauseMenu
	pause_menu.parent_scene = self
	pause_menu.restart.show()

func _input(_event):
	if Input.is_action_just_pressed("escape"): # TODO: Input action change
		if can_pause and not player_controller.menu_open:
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

func set_can_pause(value: bool) -> void:
	can_pause = value