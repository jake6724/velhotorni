# TODO: This should maybe not a be a singleton... just a child of main? 

# Singleton responsible for spawning enemies based on the active level's wave data
# All enemies are a child of this class
extends Node2D

var active_enemies: Array[Enemy]
var enemy_index: int
var can_spawn_enemy: bool
var spawn_timer: Timer = Timer.new()
var spawn_timer_2: Timer = Timer.new()

var boss_wave_active: bool = false

var enemy_scenes: Dictionary[Enemy.Size, PackedScene] = {
	Enemy.Size.MEDIUM: preload("res://scenes/enemies/Enemy.tscn"),
	Enemy.Size.LARGE: preload("res://scenes/enemies/LargeEnemy.tscn"),
}

# Signals
signal enemy_spawned
signal enemy_spawned_with_ref
signal enemy_died
signal enemy_died_with_global_pos
signal boss_enemy_damage_recieved

func _ready():
	z_index = Constants.z_index_map["enemy_spawner"]

	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)

	spawn_timer_2.timeout.connect(on_spawn_timer_2_timeout)
	add_child(spawn_timer_2)

	# Connect to WaveManager
	WaveManager.wave_started.connect(start_wave)
	WaveManager.wave_completed.connect(on_wave_complete)
	WaveManager.wave_failed.connect(reset)
	WaveManager.all_waves_completed.connect(reset)
	WaveManager.final_wave_started.connect(on_final_wave_started)

func _physics_process(_delta): # TODO: It would be great to not call this on tick
	sort_enemies_z_index_by_progress()

## Called by LevelManager.
func configure_level():
	active_enemies = []
	enemy_index = 0
	can_spawn_enemy = false
	
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

func on_wave_complete() -> void:
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
	enemy_died_with_global_pos.emit(enemy.global_position)

## Called on `spawn_timer`'s `timeout`
func on_spawn_timer_timeout() -> void:
	if WaveManager.active_wave:
		if can_spawn_enemy:
			while enemy_index < WaveManager.active_wave.data.size():
				if WaveManager.active_wave.data[enemy_index].path_index == 0:
					var spawn_data: Spawn = WaveManager.active_wave.data[enemy_index]
					var spawn_delay: float = WaveManager.active_wave.data[enemy_index].delay

					spawn_enemy(spawn_data)
					enemy_index += 1

					# Restart spawn timer
					spawn_timer.start(spawn_delay)

func on_spawn_timer_2_timeout() -> void:
		if WaveManager.active_wave:
			if can_spawn_enemy and enemy_index < WaveManager.active_wave.data.size():
				var spawn_data: Spawn = WaveManager.active_wave.data[enemy_index]
				var spawn_delay: float = WaveManager.active_wave.data[enemy_index].delay

				spawn_enemy(spawn_data)
				enemy_index += 1

				# Restart spawn timer
				spawn_timer.start(spawn_delay)

func spawn_enemy(_spawn: Spawn) -> void:
	# Configure new enemy
	var _enemy_data: EnemyData = _spawn.enemy_data
	var new_enemy: Enemy = enemy_scenes[_enemy_data.size].instantiate()
	new_enemy.data = _enemy_data
	new_enemy.died.connect(on_enemy_died)
	add_child(new_enemy)
	active_enemies.append(new_enemy)

	configure_enemy_pathing(new_enemy, _spawn)

	if boss_wave_active: 
		new_enemy.is_boss = true
		new_enemy.enemy_damage_recieved.connect(on_boss_enemy_damage_recieved)

	enemy_spawned.emit()
	enemy_spawned_with_ref.emit(new_enemy)

func configure_enemy_pathing(enemy: Enemy, _spawn: Spawn) -> void:
	# Create new PathFollow2D + RemoteTransform2D for enemy to follow EnemyPath with
	# EnemyPath2D is a node in the level, add a pathfollow to move along it, and a remote transform which will update the 
	# enemies position
	var new_path_follow: PathFollow2D = PathFollow2D.new()
	new_path_follow.rotates = true

	if _spawn.path_index == 0:
		LevelManager.active_level.enemy_path.add_child(new_path_follow)
	elif _spawn.path_index == 1:
		LevelManager.active_level.enemy_path_2.add_child(new_path_follow)

	var new_remote_transform: RemoteTransform2D = RemoteTransform2D.new()
	new_remote_transform.update_rotation = false
	new_remote_transform.update_scale = false
	new_path_follow.add_child(new_remote_transform)

	enemy.path_follow = new_path_follow
	new_remote_transform.remote_path = enemy.get_path()

	enemy.z_as_relative = true

func remove_all_enemies() -> void:
	for child in get_children():
		if child is Enemy:
			child.queue_free()

func sort_enemies_z_index_by_progress() -> void:
	var offset: int = active_enemies.size()
	active_enemies.sort_custom(compare_by_progress_ratio)
	for enemy: Enemy in active_enemies:
		enemy.sprite.z_index = offset
		offset -= 1

func compare_by_progress_ratio(enemy_a: Enemy, enemy_b: Enemy) -> bool:
	return enemy_a.path_follow.progress_ratio > enemy_b.path_follow.progress_ratio

func on_final_wave_started():
	boss_wave_active = true

func on_boss_enemy_damage_recieved(_damage: float):
	boss_enemy_damage_recieved.emit(_damage)