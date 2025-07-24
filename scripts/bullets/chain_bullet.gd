class_name ChainBullet
extends NewBullet

var in_range_enemies: Array[Enemy] = []
var chain_mode_enabled: bool = false

func _physics_process(delta):
	if is_active:
		if not chain_mode_enabled:
			ap.play("move")
			if target and target.is_alive:
				global_position = global_position + ((global_position.direction_to(target.global_position + _pos_offset)) * data.speed * delta)

			elif target and not target.is_alive:
				if global_position.distance_to(target_death_pos + _pos_offset) > _min_distance:
					global_position = global_position + ((global_position.direction_to(target_death_pos + _pos_offset)) * data.speed * delta)
				else:
					explode()
			else:
				# Don't want this one to blow up, just fizzle out. Maybe special animation?
				is_active = false
				queue_free()
		else:
			ap.play("chain")
			if target and target.is_alive:
				global_position = target.global_position + _pos_offset
			else:
				is_active = false
				queue_free()

func explode() -> void:
	is_active = false
	primary_collider.set_deferred("disabled", true) # unecessary ? 
	aoe_collider.set_deferred("disabled", false)
	ap.play("aoe_hit")

	# ?
	if not chain_mode_enabled:
			#.take_damage(damage, element)
			chain_mode_enabled = true

func on_primary_area_entered(intruder):
	if intruder == target:
		intruder.take_damage(data.damage, data.element)
		if not chain_mode_enabled:
			chain_mode_enabled = true
		explode()

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		if intruder != target and intruder not in in_range_enemies:
			if intruder.path_follow.progress_ratio < target.path_follow.progress_ratio:
				in_range_enemies.append(intruder)

# "hit" vs "aoe_hit" will need to be sorted out! Both could prob do the same thing 
func on_animation_finished(anim_name):
	if anim_name == "aoe_hit":
		order_targets()

		primary_collider.set_deferred("disabled", false) # unecessary ? 
		aoe_collider.set_deferred("disabled", true)

		is_active = true
		target = get_next_target()

func order_targets():
	in_range_enemies.sort_custom(compare_by_progress_ratio)

func get_next_target():
	var next_target: Enemy = null
	while not next_target and in_range_enemies.size() > 0:
		if in_range_enemies.size() > 0:
			next_target = in_range_enemies.pop_front()
		else: # qf if no more targets to move to
			queue_free()

	if next_target:
		return next_target
	else:
		queue_free()

func on_target_died(_pos):
	target_death_pos = _pos
	
func compare_by_progress_ratio(enemy_a: Enemy, enemy_b: Enemy) -> bool:
	return enemy_a.path_follow.progress_ratio > enemy_b.path_follow.progress_ratio