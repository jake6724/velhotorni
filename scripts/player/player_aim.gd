class_name PlayerAim
extends Node2D

@onready var player: PlayerCharacter = get_owner()

const RETICLE_MAX_DISTANCE: float = 50
const RETICLE_SPEED: float = .1

func update_aim(delta):
	update_reticle()
	flip_sprite()
	rotate_staff()

func update_reticle() -> void:
	if player.aim_direction: # Move reticle out infront of player character
		
		var reticle_tween: Tween = get_tree().create_tween()
		var target_position: Vector2 = player.spell_spawn_point.global_position + player.aim_direction * RETICLE_MAX_DISTANCE
		reticle_tween.tween_property(player.reticle_sprite, "global_position", target_position, RETICLE_SPEED)

	# else: 			     # Move reticle back to player
	# 	var reticle_tween: Tween = get_tree().create_tween()
	# 	reticle_tween.tween_property(player.reticle_sprite, "position", Vector2.ZERO, RETICLE_SPEED) 

func rotate_staff() -> void:
	if player.aim_direction:
		# Rotate staff to point at aim direction
		player.staff_sprite.rotation = player.aim_direction.angle()

		# Set staff render order based on aim direction and horizontal axis
		if player.aim_direction.y < 0:
			player.staff_sprite.z_index = player.character_sprite.z_index - 1
		else:
			player.staff_sprite.z_index = player.character_sprite.z_index + 1

		# # Set staff render order based on move direction
		# if player.move_direction.y < .5:
		# 	player.staff_sprite.z_index = player.character_sprite.z_index - 1
		# elif player.move_direction.y > -.5:
		# 	player.staff_sprite.z_index = player.character_sprite.z_index + 1

func flip_sprite() -> void:
	if player.aim_direction:
		if player.aim_direction.x <= -0.001:
			player.character_sprite.flip_h = true
		else:
			player.character_sprite.flip_h = false
