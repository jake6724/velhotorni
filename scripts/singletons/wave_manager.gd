extends Node

# Observes signals from EnemySpawner, PlayerController, and Base to determine and propogate Wave state

# TODO: be careful for race condition between tower dying and enemy dying at the same time

var is_wave_failed: bool = false

var level_waves: Array[Wave] = []
var active_wave: Wave
var wave_index: int

signal wave_started
signal wave_failed
signal wave_completed

func _ready():
	# Connect to EnemySpawner
	EnemySpawner.enemy_died.connect(on_enemy_died)

func configure_level(active_level: LevelEnvironment) -> void:
	level_waves = active_level.waves
	active_wave = level_waves[0]
	wave_index = 0

	# Connect to Base for this level
	active_level.base.destroyed.connect(on_wave_failed)

func on_enemy_died() -> void:
	check_wave_complete()

func check_wave_complete() -> void:
	if EnemySpawner.enemy_index == EnemySpawner.active_wave.data.size():
		if EnemySpawner.active_enemies.size() == 0:
			if not is_wave_failed:
				on_wave_complete()

func on_wave_complete() -> void:
	wave_index += 1

	if wave_index < level_waves.size():
		active_wave = level_waves[wave_index]
	else:
		active_wave = null

	wave_completed.emit()

func on_wave_failed() -> void:
	is_wave_failed = true
	wave_failed.emit()