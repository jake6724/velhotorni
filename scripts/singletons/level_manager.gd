# Singleton responsible for managing and determing the active level
extends Node

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var main_menu_scene: PackedScene = load("res://scenes/MainMenu.tscn")
var main: Node2D # Reference used to change RoundInfo UI

#res://scenes/level/2_earth/Level5.tscn

var level_0: PackedScene = load("res://scenes/level/0_tutorial/Level0.tscn")
var level_1: PackedScene = load("res://scenes/level/1_wind/Level1.tscn")
var level_2: PackedScene = load("res://scenes/level/1_wind/Level2.tscn")
var level_3a: PackedScene = load("res://scenes/level/1_wind/Level3A.tscn")
var level_3b: PackedScene = load("res://scenes/level/1_wind/Level3B.tscn")
var level_4: PackedScene = load("res://scenes/level/2_earth/Level4.tscn")
var level_5: PackedScene = load("res://scenes/level/2_earth/Level5.tscn")
var level_6a: PackedScene = load("res://scenes/level/2_earth/Level6A.tscn")
var level_6b: PackedScene = load("res://scenes/level/2_earth/Level6B.tscn")
var level_7: PackedScene = load("res://scenes/level/3_water/Level7.tscn")
var level_8: PackedScene = load("res://scenes/level/3_water/Level8.tscn")
var level_9a: PackedScene = load("res://scenes/level/3_water/Level9A.tscn")
var level_9b: PackedScene = load("res://scenes/level/3_water/Level9B.tscn")
var level_10: PackedScene = load("res://scenes/level/4_fire/Level10.tscn")
var level_11: PackedScene = load("res://scenes/level/4_fire/Level11.tscn")
var level_12a: PackedScene = load("res://scenes/level/4_fire/Level12A.tscn")
var level_12b: PackedScene = load("res://scenes/level/4_fire/Level12B.tscn")
var level_13: PackedScene = load("res://scenes/level/5_dark/Level13.tscn")
var level_14: PackedScene = load("res://scenes/level/5_dark/Level14.tscn")
var level_15a: PackedScene = load("res://scenes/level/5_dark/Level15A.tscn")
var level_15b: PackedScene = load("res://scenes/level/5_dark/Level15B.tscn")
var level_16: PackedScene = load("res://scenes/level/6_light/Level16.tscn")
var level_17: PackedScene = load("res://scenes/level/6_light/Level17.tscn")
var level_18a: PackedScene = load("res://scenes/level/6_light/Level18A.tscn")
var level_18b: PackedScene = load("res://scenes/level/6_light/Level18B.tscn")
var level_19: PackedScene = load("res://scenes/level/7_final/Level19.tscn")
var level_20: PackedScene = load("res://scenes/level/7_final/Level20.tscn")
var level_21: PackedScene = load("res://scenes/level/7_final/Level21.tscn")
var level_22: PackedScene = load("res://scenes/level/7_final/Level22.tscn")

var levels: Array[PackedScene] = [level_0, level_1, level_2, level_3a, level_3b, level_4, level_5, level_6a, level_6b, 
level_7, level_8, level_9a, level_9b, level_10, level_11, level_12a, level_12b, level_13, level_14, level_15a, level_15b, 
level_16, level_17, level_18a, level_18b, level_19, level_20, level_21, level_22]
var level_index: int = 5
var active_level: LevelEnvironment

var level_complete_timer: Timer = Timer.new()
var level_complete_duration: float = 3
var level_failed: bool = false

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
	# Check if full game complete, or move to next level
	if level_index + 1 == levels.size():
		main.round_info.show_game_complete()
	else:
		main.round_info.show_level_complete()

	level_complete_timer.start(level_complete_duration)
	play_level_complete_sfx()

## Observes `level_complete_timer.timeout` 
func on_level_complete_message_finished():
	# Exit to main menu if last level
	if level_index + 1 == levels.size():
		complete_game()
	else:
		load_next_level()

func load_next_level():
	level_index += 1
	SceneTransition.change_scene(main_scene)

func restart_level():
	WaveManager.wave_failed.emit() # Ensure enemies are cleared
	SceneTransition.change_scene(main_scene)

func load_specific_level(_level_environment):
	level_index = levels.find(_level_environment)
	print(level_index)
	if level_index != -1:
		# level_index = _level_index
		SceneTransition.change_scene(main_scene)

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
