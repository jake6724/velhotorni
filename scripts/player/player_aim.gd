class_name PlayerAim
extends Node2D

@onready var player: PlayerCharacter = get_owner()


const RETICLE_MAX_DISTANCE: float = 65

## The total duration of the tween_property call used to update the reticle's position, in seconds
const RETICLE_SPEED: float = .1
const RETICLE_MIN_MAGNITUDE: float = .3
const RETICLE_RESET_TIMER_DELAY: float = .25
const RETICLE_RESET_POSITION_DURATION: float = 3

## Controls how quickly the reticles moves back toward the player when no input is given
## Higher values will make the reticle move faster
@export var reset_speed_modifier: float = .65

var aim_input: Vector2 # Manully set by PlayerCharacter

var resetting_reticle: bool = false

func update_aim():
	update_reticle()
	flip_sprite()
	rotate_staff()

func update_reticle() -> void:
	if !aim_input:
		player.reticle_sprite.position = Vector2.ZERO
		return

	if aim_input.length() < RETICLE_MIN_MAGNITUDE:
		aim_input = aim_input.normalized() * RETICLE_MIN_MAGNITUDE

	var reticle_tween: Tween = get_tree().create_tween()
	var target_position: Vector2 = player.spell_spawn_point.global_position + (aim_input * RETICLE_MAX_DISTANCE)
	reticle_tween.tween_property(player.reticle_sprite, "global_position", target_position, RETICLE_SPEED)

func reset_reticle_position(delta) -> void:
	aim_input -= aim_input.normalized() * delta * reset_speed_modifier
	
func rotate_staff() -> void:
	if aim_input:
		# Rotate staff to point at aim direction
		player.staff_sprite.rotation = aim_input.angle()

		# Set staff render order based on aim direction and horizontal axis
		if aim_input.normalized().y < 0:
			player.staff_sprite.z_index = player.character_sprite.z_index - 1
		else:
			player.staff_sprite.z_index = player.character_sprite.z_index + 1

		# # Set staff render order based on move direction
		# if player.move_direction.y < .5:
		# 	player.staff_sprite.z_index = player.character_sprite.z_index - 1
		# elif player.move_direction.y > -.5:
		# 	player.staff_sprite.z_index = player.character_sprite.z_index + 1

func flip_sprite() -> void:
	if aim_input:
		var flip = aim_input.x <= -0.001
		player.character_sprite.flip_h = flip
