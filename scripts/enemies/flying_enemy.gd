class_name FlyingEnemy
extends Enemy

# Soft-collision avoidance guide: https://www.youtube.com/watch?v=ffXx0dPejWY

@onready var push_area: Area2D = %PushArea

var player: PlayerCharacter
var spawn_pos: Vector2

var reset_attack_timer: Timer = Timer.new()
var reset_attack: bool = false

const PUSH_VECTOR_INFLUENCE: float = .5

func flying_enemy_ready() -> void:
	reset_attack_timer.one_shot = true
	reset_attack_timer.autostart = false
	add_child(reset_attack_timer)
	reset_attack_timer.timeout.connect(on_reset_attack_timer_timeout)

func get_push_vector() -> Vector2:
	var areas = push_area.get_overlapping_areas()
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

			if reset_attack:
				direction = -direction
			
			global_position += direction.round().normalized() * data.speed * delta
			global_position += get_push_vector() * PUSH_VECTOR_INFLUENCE
			


	else:
			ap.play("idle")

func on_reset_attack_timer_timeout() -> void:
	reset_attack = false

func on_debuff_apply_knockback(_value, _total_duration) -> void:
	pass

func on_debuff_remove_knockback() -> void:
	pass