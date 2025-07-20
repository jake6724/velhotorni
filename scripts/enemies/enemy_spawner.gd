# Autoloader
extends Node

var active_level: LevelEnvironment
var enemy_path_length: float
var level_waves: Array[Wave] = []
var active_wave: Wave
var wave_index: int = 0
var enemy_index: int = 0 
var spawn_timer: Timer = Timer.new()
var spawn_rate: float = 1.0 # Time between enemy spawn, in seconds
var can_spawn_enemy: bool = false
var active_enemies: Array[Enemy] = []

# Checkpoint data
var checkpoint_wave_index: int

var enemy_scene: PackedScene = preload("res://scenes/enemies/Enemy.tscn")
var enemy_data: Dictionary[GameManager.Element, EnemyData] = {
	GameManager.Element.FIRE: preload("res://data/enemies/enemy_fire_data.tres"),
	GameManager.Element.EARTH: preload("res://data/enemies/enemy_earth_data.tres"),
	GameManager.Element.WATER: preload("res://data/enemies/enemy_water_data.tres"),
}
# Signals
signal wave_complete
signal level_complete
signal enemy_spawned
signal enemy_died

func _ready():
	# Enemy spawner manually configured and reset by GameManager
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)

func configure_level(_active_level: LevelEnvironment):
	active_level = _active_level
	enemy_path_length = active_level.enemy_path.curve.get_baked_length()
	level_waves = _active_level.waves

func clear_level() -> void:
	for child in get_children():
		if child is Enemy:
			child.queue_free()

	active_enemies = []
	level_waves = []
	active_wave = null
	wave_index = 0
	enemy_index = 0
	
## Intended to be triggered directly by `player_controller`
func start_wave() -> void:
	active_wave = level_waves[wave_index]
	can_spawn_enemy = true
	on_spawn_timer_timeout() # Called manually the first timer, then timer handles it

	# Checkpoint EnemySpawner data
	checkpoint_wave_index = wave_index

func check_wave_complete() -> bool:
	print("is_wave_failed: ", GameManager.is_wave_failed)
	print("enemy_index == active_wave.data.size(): ", enemy_index == active_wave.data.size())
	print("active_enemies.size() == 0 ", active_enemies.size() == 0)
	if enemy_index == active_wave.data.size() and active_enemies.size() == 0 and GameManager.is_wave_failed == false:
		print("Check wave complete internal pass")
		return true
	else:
		return false

func on_wave_complete() -> void:
	active_wave = null
	wave_index += 1
	enemy_index = 0
	print("Enemy spawner calling level_complete.emit()")
	wave_complete.emit()
	can_spawn_enemy = false

## Called manually by `GameManager` to avoid race-conditions with `PlayerController`.
func on_wave_failed() -> void:
	for child in get_children():
		if child is Enemy:
			child.queue_free()
	active_enemies = []
	wave_index = checkpoint_wave_index
	enemy_index = 0
	active_wave = level_waves[wave_index]
	can_spawn_enemy = false
	spawn_timer.stop()

func check_level_complete() -> void:
	if wave_index == level_waves.size() and GameManager.level_failed == false:
		level_complete.emit()

func on_enemy_died(enemy: Enemy) -> void:
	var index = active_enemies.find(enemy)
	if index != -1:
		active_enemies.remove_at(index)
	enemy_died.emit()

	if active_wave and check_wave_complete():
		print("Check wave complete passed")
		on_wave_complete()

		check_level_complete()

func on_spawn_timer_timeout() -> void:
	if active_wave:
		if can_spawn_enemy and enemy_index < active_wave.data.size():
			var spawn_element: GameManager.Element = active_wave.data[enemy_index].element
			var spawn_delay: float = active_wave.data[enemy_index].delay
			spawn_enemy(spawn_element)
			enemy_index += 1

			# Restart spawn timer
			spawn_timer.start(spawn_delay)

func spawn_enemy(element: GameManager.Element) -> void:
	# Configure new enemy
	var new_enemy: Enemy = enemy_scene.instantiate()
	new_enemy.data = enemy_data[element]
	new_enemy.position = GameManager.active_spawn_location
	new_enemy.is_dead.connect(on_enemy_died)
	add_child(new_enemy)
	active_enemies.append(new_enemy)

	configure_enemy_pathing(new_enemy)
	enemy_spawned.emit()

func configure_enemy_pathing(enemy: Enemy) -> void:
	# Create new PathFollow2D + RemoteTransform2D for enemy to follow EnemyPath with
	# EnemyPath2D is a node in the level, add a pathfollow to move along it, and a remote transform which will update the 
	# enemies position
	var new_path_follow: PathFollow2D = PathFollow2D.new()
	active_level.enemy_path.add_child(new_path_follow)

	var new_remote_transform: RemoteTransform2D = RemoteTransform2D.new()
	new_remote_transform.update_rotation = false
	new_remote_transform.update_scale = false
	new_path_follow.add_child(new_remote_transform)

	enemy.path_follow = new_path_follow
	new_remote_transform.remote_path = enemy.get_path()


# func _physics_process(_delta) -> void:
# 	# TODO: This can move out of here and into a function that is called in on_enemy_died() or something less performance heavy
# 	# Only process if a wave is active	
# 	if active_wave:
# 		# Check if wave is over
# 		if enemy_index == active_wave.data.size() and active_enemies.size() == 0:
# 			# Wave complete (could be a function)
# 			active_wave = null
# 			wave_index += 1
# 			enemy_index = 0
# 			wave_complete.emit()
# 			can_spawn_enemy = false
			
# 			if wave_index == level_waves.size() and GameManager.level_failed == false:
# 				level_complete.emit()

# 		elif can_spawn_enemy and enemy_index < active_wave.data.size():
# 			var spawn_element: GameManager.Element = active_wave.data[enemy_index].element
# 			var spawn_delay: float = active_wave.data[enemy_index].delay
# 			spawn_enemy(spawn_element)
# 			enemy_index += 1
		
# 			# Restart spawn timer
# 			spawn_timer.start(spawn_delay)
# 			can_spawn_enemy = false
