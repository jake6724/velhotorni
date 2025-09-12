class_name PlayerAim
extends Node2D

@onready var player: PlayerCharacter = get_owner()

func update_aim(_delta):
	player.reticle_sprite.position = player.aim_direction * 100

	flip_sprite()
	rotate_staff()

func rotate_staff() -> void:
	if player.aim_direction:
		player.staff_sprite.rotation = player.aim_direction.angle()

func flip_sprite() -> void:
	if player.aim_direction:
		if player.aim_direction.x <= -0.001:
			player.character_sprite.flip_h = true
			player.staff_sprite.z_index = player.character_sprite.z_index - 1
			print(player.staff_sprite.z_index)
		else:
			player.character_sprite.flip_h = false
			player.staff_sprite.z_index = player.character_sprite.z_index + 1
			print(player.staff_sprite.z_index)
