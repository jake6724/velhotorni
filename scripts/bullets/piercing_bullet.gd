class_name PiercingBullet
extends NewBullet

var _enemies_hit: int = 0

func _physics_process(delta):
	if is_active:
		ap.play("move")
		global_position += data.speed * _target_direction * delta
			
		if global_position.distance_to(_original_global_position) >= data.max_distance:
			is_active = false
			ap.play("hit")

func on_primary_area_entered(intruder) -> void:
	if is_active:
		if intruder is Enemy:
			intruder.take_damage(data.damage, data.element)
			_enemies_hit += 1

		if _enemies_hit >= data.max_pierce:
			is_active = false
			ap.play("hit")

func on_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()