class_name CoinDropManager
extends Node2D

## Manages all of the inidividual coin drops. Does not handle collection, see coin_collector.gd

var coin_drop_scene: PackedScene = preload("res://scenes/enemies/CoinDrop.tscn")
const JITTER: float = 7
const REWARD_JITTER: float = 10
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var reward_remaining: int = 0
var direction_to_mouse: Vector2

var spawn_tower_mana_as_spell_mana_chance: float = 0.0

signal reward_completed
signal spell_mana_spawn_requested

func _ready():
	WaveManager.wave_failed.connect(on_wave_failed)
	WaveManager.wave_completed_coin_manager.connect(on_wave_complete)

func on_enemy_spawned(_enemy: Enemy) -> void:
	_enemy.coin_dropped.connect(spawn_coin_drop)

## Called when an enemy that `CoinDropManager` is connected to dies. `CoinDropManager` connects to enemies in `on_enemy_spawned()`
## helper function is used so that parent function can modify drop_chance with perk bonus before recursive calls start
func spawn_coin_drop(_global_pos, drop_chance) -> void:
	drop_chance = drop_chance + TowerGlobalData.tower_mana_drop_perk_bonus
	spawn_coin_drop_helper(_global_pos, drop_chance)

func spawn_coin_drop_helper(_global_pos, drop_chance) -> void:
	var roll: float = rng.randf()
	if roll <= drop_chance:
		# Decide if should spawn as tower or spell mana (required by a perk)
		var spell_mana_roll: float = rng.randf()
		if spell_mana_roll <= spawn_tower_mana_as_spell_mana_chance:
			spell_mana_spawn_requested.emit(_global_pos)

		else:
			var coin: CoinDrop = coin_drop_scene.instantiate()
			call_deferred("add_child", coin)
			coin.global_position = _global_pos
			var closest_valid: Vector2 = WorldGrid.get_closest_valid_point(_global_pos)
			coin.destination = calc_destination(closest_valid)
			coin.destination.clamp(Vector2(0,0), Vector2(400,224))
			#print("Origin point: ", _global_pos, " Coin Destination: ", coin.destination, "Diff: ", coin.global_position.distance_to(coin.destination))
			coin.destination_direction = coin.global_position.direction_to(coin.destination)
		
		# Recursive call if drop chance remaining
		drop_chance -= 1.0
		if drop_chance > 0.0:
			spawn_coin_drop_helper(_global_pos, drop_chance)
	
## Called when an enemy that `CoinDropManager` is connected to dies. `CoinDropManager` connects to enemies in `on_enemy_spawned()`
func spawn_reward(_global_pos, drop_chance) -> void:
	var roll: float = rng.randf()
	if roll <= drop_chance:
		var coin: CoinDrop = coin_drop_scene.instantiate()
		coin.is_reward = true
		reward_remaining += 1
		call_deferred("add_child", coin)
		coin.global_position = _global_pos
		coin.destination = calc_reward_destination(_global_pos)
		coin.destination_direction = coin.global_position.direction_to(coin.destination)

		drop_chance -= 1.0
		await get_tree().create_timer(.01).timeout
		if drop_chance > 0.0:
			spawn_reward(_global_pos, drop_chance)

func decrement_reward_remaining() -> void:
	reward_remaining -= 1
	if reward_remaining <= 0:
		reward_completed.emit()

func _physics_process(delta):
	for child in get_children():
		var coin: CoinDrop = child as CoinDrop
		if coin: 
			if not coin.destination_reached:
				coin.global_position += coin.destination_direction * coin.speed * delta
				#print(coin.global_position.distance_to(coin.destination))
				if coin.global_position.distance_to(coin.destination) <= 1 or coin.global_position.distance_to(coin.destination) > 15:
					coin.destination_reached = true

func calc_destination(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(-JITTER, JITTER)
	var jy: float = rng.randf_range(-JITTER, JITTER)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset

func calc_reward_destination(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(-REWARD_JITTER, REWARD_JITTER)
	var jy: float = rng.randf_range(-REWARD_JITTER, REWARD_JITTER)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset

func on_wave_complete(global_pos: Vector2, reward: int) -> void:
	spawn_reward(global_pos, reward)

func on_wave_failed() -> void:
	for child in get_children():
		var coin: CoinDrop = child as CoinDrop
		if coin:
			coin.queue_free()

func on_spawn_tower_mana_as_spell_mana_chance_incremented(_increment: float) -> void:
	spawn_tower_mana_as_spell_mana_chance += _increment