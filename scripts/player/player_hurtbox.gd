class_name PlayerHurtbox
extends Area2D

@onready var collider: CollisionShape2D = $PlayerHurtboxCollider

signal hit
signal hit_no_data
signal pit_entered
signal camera_shake_requested

var reflect_chance: float # Set manually by PlayerCharacter
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const REFLECT_CAMERA_SHAKE: float = .4

func _ready():
	body_entered.connect(on_body_entered)
	area_entered.connect(on_area_entered)

func take_damage(_damage: float, bullet_pos: Vector2) -> void:
	hit.emit(calc_knockback_direction(bullet_pos))
	hit_no_data.emit()

## Receive bullet damage. This function is very custom: it hanldes player damage and knockback and also handles
## triggering bullet reflection as well. It also returns a value which tells the colliding bullet if it should
## Play hit or not (do not play if reflected)
func take_bullet_damage(_damage: float, bullet_pos: Vector2, bullet: EnemyBullet) -> bool:
	if rng.randf() < reflect_chance:
		reflect_bullet(bullet)
		camera_shake_requested.emit(REFLECT_CAMERA_SHAKE)
		return false

	hit.emit(calc_knockback_direction(bullet_pos))
	hit_no_data.emit()
	return true

func calc_knockback_direction(bullet_pos: Vector2) -> Vector2:
	# global_position can be used since this is a Node2D which will stay in the same location as PlayerCharacter root node
	var knockback_direction: Vector2 = bullet_pos.direction_to(global_position)
	return knockback_direction

func on_body_entered(_intruder) -> void:
	pit_entered.emit()

## Used for walking into enemies
func on_area_entered(_intruder) -> void:
	take_damage(_intruder.damage, _intruder.global_position)

func reflect_bullet(bullet: EnemyBullet) -> void:
	# Invert bullet direction
	bullet.direction = global_position.direction_to(bullet.global_position)

	# Change bullet collision layer to see enemies and ignore player 
	bullet.collision_area.set_collision_mask_value(4,false) # Ignore tower hurtbox
	bullet.collision_area.set_collision_mask_value(17,false) # Ignore player hurtbox
	bullet.collision_area.set_collision_mask_value(21,false) # Ignore smelee spell
	bullet.collision_area.set_collision_mask_value.call_deferred(5,true) # see enemies

	bullet.active = true # Make bullet active again