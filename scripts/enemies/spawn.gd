class_name Spawn
extends Resource

## The element type of the `enemy` to spawn.
@export var enemy_data: EnemyData

## The delay before spawning the next `enemy` in the `Wave`. Measured in seconds.
@export var delay: float = 1.0
