class_name EnemyMovement
extends Node2D

var move_func: Callable = Callable(self, "move_along_path")

signal animation_requested
signal sprite_flip_requested
signal damage_base_requested
signal death_requested

## Wrapper function for the `move_func` Callable (function pointer)
func move(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2,
_player: PlayerCharacter, _path_follow: PathFollow2D) -> void:
	move_func.call(delta, speed, slow_percent, is_alive, is_frozen, is_stunned, 
	is_taking_damage, _enemy_global_position, _player, _path_follow)

func move_along_path(delta: float, speed: float, slow_percent: float, is_alive: bool, is_frozen: bool,
is_stunned: bool, is_taking_damage: bool, _enemy_global_position: Vector2,
_player: PlayerCharacter, _path_follow: PathFollow2D) -> void:

	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				animation_requested.emit("walk")

			sprite_flip_requested.emit(_path_follow.rotation_degrees >= 91)
				
			if _path_follow.progress_ratio < .99:
				_path_follow.progress += (speed - ((speed * (slow_percent/100)))) * delta
			else:
				damage_base_requested.emit()
				death_requested.emit()
		else:
			animation_requested.emit("idle")