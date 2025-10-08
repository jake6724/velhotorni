class_name FlyingEnemy
extends Enemy

# Soft-collision avoidance guide: https://www.youtube.com/watch?v=ffXx0dPejWY

var player: PlayerCharacter
var spawn_pos: Vector2

func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	var push_vector: Vector2 = Vector2.ZERO
	if areas.size() > 0:
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)	
	return push_vector

## Move to player
func move(delta) -> void:
	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				ap.play("walk")
		
			var direction = global_position.direction_to(player.global_position)
			sprite.flip_h = direction.x < 0
			global_position += direction.round().normalized() * data.speed * delta
			global_position += get_push_vector() * .5
	else:
			ap.play("idle")
