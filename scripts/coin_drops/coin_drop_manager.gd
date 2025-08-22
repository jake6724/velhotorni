class_name CoinDropManager
extends Node

## Manages all of the inidividual coin drops. Does not handle collection, see coin_collector.gd

var coin_drop_scene: PackedScene = preload("res://scenes/enemies/CoinDrop.tscn")
const JITTER_MIN: float = -20
const JITTER_MAX: float = 20
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	WaveManager.wave_failed.connect(on_wave_failed)
	WaveManager.wave_completed_coin_manager.connect(on_wave_complete)

## Called when an enemy that `CoinDropManager` is connected to dies. `CoinDropManager` connects to enemies in `on_enemy_spawned()`
func spawn_coin_drop(_global_pos, drop_chance) -> void:
	var roll: float = rng.randf()
	if roll <= drop_chance:
		var coin: CoinDrop = coin_drop_scene.instantiate()
		call_deferred("add_child", coin)
		coin.global_position = _global_pos
		coin.destination = calc_destination(_global_pos)
		coin.destination_direction = coin.global_position.direction_to(coin.destination)

		drop_chance -= 1.0
		if drop_chance > 0.0:
			spawn_coin_drop(_global_pos, drop_chance)

func on_enemy_spawned(_enemy: Enemy) -> void:
	_enemy.coin_dropped.connect(spawn_coin_drop)

func _physics_process(delta):
	for child in get_children():
		var coin: CoinDrop = child as CoinDrop
		if coin:
			coin.countdown -= delta
			if coin.countdown > 0:
				if not coin.destination_reached:
					coin.global_position += coin.destination_direction * coin.speed * delta
					if abs(coin.global_position - coin.destination) < Vector2(1,1) or abs(coin.global_position - coin.destination) > Vector2(25,25):
						coin.destination_reached = true
					
				if coin.countdown < coin.blink_start:
					if coin.blink_checkpoint == 0.0:
						coin.blink_checkpoint = coin.countdown

					if coin.countdown <= (coin.blink_checkpoint - coin.blink_rate):
						coin.visible = not coin.visible
						coin.blink_checkpoint = coin.countdown
						coin.blink_rate = coin.blink_rate - (coin.blink_rate * coin.blink_rate_multiplier)
			else:
				coin.queue_free()

func calc_destination(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(JITTER_MIN, JITTER_MAX)
	var jy: float = rng.randf_range(JITTER_MIN, JITTER_MAX)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset

func on_wave_complete(global_pos: Vector2, reward: int) -> void:
	spawn_coin_drop(global_pos, reward)

func on_wave_failed() -> void:
	for child in get_children():
		var coin: CoinDrop = child as CoinDrop
		if coin:
			coin.queue_free()
