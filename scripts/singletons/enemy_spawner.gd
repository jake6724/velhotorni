# TODO: This should maybe not a be a singleton... just a child of main? 

# Singleton responsible for spawning enemies based on the active level's wave data
# All enemies are a child of this class
extends Node2D

var active_enemies: Array[Enemy]
var active_path_enemies: Array[Enemy]
var enemy_index: int
var can_spawn_enemy: bool

var spawn_timers: Array[Timer] = []

var boss_wave_active: bool = false

var path_spawns: Array = []
var path_enemy_indexes: Array[int] = []
var flying_spawn_points: Array[Vector2] = []

var player: PlayerCharacter # Set by main

var enemy_scenes: Dictionary[Enemy.Size, PackedScene] = {
	Enemy.Size.SMALL: preload("res://scenes/enemies/SmallEnemy.tscn"),
	Enemy.Size.LARGE: preload("res://scenes/enemies/LargeEnemy.tscn"),
	Enemy.Size.FLYING_SMALL: preload("res://scenes/enemies/FlyingSmallEnemy.tscn"),
	Enemy.Size.FLYING_LARGE: preload("res://scenes/enemies/FlyingLargeEnemy.tscn"),
	Enemy.Size.RANGED_SMALL: preload("res://scenes/enemies/RangedSmallEnemy.tscn"),
	Enemy.Size.RANGED_LARGE: preload("res://scenes/enemies/EnemyRangedLarge.tscn"),
	Enemy.Size.REPEATER_SMALL: preload("res://scenes/enemies/EnemyRangedSmallRepeater.tscn"),
	Enemy.Size.REPEATER_LARGE: preload("res://scenes/enemies/EnemyRangedRepeaterLarge.tscn"),
}

# Signals
signal enemy_spawned
signal enemy_spawned_with_ref
signal enemy_died
signal enemy_died_with_global_pos
signal enemy_died_with_global_pos_drop_chance
signal boss_enemy_damage_recieved

func _ready():
	z_index = Constants.z_index_map["enemy_spawner"]

	# Connect to WaveManager
	WaveManager.wave_started.connect(start_wave)
	WaveManager.wave_completed.connect(on_wave_complete)
	WaveManager.wave_failed.connect(reset)
	WaveManager.all_waves_completed.connect(reset)
	WaveManager.final_wave_started.connect(on_final_wave_started)

func _physics_process(_delta): # TODO: It would be great to not call this on tick
	sort_path_enemies_z_index_by_progress()

## Called by LevelManager.
func configure_level(active_level: LevelEnvironment):
	active_enemies = []
	active_path_enemies = []
	enemy_index = 0
	can_spawn_enemy = false
	create_spawn_timers(active_level)

	for i in range(active_level.enemy_paths.size()):
		path_spawns.append([])
		path_enemy_indexes.append(0)

	sort_enemies_by_path()

	flying_spawn_points = active_level.flying_spawn_points

## Intended to be triggered directly by `player_controller`.
func start_wave() -> void:
	can_spawn_enemy = true

	for i in range(spawn_timers.size()):
		on_spawn_timer_timeout(i)

## Called when a wave is completed or failed.
func reset() -> void:
	remove_all_enemies()
	active_enemies = []
	active_path_enemies = []
	can_spawn_enemy = false
	stop_all_spawn_timers()
	reset_indexes()

func on_wave_complete() -> void:
	active_enemies = []
	active_path_enemies = []
	can_spawn_enemy = false
	stop_all_spawn_timers()
	sort_enemies_by_path()
	reset_indexes()

func reset_indexes() -> void:
	enemy_index = 0
	for i in range(path_enemy_indexes.size()):
		path_enemy_indexes[i] = 0

## Triggered when an `Enemy` child dies and emits their `died` signal.
func on_enemy_died(enemy: Enemy) -> void:
	var index = active_enemies.find(enemy)
	var index_2 = active_path_enemies.find(enemy)
	if index != -1:
		active_enemies.remove_at(index)
		if index_2 != -1:
			active_path_enemies.remove_at(index_2)
	enemy_died.emit()
	enemy_died_with_global_pos.emit(enemy.global_position)
	enemy_died_with_global_pos_drop_chance.emit(enemy.global_position, enemy.data.element_mana_drop_chance)

func on_spawn_timer_timeout(path_index: int) -> void:
	if path_index < path_spawns.size() and path_spawns[path_index].size() > 0:
		if path_enemy_indexes[path_index] < path_spawns[path_index].size():
			if can_spawn_enemy:
				var spawn_data: Spawn = path_spawns[path_index][path_enemy_indexes[path_index]]
				spawn_enemy(spawn_data)
				enemy_index += 1
				path_enemy_indexes[path_index] += 1

				# Start the correct timer based on enemy path_index
				# the active level's enemy_paths Array should be parallel with spawn_timers
				spawn_timers[spawn_data.path_index].start(spawn_data.delay)

func spawn_enemy(_spawn: Spawn) -> void:
	# Configure new enemy
	var _enemy_data: EnemyData = _spawn.enemy_data
	var new_enemy: Enemy = enemy_scenes[_enemy_data.size].instantiate()
	new_enemy.data = _enemy_data
	new_enemy.died.connect(on_enemy_died)
	add_child(new_enemy)
	active_enemies.append(new_enemy)

	if new_enemy is FlyingEnemy:
		new_enemy.player = player
		new_enemy.global_position = flying_spawn_points[_spawn.flying_spawn_index]
	else:
		active_path_enemies.append(new_enemy)
		configure_enemy_pathing(new_enemy, _spawn)

	if new_enemy is EnemyRanged or new_enemy is EnemyRangedRepeater:
		new_enemy.configure_ranged_enemy()

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

	# Add to the correct path (does not account for runtime errors. If a spawn has a path_index > 0,
	# a corresponding Path2D node MUST be added to accomodate)
	LevelManager.active_level.enemy_paths[_spawn.path_index].add_child(new_path_follow)

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

func sort_path_enemies_z_index_by_progress() -> void:
	var offset: int = active_path_enemies.size()
	if active_path_enemies.size() > 1:
		active_path_enemies.sort_custom(compare_by_progress_ratio)
		for enemy: Enemy in active_path_enemies:
			if enemy: # Fix for a common error that has been difficult to root cause: Invalid access to property or key 'sprite' on a base object of type 'previously freed'.
				enemy.sprite.z_index = offset
				offset -= 1

func compare_by_progress_ratio(enemy_a: Enemy, enemy_b: Enemy) -> bool:
	return enemy_a.path_follow.progress_ratio > enemy_b.path_follow.progress_ratio

func on_final_wave_started():
	boss_wave_active = true

func on_boss_enemy_damage_recieved(_damage: float):
	boss_enemy_damage_recieved.emit(_damage)

func create_spawn_timers(active_level) -> void:
	for i in range(active_level.enemy_paths.size()):
		var new_timer: Timer = Timer.new()
		new_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		new_timer.autostart = false
		new_timer.timeout.connect(on_spawn_timer_timeout.bind(i))
		add_child(new_timer)
		spawn_timers.append(new_timer)
	
func stop_all_spawn_timers() -> void:
	for timer: Timer in spawn_timers:
		timer.stop()

func sort_enemies_by_path() -> void:
	for i in range(path_spawns.size()):
		path_spawns[i] = []
		path_enemy_indexes[i] = 0

	if WaveManager.active_wave:
		for spawn: Spawn in WaveManager.active_wave.data:
			path_spawns[spawn.path_index].append(spawn)
