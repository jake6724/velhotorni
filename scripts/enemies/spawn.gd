class_name Spawn
extends Resource

## The element type of the `enemy` to spawn.
@export var enemy_data: EnemyData

## The delay before spawning the next `enemy` in the `Wave`. Measured in seconds.
@export var delay: float = 1.0

## Determines which path the enemy uses for the entirety of its lifetime. 
## Starts at 0
@export var path_index: int = 0