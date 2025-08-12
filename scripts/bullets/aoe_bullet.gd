class_name AOEBullet
extends Bullet
func _physics_process(delta):
	if is_active:
		ap.play("move")
		# Target exists and is alive; move toward target an explode on collision
		if target and target.is_alive and not target.collider.disabled:
			global_position = global_position + ((global_position.direction_to(target.global_position + _pos_offset)) * data.speed * delta)

		# Target exists but is dead; move toward death location and explode upon reaching
		elif target and not target.is_alive:
			if global_position.distance_to(target_death_pos + _pos_offset) > _min_distance:
				global_position = global_position + ((global_position.direction_to(target_death_pos + _pos_offset)) * data.speed * delta)
			else:
				explode()

		# Target does not exist, explode immeadiately
		else:
			explode()

func on_primary_area_entered(intruder):
	if intruder == target:
		explode()

func explode() -> void:
	is_active = false
	primary_collider.set_deferred("disabled", true)
	aoe_collider.set_deferred("disabled", false)
	ap.play("aoe_hit")

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		intruder.take_damage(data.damage, data.element)
		if data.debuff_data and intruder.debuff_manager:
				intruder.debuff_manager.add_debuff(data.debuff_data)
	
func on_animation_finished(anim_name):
	if anim_name == "aoe_hit":
		queue_free()

func on_target_died(_pos):
	target_death_pos = _pos