class_name InstantBullet
extends Bullet

func _ready() -> void:
	# Configure children
	primary_area.area_entered.connect(on_primary_area_entered)
	aoe_area.area_entered.connect(on_aoe_area_entered)
	aoe_collider.disabled = true
	ap.animation_finished.connect(on_animation_finished)
	global_position = target.global_position

func on_primary_area_entered(intruder) -> void:
	if intruder is Enemy and intruder == target:
		is_active = false
		intruder.apply_drop_chance_bonus(data.drop_chance_bonus)
		intruder.take_damage(data.damage, data.element)
		if data.debuff_data and intruder.debuff_manager:
				intruder.debuff_manager.add_debuff(data.debuff_data)
		ap.play("hit")

func on_animation_finished(anim_name):
	if anim_name == "hit":
		queue_free()
