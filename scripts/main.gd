class_name Main
extends Node2D

@onready var round_info: RoundInfo = $UI/RoundInfo
@onready var pause_menu: PauseMenu = $UI/PauseMenu
@onready var bestiary_menu: BestiaryMenu = $UI/BestiaryMenu
@onready var player_controller: PlayerController = %PlayerController
@onready var player_character: PlayerCharacter = %PlayerCharacter
@onready var coin_drop_manager: CoinDropManager = %CoinDropManager
@onready var pathfinder: PathFinder = %PathFinder

@onready var camera: Camera2D = %PlayerCamera
@onready var fps_label: Label = %FPSLabel
@onready var level_complete_panel: LevelCompletePanel = %LevelCompletePanel

var active_level: LevelEnvironment
var exit_scene: PackedScene = load("res://scenes/level/world_map/WorldMap.tscn") # passed to PauseMenu
var can_pause: bool = false

var wave_failures: int = 0

func _ready():
	SceneTransition.scene_transition_complete.connect(set_can_pause.bind(true))
	# Configure with data from LevelManager
	LevelManager.configure_level(self)
	active_level = LevelManager.active_level
	add_child(active_level)

	# Configure other singletons
	WorldGrid.configure_level(LevelManager.active_level)
	WaveManager.configure_level(LevelManager.active_level)
	EnemySpawner.configure_level(LevelManager.active_level)
	TowerGlobalData.reset()

	# # TODO: DEV ONLY for FLYING ENEMIES
	EnemySpawner.player_character = player_character

	# Configure Enemy Spawner
	EnemySpawner.pathfinder = pathfinder

	# Connect to WaveManager
	WaveManager.wave_failed.connect(on_wave_failed)

	# Configure PlayerController
	player_controller.setup()
	player_controller.bestiary_pressed.connect(pause_game_with_bestiary)
	coin_drop_manager.reward_completed.connect(player_controller.on_reward_complete)
	player_controller.coin_collector = player_character.coin_collector

	# Configure CoinDrop Manager and Coin Collector
	EnemySpawner.enemy_spawned_with_ref.connect(coin_drop_manager.on_enemy_spawned)
	player_controller.coin_collector.reward_collected.connect(coin_drop_manager.decrement_reward_remaining)

	# Configure Camera
	active_level.base.damaged.connect(camera.apply_shake)

	# Configure TowerGlobalData
	TowerGlobalData.reset()

	# Configure PauseMenu
	pause_menu.parent_scene = self
	pause_menu.exit_scene = exit_scene
	pause_menu.restart.show()

	# Configure Bestiary
	bestiary_menu.parent_scene = self
	bestiary_menu.add_entries()
	EnemySpawner.enemy_spawned_with_ref.connect(bestiary_menu.on_enemy_spawned)

	# Configure PathFinder
	pathfinder.initialize()

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

func pause_game_with_bestiary() -> void:
	bestiary_menu.show()
	get_tree().paused = true

func unpause_game_with_bestiary() -> void:
	bestiary_menu.hide()
	get_tree().paused = false

func set_can_pause(value: bool) -> void:
	can_pause = value

func on_wave_failed() -> void:
	wave_failures += 1

func show_level_complete() -> void:
	level_complete_panel.set_stars(calc_stars())
	player_controller.tower_menu.hide()
	level_complete_panel.show()

func calc_stars() -> int:
	var count: int = 2
	if wave_failures == 0:
		count += 1
		if active_level.base.health == 10:
			count += 1
	
	if count > StarRegistry.stars[LevelManager.levels[LevelManager.level_index]]:
		StarRegistry.stars[LevelManager.levels[LevelManager.level_index]] = count

	return count
