class_name CoinDropManager
extends Node

var coin_drop_scene: PackedScene = preload("res://scenes/enemies/CoinDrop.tscn")
const JITTER_MIN: float = -20
const JITTER_MAX: float = 20
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func spawn_coin_drop(_global_pos) -> void:
	print("Spawning coin")
	var new_coin_drop: CoinDrop = coin_drop_scene.instantiate()
	add_child(new_coin_drop)
	new_coin_drop.global_position = apply_jitter(_global_pos)

func on_enemy_spawned(_enemy: Enemy) -> void:
	print("Connecting to enemy")
	_enemy.death_position.connect(spawn_coin_drop)

func _physics_process(delta):
	for child in get_children():
		var coin: CoinDrop = child as CoinDrop
		if coin:
			coin.countdown -= delta
			if coin.countdown <= 0:
				print("Deleting coin!")
				coin.queue_free()

func apply_jitter(_global_pos) -> Vector2:
	var jx: float = rng.randf_range(JITTER_MIN, JITTER_MAX)
	var jy: float = rng.randf_range(JITTER_MIN, JITTER_MAX)
	var jitter_offset: Vector2 = Vector2(jx, jy)
	return _global_pos + jitter_offset