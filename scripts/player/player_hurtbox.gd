class_name PlayerHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PlayerHurtboxCollider

signal damage_recieved
signal knockback_direction_calculated

func take_damage(damage: float, bullet_pos: Vector2) -> void:
	damage_recieved.emit(damage)
	calc_knockback_direction(bullet_pos)

func calc_knockback_direction(bullet_pos: Vector2) -> void:
	# global_position can be used since this is a Node2D which will stay in the same location as PlayerCharacter root node
	var knockback_direction: Vector2 = bullet_pos.direction_to(global_position).round()
	knockback_direction_calculated.emit(knockback_direction)

# func _ready():
# 	area_entered.connect(on_area_entered)

# func on_area_entered(intruder: Area2D):
# 	pass