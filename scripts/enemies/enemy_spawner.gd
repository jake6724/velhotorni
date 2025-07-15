# Autoloader
extends Node

var level_waves: Array[Wave] = []
var active_wave: Wave
var wave_index: int = 0
var enemy_index: int = 0 
var spawn_timer: Timer = Timer.new()
var spawn_rate: float = 1.0 # Time between enemy spawn, in seconds
var can_spawn_enemy: bool = false
var active_enemies: Array[Enemy] = []

var enemies: Dictionary[GameManager.Element, PackedScene] = {
	GameManager.Element.FIRE: preload("res://scenes/enemies/FireEnemy.tscn"),
	GameManager.Element.WATER: preload("res://scenes/enemies/WaterEnemy.tscn"),
	GameManager.Element.EARTH: preload("res://scenes/enemies/EarthEnemy.tscn"),
}

# Signals
signal wave_complete
signal level_complete
signal enemy_spawned
signal enemy_died

func _ready():
	# Configure Timer
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)

	# Enemy spawner manually start and reset by GameManager

func configure_level(active_level: LevelEnvironment):
	level_waves = active_level.waves

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

func _physics_process(_delta) -> void:
	# Only process if a wave is active	
	if active_wave:
		# Check if wave is over
		if enemy_index == active_wave.data.size() and active_enemies.size() == 0:
			# Wave complete (could be a function)
			active_wave = null
			wave_index += 1
			enemy_index = 0
			wave_complete.emit()
			can_spawn_enemy = false

			if wave_index == level_waves.size() and GameManager.level_failed == false:
				level_complete.emit()

		elif can_spawn_enemy and enemy_index < active_wave.data.size():
			var spawn_element: GameManager.Element = active_wave.data[enemy_index].element
			var spawn_delay: float = active_wave.data[enemy_index].delay
			spawn_enemy(spawn_element)
			enemy_index += 1
		
			# Restart spawn timer
			spawn_timer.start(spawn_delay)
			can_spawn_enemy = false
		
func spawn_enemy(enemy_type: GameManager.Element) -> void:
	# Configure new enemy
	var new_enemy: Enemy = enemies[enemy_type].instantiate()
	new_enemy.position = GameManager.active_spawn_location
	new_enemy.is_dead.connect(on_enemy_died)
	add_child(new_enemy)

	active_enemies.append(new_enemy)
	enemy_spawned.emit()

func on_enemy_died(enemy: Enemy) -> void:
	var index = active_enemies.find(enemy)
	if index != -1:
		active_enemies.remove_at(index)
		enemy.ap.play("die") # This may not need to be here and could MAYBE go in enemy. Not sure if queue_free() would cause race condition or issues...
		enemy.play_explosion_sfx()
	enemy_died.emit()

func on_spawn_timer_timeout() -> void:
	can_spawn_enemy = true
