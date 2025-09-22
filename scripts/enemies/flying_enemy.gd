class_name FlyingEnemy
extends Enemy

# var player: PlayerCharacter # For now just get a hard ref. Later maybe use detection of some kind ? 

func move(delta) -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)

	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				ap.play("walk")

			sprite.flip_h = direction.x < .5
			global_position += ((speed - ((speed * (slow_percent/100)))) * delta) * direction

func _physics_process(delta):
	if is_alive:
		move(delta)
