class_name TargetDummy extends Enemy

func move(delta) -> void:
	pass
	
func respawn() -> void:
	health = data.health

	show()
	ap.play_backwards("die")
	await ap.animation_finished
	ap.play("idle")

	is_alive = true
	collider.set_deferred("disabled", false) 
	z_index = Constants.z_index_map["enemy_spawner"]

func die() -> void:
	is_alive = false

	collider.set_deferred("disabled", true) 
	debuff_manager.remove_all_debuffs()

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()

	z_index = Constants.z_index_map["enemy_corpse"]
	boon_area.can_show_boon_range = false


	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ENEMY_DEATH_FLESH)
	ap.play("die")
	await ap.animation_finished
	ap.play("corpse")

	hide_all_fx() # Somehow, the burn fx can turn back on. The debuff not seem to be active, just the fx. Ensure it is off

	await get_tree().create_timer(1).timeout
	respawn()


func on_animation_finished(anim_name):
	if anim_name == "hit":
		is_taking_damage = false

