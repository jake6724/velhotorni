class_name PlayerClone
extends Node2D

# @onready var staff_sprite: StaffSprite = 

# func rotate_staff(aim_input) -> void:
# 	if aim_input:
# 		# Rotate staff to point at aim direction
# 		player.staff_sprite.rotation = aim_input.angle() + deg_to_rad(staff_rotation_offset_degrees) * staff_rotation_sign

# 		# Set staff render order based on aim direction and horizontal axis
# 		if aim_input.normalized().y < 0:
# 			player.staff_sprite.z_index = player.character_sprite.z_index - 1
# 		else:
# 			player.staff_sprite.z_index = player.character_sprite.z_index + 1

# 	# Render staff behind player if moving up in all cases
# 	if player.velocity.y < 0:
# 		player.staff_sprite.z_index = player.character_sprite.z_index - 1

# 	if not player.can_fire:
# 		player.staff_sprite.z_index = player.character_sprite.z_index + 1