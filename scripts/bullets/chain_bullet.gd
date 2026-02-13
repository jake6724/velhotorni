class_name ChainBullet
extends Bullet

var in_range_enemies: Array[Enemy] = []
var chain_mode_enabled: bool = false
var chain_count: int = 0
const CHAIN_MAX: int = 8

func _physics_process(delta):
	if is_active:
		if not chain_mode_enabled:
			ap.play("move")
			# Target exists and is alive; move toward target an start chain on collision
			if target and target.is_alive and not target.collider.disabled:
				global_position = global_position + ((global_position.direction_to(target.global_position + _pos_offset)) * data.speed * delta)

			# Target exists but is dead; move toward death location and chain upon colliding with a living enemy
			elif target and not target.is_alive:
				if global_position.distance_to(target_death_pos + _pos_offset) > _min_distance:
					global_position = global_position + ((global_position.direction_to(target_death_pos + _pos_offset)) * data.speed * delta)
				else:
					explode()

			# Target does not exist; disappear immediately
			else:
				is_active = false
				queue_free()
		
		# Chain mode enabled
		else:
			ap.play("chain")
			if target and target.is_alive:
				global_position = target.global_position + _pos_offset
			else:
				is_active = false
				queue_free()

func explode() -> void:
	is_active = false
	primary_collider.set_deferred("disabled", true)
	aoe_collider.set_deferred("disabled", false)
	ap.play("chain_hit")

	if not chain_mode_enabled:
		chain_mode_enabled = true

func on_primary_area_entered(intruder):
	if intruder == target:
		intruder.apply_drop_chance_bonus(data.drop_chance_bonus)
		intruder.take_damage(data.damage, data.element, 0.0, false)
		if data.debuff_data and intruder.debuff_manager:
				intruder.debuff_manager.add_debuff(data.debuff_data)

		if not chain_mode_enabled:
			chain_mode_enabled = true
		explode()

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		if intruder != target and intruder not in in_range_enemies:
			if intruder.path_follow.progress_ratio < target.path_follow.progress_ratio:
				in_range_enemies.append(intruder)

func on_animation_finished(anim_name):
	if anim_name == "chain_hit":
		order_targets()

		primary_collider.set_deferred("disabled", false) # unecessary ? 
		aoe_collider.set_deferred("disabled", true)

		is_active = true
		target = get_next_target()

func order_targets():
	if in_range_enemies.size() > 1:
		in_range_enemies.sort_custom(compare_by_progress_ratio)

func get_next_target():
	chain_count += 1
	if chain_count < CHAIN_MAX:
		var next_target: Enemy = null
		while not next_target and in_range_enemies.size() > 0:	
			next_target = in_range_enemies.pop_front()

		if next_target:
			return next_target
		else:
			queue_free()
	else:
		queue_free()

func on_target_died(_pos):
	target_death_pos = _pos
	
func compare_by_progress_ratio(enemy_a: Enemy, enemy_b: Enemy) -> bool:
	return enemy_a.path_follow.progress_ratio > enemy_b.path_follow.progress_ratio
