class_name PlayerMovement
extends Node

var move_input_cardinal_normalized: Vector2

## Called in PlayerCharacter._physic_process(). Returns the new velocity value of the player
func get_velocity(move_input, speed) -> Vector2:
	if move_input:
		move_input = Constants.get_closest_cardinal_direction_normalized(move_input)
	return move_input * speed

func get_hitstun_velocity(delta, curr_velocity, hitstun_recovery_multiplier) -> Vector2:
	return curr_velocity.move_toward(Vector2.ZERO, delta * hitstun_recovery_multiplier)