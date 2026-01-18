class_name TowerHurtbox
extends Area2D

@onready var tower: Tower = get_owner()
var reflect_chance: float
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const REFLECT_SPEED_MULTIPLIER: float = 1.2
const REFLECT_DAMAGE_MULTIPLIER: float = 5.0

signal hit

func initialize(data: TowerData) -> void:
	reflect_chance = data.reflect_chance

func take_damage(_damage, enemy_bullet: EnemyBullet) -> bool:
	if tower.alive:
		if rng.randf() < (reflect_chance + TowerGlobalData.reflect_chance):
			reflect_bullet(enemy_bullet)
			return false
		else:
			hit.emit(_damage)
			return true
	return true

func reflect_bullet(bullet: EnemyBullet) -> void:
	# Invert bullet direction
	bullet.direction = global_position.direction_to(bullet.global_position)

	# Increase bullet damage
	bullet.damage *= REFLECT_DAMAGE_MULTIPLIER
	bullet.speed *= REFLECT_SPEED_MULTIPLIER

	# Change bullet collision layer to see enemies and ignore player 
	bullet.collision_area.set_collision_mask_value(4,false) # Ignore tower hurtbox
	bullet.collision_area.set_collision_mask_value(17,false) # Ignore player hurtbox
	bullet.collision_area.set_collision_mask_value(21,false) # Ignore smelee spell
	bullet.collision_area.set_collision_mask_value.call_deferred(5,true) # see enemies

	bullet.active = true # Make bullet active again
