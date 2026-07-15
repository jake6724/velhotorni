# Singleton responsible for managing and determing the active level
extends Node

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var main_menu_scene: PackedScene = load("res://scenes/MainMenu.tscn")
var main: Main # Reference used to change RoundInfo UI

# var exit_scene: PackedScene = load("res://scenes/level/world_map/WorldMap.tscn") # The scene that 'exit' in menu takes you to

var tower_level: PackedScene = load("uid://dnilok8ickyxd")
var level_1: PackedScene = load("uid://c834s0blo3yw2")
var level_2: PackedScene
var level_3: PackedScene = load("uid://bq1dqq33vdbh2")

var level_environments: Dictionary[LevelTag, PackedScene]

var levels: Array[PackedScene] = [tower_level, level_1, level_2, level_3]

var level_index: int = 3
var active_level: LevelEnvironment

enum LevelTag {TUTORIAL}

func _ready():
	# configure_level() called in main - level only configured when main is ready to parent it
	WaveManager.all_waves_completed.connect(on_level_complete)

## Called by `Main`. Only called when `Main` is ready to parent `active_level`. `LevelManager` 
## triggers the `configure_level()` methods of other singletons here.
func configure_level(_main: Main):
	main = _main # Reference provided by current main itself
	active_level = levels[level_index].instantiate() #TODO get ref from main?

## Observes `WaveManager.all_waves_complete`.
func on_level_complete():
	# Check if full game complete, or move to next level
	if level_index + 1 == levels.size():
		main.round_info.show_game_complete() # TODO: This should go back to world?
	else:
		main.show_level_complete()

	# level_complete_timer.start(level_complete_duration)
	play_level_complete_sfx()

func load_next_level():
	level_index += 1
	SceneTransition.change_scene(main_scene)

func restart_level():
	EnemySpawner.reset()
	WaveManager.reset()
	SceneTransition.change_scene_no_animation(main_scene)

func load_specific_level(_level_environment):
	SceneTransition.change_scene(_level_environment)
	# level_index = levels.find(_level_environment)
	# if level_index != -1:
	# 	SceneTransition.change_scene(main_scene)
	# else:
	# 	push_error("Level not found!")

func load_specific_level_by_level_tag(_level_tag: LevelTag):
	var scene_to_load: PackedScene
	match _level_tag:
		LevelTag.TUTORIAL: scene_to_load = level_1
		_:
			push_error("LevelManager.load_specific_level_by_level_tag(), LevelTag '", _level_tag, "' could not be found.")

	SceneTransition.change_scene(scene_to_load)

# func exit_level() -> void: # TODO: Eventually this should load the tower not the map
# 	EnemySpawner.reset()
# 	WaveManager.reset()
# 	SceneTransition.change_scene(exit_scene)

func complete_game() -> void:
	level_index = 0
	get_tree().change_scene_to_packed(main_menu_scene)

func play_level_complete_sfx() -> void:
	MusicPlayer.fade_out()
	await MusicPlayer.fade_out_complete

	SFXPlayer.play_sfx("victory")
	await SFXPlayer.victory_sfx_complete

	MusicPlayer.fade_in()
	await MusicPlayer.fade_in_complete
