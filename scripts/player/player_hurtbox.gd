class_name PlayerHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PlayerHurtboxCollider

signal damage_recieved
signal hit

func take_damage(damage: float, bullet_pos: Vector2) -> void:
	damage_recieved.emit(damage)
	hit.emit(calc_knockback_direction(bullet_pos))

func calc_knockback_direction(bullet_pos: Vector2) -> Vector2:
	# global_position can be used since this is a Node2D which will stay in the same location as PlayerCharacter root node
	var knockback_direction: Vector2 = bullet_pos.direction_to(global_position).round()
	return knockback_direction