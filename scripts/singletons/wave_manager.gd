extends Node
# Combines data from EnemySpawner, Base, and PlayerController to determine and propogate wave state

var is_wave_failed: bool
var level_waves: Array[Wave] = []
var active_wave: Wave
var wave_index: int

var wave_index_checkpoint: int

signal wave_started
signal wave_failed
signal wave_completed
signal wave_completed_coin_manager
signal all_waves_completed

func _ready():
	# Connect to EnemySpawner
	EnemySpawner.enemy_died_with_global_pos.connect(on_enemy_died)

func configure_level(active_level: LevelEnvironment) -> void:
	level_waves = active_level.waves
	active_wave = level_waves[0]
	wave_index = 0

	# Connect to current Base
	active_level.base.destroyed.connect(on_wave_failed)

## Intended to be called directly by current `PlayerController`
func start_wave() -> void:
	is_wave_failed = false
	wave_started.emit()

func check_wave_complete(global_pos: Vector2) -> void:
	if EnemySpawner.enemy_index == active_wave.data.size():
		if EnemySpawner.active_enemies.size() == 0:
			if not is_wave_failed and LevelManager.active_level.base.health > 0: # Prevent race-condition between last enemy death and base death
				wave_completed_coin_manager.emit(global_pos, active_wave.reward)
				on_wave_complete()

func on_wave_complete() -> void:
	wave_index += 1
	if wave_index < level_waves.size():
		active_wave = level_waves[wave_index]
	else:
		active_wave = null
		all_waves_completed.emit()
	
	wave_index_checkpoint = wave_index
	wave_completed.emit()

func on_wave_failed() -> void:
	is_wave_failed = true
	wave_index = wave_index_checkpoint
	wave_failed.emit()

func on_enemy_died(global_pos: Vector2) -> void:
	check_wave_complete(global_pos)