class_name PlayerAim
extends Node2D

@onready var player: PlayerCharacter = get_owner()

func update_aim(_delta):
	player.reticle_sprite.position = player.aim_direction * 100

	flip_sprite()
	rotate_staff()

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
