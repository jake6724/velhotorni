# Singleton responsible for managing and determing the active level
extends Node

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var main_menu_scene: PackedScene = load("res://scenes/MainMenu.tscn")
var main: Main # Reference used to change RoundInfo UI

var tower_level: PackedScene = load("uid://dnilok8ickyxd")
var level_1: PackedScene = load("uid://c834s0blo3yw2")
var level_2: PackedScene = load("uid://b87ndohcw2gmr")
var level_3: PackedScene = load("uid://bq1dqq33vdbh2")
var level_4: PackedScene = load("uid://cql1ddc1e3523")
var levels: Array[PackedScene] = [tower_level, level_1, level_2, level_3, level_4]
var level_index: int = 2
var active_level: LevelEnvironment

var exit_scene: PackedScene = tower_level

func _ready():
	# configure_level() called in main - level only configured when main is ready to parent it
	WaveManager.all_waves_completed.connect(on_level_complete)

## Called by `Main`. Only called when `Main` is ready to parent `active_level`. `LevelManager` 
## triggers the `configure_level()` methods of other singletons here.
func configure_level(_main: Main):
	main = _main # Reference provided by current main itself
	active_level = levels[level_index].instantiate() #TODO get ref from main?

func load_level_from_index(_index: int) -> void:
	EnemySpawner.reset()
	WaveManager.reset()
	level_index = _index
	print("level_index: ", level_index)
	SceneTransition.change_scene(main_scene)

func restart_level():
	EnemySpawner.reset()
	WaveManager.reset()
	SceneTransition.change_scene_no_animation(main_scene)

func exit_level() -> void:
	EnemySpawner.reset()
	WaveManager.reset()
	level_index = 0
	SceneTransition.change_scene(main_scene)

func exit_to_main_menu() -> void:
	EnemySpawner.reset()
	WaveManager.reset()
	SceneTransition.change_scene(main_menu_scene)

## Observes WaveManager.all_waves_complete
func on_level_complete():
	main.show_level_complete()
