class_name PulseBullet
extends Bullet

func _physics_process(_delta):
	if is_active:
		is_active = false
		ap.play("pulse")

func on_aoe_area_entered(intruder):
	if intruder is Enemy:
		intruder.take_damage(data.damage, data.element)
		if data.debuff_data and intruder.debuff_manager:
				intruder.debuff_manager.add_debuff(data.debuff_data)

func on_animation_finished(anim_name):
	if anim_name == "pulse":
		queue_free()

func enable_aoe_collider() -> void:
	aoe_collider.set_deferred("disabled", false)
