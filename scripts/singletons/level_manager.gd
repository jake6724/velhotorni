# Singleton responsible for managing and determing the active level
extends Node

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var main_menu_scene: PackedScene = load("res://scenes/MainMenu.tscn")
var main: Node2D # Reference used to change RoundInfo UI

var level_tutorial: PackedScene = load("res://scenes/level/LevelEnvironmentTutorial.tscn")
var level_one: PackedScene = load("res://scenes/level/LevelEnvironmentOne.tscn")
var level_two: PackedScene = load("res://scenes/level/LevelEnvironmentTwo.tscn")
var test_level: PackedScene = load("res://scenes/level/LevelEnvironmentTest.tscn")

var levels: Array[PackedScene] = [level_tutorial, level_one, level_two]
var level_index: int = 0
var active_level: LevelEnvironment

var level_complete_timer: Timer = Timer.new()
var level_complete_duration: float = 3
var level_failed: bool = false

var is_wave_failed = false

func _ready():
	# configure_level() called in main - level only configured when main is ready to parent it
	WaveManager.all_waves_completed.connect(on_level_complete)
 
	level_complete_timer.one_shot = true
	level_complete_timer.autostart = false
	level_complete_timer.timeout.connect(on_level_complete_message_finished)
	add_child(level_complete_timer)

## Called by `Main`. Only called when `Main` is ready to parent `active_level`. `LevelManager` 
## triggers the `configure_level()` methods of other singletons here.
func configure_level(_main: Main):
	main = _main # Reference provided by current main itself
	active_level = levels[level_index].instantiate()
	level_failed = false

## Observes `WaveManager.all_waves_complete`.
func on_level_complete():
	level_index += 1
	# Check if full game complete, or move to next level
	if level_index == levels.size():
		main.round_info.show_game_complete()
	else:
		main.round_info.show_level_complete()

	level_complete_timer.start(level_complete_duration)
	play_level_complete_sfx()

## Observes `level_complete_timer.timeout` 
func on_level_complete_message_finished():
	# Exit to main menu if last level
	if level_index == levels.size():
		level_index = 0
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		load_next_level()

func load_next_level():
	# level_index has already been incremented in previous methods which call this one
	get_tree().change_scene_to_packed(main_scene)

func play_level_complete_sfx() -> void:
	MusicPlayer.fade_out()
	await MusicPlayer.fade_out_complete

	SFXPlayer.play_sfx("victory")
	await SFXPlayer.victory_sfx_complete

	MusicPlayer.fade_in()
	await MusicPlayer.fade_in_complete
