# Autoloader
extends Node

var main_scene: PackedScene = load("res://scenes/Main.tscn")
var main_menu_scene: PackedScene = load("res://scenes/MainMenu.tscn")
var main: Node2D

var level_tutorial: PackedScene = load("res://scenes/level/LevelEnvironmentTutorial.tscn")
var level_one: PackedScene = load("res://scenes/level/LevelEnvironmentOne.tscn")
var level_two: PackedScene = load("res://scenes/level/LevelEnvironmentTwo.tscn")
var test_level: PackedScene = load("res://scenes/level/LevelEnvironmentTest.tscn")

var levels: Array[PackedScene] = [level_tutorial, level_one, level_two]

var level_index: int = 0
var active_level: LevelEnvironment
var active_path: PackedVector2Array
var active_spawn_location: Vector2 # In world coordinates

var level_complete_timer: Timer = Timer.new()
var level_complete_duration: float = 3
var level_failed: bool = false

# var base: Base

# # Wave checkpoint data
# var checkpoint_gold: int
# var checkpoint_wave_index: int
# var checkpoint_active_towers: Array[Tower]
# var checkpoint_base_health: int

var is_wave_failed = false

signal wave_failed

func _ready():
	# configure_level() called in main - level only configured when main is ready to parent it
	EnemySpawner.level_complete.connect(on_level_complete)

	level_complete_timer.one_shot = true
	level_complete_timer.autostart = false
	level_complete_timer.timeout.connect(on_level_complete_message_finished)
	add_child(level_complete_timer)

func configure_level():
	# # Base stuff
	# base = active_level.base # TODO: this all needs to move out and the bug will fix (maybe level env. tracks it?)
	# base.base_destroyed.connect(on_wave_failed)
	# checkpoint_base_health = base.max_health

	active_level = levels[level_index].instantiate()

	# Call other singleton's configure_level() methods
	WorldGrid.configure_level(active_level)
	EnemySpawner.configure_level(active_level)

	# Level data
	level_failed = false

func start_level(): # TODO: could this just be configure level ? is this really needed?
	# Reset autoloaders
	clear_level()

	# Instantiate a new level scene - will become a child of Main
	active_level = levels[level_index].instantiate()

	# Reset Main Scene - this will trigger configure_level()
	get_tree().change_scene_to_packed(main_scene)

func clear_level():
	active_level = null
	active_path = []
	active_spawn_location = Vector2()
	# base.base_destroyed.disconnect(on_wave_failed)
	# base = null
	EnemySpawner.clear_level()

func on_level_complete(): # Emitted by EnemySpawner
	level_index += 1
	if level_index == levels.size():
		main.round_info.show_game_complete()
	else:
		main.round_info.show_level_complete()

	level_complete_timer.start(level_complete_duration)

	MusicPlayer.fade_out()
	await MusicPlayer.fade_out_complete

	SFXPlayer.play_sfx("victory")
	await SFXPlayer.victory_sfx_complete

	MusicPlayer.fade_in()
	await MusicPlayer.fade_in_complete

func on_level_complete_message_finished():
	# Exit to main menu if last level
	if level_index == levels.size():
		clear_level()
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		start_level()

func on_wave_failed()-> void:
	is_wave_failed = true
	EnemySpawner.on_wave_failed() # Called manually to avoid race-conditions with PlayerController

	# base.health = checkpoint_base_health
	# base.update_health_label(base.health) # TODO: Use set()
	wave_failed.emit()
	is_wave_failed = false

# func set_checkpoint_base_health() -> void:
# 	checkpoint_base_health = base.health
