class_name AOEBullet
extends Bullet
func _physics_process(delta):
	if is_active:
		ap.play("move")
		# Target exists and is alive; move toward target an explode on collision
		if (target and target.is_alive): #and not target.collider.disabled: 
			global_position = global_position + ((global_position.direction_to(target.global_position + _pos_offset)) * data.speed * delta)

		# Target exists but is dead; move toward death location and explode upon reaching
		elif target:
			if not target.is_alive:
					# print("target:", target, " - target_death_pos: ", target_death_pos)
				# if not target.collider.disabled: # collider is NOT disabled
					if global_position.distance_to(target.death_global_position + _pos_offset) > _min_distance:
						global_position = global_position + ((global_position.direction_to(target.death_global_position  + _pos_offset)) * data.speed * delta)
					else:
						explode()
				# else:
				# 	print("target.collider.disabled = true")
			else:
				print("Target.is_alive = false")

		# Target does not exist, queue free immeadiately
		else:
			queue_free()

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

func on_target_died(enemy_death_pos: Vector2):
	target_death_pos = enemy_death_pos
	print("BULLET SAYS ENEMY DIED - ", target_death_pos)
