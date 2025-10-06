class_name PlayerHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PlayerHurtboxCollider

signal damage_recieved
signal hit
signal pit_entered

func _ready():
	body_entered.connect(on_body_entered)
	area_entered.connect(on_area_entered)

func take_damage(damage: float, bullet_pos: Vector2) -> void:
	damage_recieved.emit(damage)
	hit.emit(calc_knockback_direction(bullet_pos))

func calc_knockback_direction(bullet_pos: Vector2) -> Vector2:
	# global_position can be used since this is a Node2D which will stay in the same location as PlayerCharacter root node
	var knockback_direction: Vector2 = bullet_pos.direction_to(global_position)
	return knockback_direction

func on_body_entered(_intruder) -> void:
	pit_entered.emit()

func on_area_entered(_intruder) -> void:
	damage_recieved.emit(_intruder.damage)
	take_damage(_intruder.damage, _intruder.global_position)