class_name PlayerAnimation
extends Node2D

# This implementation is based on this video: https://www.youtube.com/watch?v=iElHZhOxGYA

@export var animation_tree: AnimationTree
@onready var player: PlayerCharacter = get_owner()

var last_facing_direction: Vector2 = Vector2(0, -1)

func _physics_process(_delta):

	var idle = !player.velocity

	if !idle:
		last_facing_direction = player.velocity.normalized()

	animation_tree.set("parameters/Walk/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)

	flip_sprite()

func flip_sprite() -> void:
	if player.aim_direction.x <= -0.001:
		player.character_sprite.flip_h = true
		player.staff_sprite.z_index = player.character_sprite.z_index - 1
		print(player.staff_sprite.z_index)
	else:
		player.character_sprite.flip_h = false
		player.staff_sprite.z_index = player.character_sprite.z_index + 1
		print(player.staff_sprite.z_index)
