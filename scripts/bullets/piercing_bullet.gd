class_name PiercingBullet
extends Bullet

var _enemies_hit: int = 0

func _physics_process(delta):
	if is_active:
		ap.play("move")
		global_position += data.speed * _target_direction * delta
			
	if global_position.distance_to(_original_global_position) >= data.max_distance:
		is_active = false
		ap.play("hit")

func on_primary_area_entered(intruder) -> void:
	print(intruder)
	if is_active and _enemies_hit < data.pierce:
		if intruder is Enemy:
			intruder.apply_drop_chance_bonus(data.drop_chance_bonus)
			intruder.take_damage(data.damage, data.element, 0.0, false, data.damage_source)
			if data.debuff_data and intruder.debuff_manager:
				intruder.debuff_manager.add_debuff(data.debuff_data)

			_enemies_hit += 1

		if _enemies_hit >= data.pierce:
			is_active = false
			ap.play("hit")

func on_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()