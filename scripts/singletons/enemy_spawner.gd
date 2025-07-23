# TODO: This should maybe not a be a singleton... just a child of main? 

# Singleton responsible for spawning enemies based on the active level's wave data
# All enemies are a child of this class
extends Node

var active_enemies: Array[Enemy]
var enemy_index: int
var can_spawn_enemy: bool
var enemy_path_length: float # Per level
var spawn_timer: Timer = Timer.new()

var enemy_scene: PackedScene = preload("res://scenes/enemies/Enemy.tscn")
var enemy_data: Dictionary[Constants.Element, EnemyData] = {
	Constants.Element.FIRE: preload("res://data/enemies/enemy_data_fire_ghoul.tres"),
	Constants.Element.WIND: preload("res://data/enemies/enemy_data_wind_ghoul.tres"),
	Constants.Element.WATER: preload("res://data/enemies/enemy_data_water_ghoul.tres"),}

# Signals
signal enemy_spawned
signal enemy_died

func _ready():
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Connect to WaveManager
	WaveManager.wave_started.connect(start_wave)
	WaveManager.wave_completed.connect(reset)
	WaveManager.wave_failed.connect(reset)
	WaveManager.all_waves_completed.connect(reset)

## Called by LevelManager.
func configure_level(active_level: LevelEnvironment):
	active_enemies = []
	enemy_index = 0
	can_spawn_enemy = false
	enemy_path_length = active_level.enemy_path.curve.get_baked_length()
	
## Intended to be triggered directly by `player_controller`.
func start_wave() -> void:
	can_spawn_enemy = true
	on_spawn_timer_timeout()

## Called when a wave is completed or failed.
func reset() -> void:
	remove_all_enemies()
	active_enemies = []
	enemy_index = 0
	can_spawn_enemy = false
	spawn_timer.stop()

## Triggered when an `Enemy` child dies and emits their `died` signal.
func on_enemy_died(enemy: Enemy) -> void:
	var index = active_enemies.find(enemy)
	if index != -1:
		active_enemies.remove_at(index)
	enemy_died.emit()

## Called on `spawn_timer`'s `timeout`
func on_spawn_timer_timeout() -> void:
	if WaveManager.active_wave:
		if can_spawn_enemy and enemy_index < WaveManager.active_wave.data.size():
			var spawn_data: EnemyData = WaveManager.active_wave.data[enemy_index].enemy_data
			var spawn_delay: float = WaveManager.active_wave.data[enemy_index].delay

			spawn_enemy(spawn_data)
			enemy_index += 1

			# Restart spawn timer
			spawn_timer.start(spawn_delay)

func spawn_enemy(_enemy_data: EnemyData) -> void:
	# Configure new enemy
	var new_enemy: Enemy = enemy_scene.instantiate()
	new_enemy.data = _enemy_data
	# new_enemy.data = enemy_data[element]
	# new_enemy.position = LevelManager.active_spawn_location
	new_enemy.died.connect(on_enemy_died)
	add_child(new_enemy)
	active_enemies.append(new_enemy)

	configure_enemy_pathing(new_enemy)
	enemy_spawned.emit()

func configure_enemy_pathing(enemy: Enemy) -> void:
	# Create new PathFollow2D + RemoteTransform2D for enemy to follow EnemyPath with
	# EnemyPath2D is a node in the level, add a pathfollow to move along it, and a remote transform which will update the 
	# enemies position
	var new_path_follow: PathFollow2D = PathFollow2D.new()
	LevelManager.active_level.enemy_path.add_child(new_path_follow)

	var new_remote_transform: RemoteTransform2D = RemoteTransform2D.new()
	new_remote_transform.update_rotation = false
	new_remote_transform.update_scale = false
	new_path_follow.add_child(new_remote_transform)

	enemy.path_follow = new_path_follow
	new_remote_transform.remote_path = enemy.get_path()

func remove_all_enemies() -> void:
	for child in get_children():
		if child is Enemy:
			child.queue_free()
