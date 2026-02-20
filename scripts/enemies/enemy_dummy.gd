class_name EnemyDummy
extends Enemy

const REGENERATE_DELAY: float = 1.5

func move(delta) -> void:
	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				ap.play("walk")

			sprite.flip_h = path_follow.rotation_degrees >= 91
			path_follow.progress += (speed - ((speed * (slow_percent/100)))) * delta
			moving_horizontally = is_moving_horizontally(path_follow.rotation_degrees)

		else:
			ap.play("idle")

	debuff_manager.enemy_progress = path_follow.progress

## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
## Returns the amount of damage actually received (after calculating resistances and other modifiers)
func take_damage(damage_recieved: float, tower_element: Constants.Element, _execution_threshold_recieved: float = 0.0, _double_spell_mana_drop=false) -> float:
	if is_alive:
		is_taking_damage = true
		ap.play("hit")

		# Hit by same element
		if tower_element == data.element:
			damage_recieved *= negative_modifier

		if not health_bar.is_visible():
			health_bar.show()

		# Apply Weaken modifier
		damage_recieved = damage_recieved + (damage_recieved * (weaken_percent/100))

		number_popup.display_damage_number(damage_recieved, global_position, moving_horizontally, true)

		var damage_applied: float = min(health, damage_recieved)

		health = max(0, health - damage_recieved)

		if is_boss: enemy_damage_recieved.emit(damage_recieved)
		if health <= 0: regenerate()

		return damage_applied
	else:
		return 0

func regenerate() -> void:
	await get_tree().create_timer(REGENERATE_DELAY).timeout
	health = max_health
