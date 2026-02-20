class_name FlyingEnemy
extends Enemy

# Soft-collision avoidance guide: https://www.youtube.com/watch?v=ffXx0dPejWY

@onready var push_area: Area2D = %PushArea

var player: PlayerCharacter
var spawn_pos: Vector2

var frame_counter: int = 0
const FRAME_COUNT_THRESHOLD: int = 0

var reset_attack_timer: Timer = Timer.new()
var reset_attack: bool = false

const PUSH_VECTOR_INFLUENCE: float = .5
const RESET_DISTANCE_THRESHOLD: float = 100.0

var angle: float = 0.0
var rotation_speed: float = 2.0
var radius: float = 10
var speed_reset_value: float

func flying_enemy_ready() -> void:
	reset_attack_timer.one_shot = true
	reset_attack_timer.autostart = false
	add_child(reset_attack_timer)
	reset_attack_timer.timeout.connect(on_reset_attack_timer_timeout)

## Called by EnemySpawner after add_child has been called with FlyingEnemy
func initialize() -> void:
	player.player_hurtbox.hurtbox_enabled.connect(on_player_hurtbox_enabled)
	player.player_hurtbox.hurtbox_disabled.connect(on_player_hurtbox_disabled)

func get_push_vector() -> Vector2:
	var areas = push_area.get_overlapping_areas()
	var push_vector: Vector2 = Vector2.ZERO
	if areas.size() > 0:
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)	
	return push_vector

## Move to player
func move(delta) -> void:
	frame_counter += 1
	if frame_counter >= FRAME_COUNT_THRESHOLD:
		frame_counter = 0
		if is_alive:
			if not is_frozen and not is_stunned:
				if not is_taking_damage:
					ap.play("walk")

				var direction = global_position.direction_to(player.global_position)
				sprite.flip_h = direction.x < 0

				if reset_attack:
					direction = -direction
					# var offset = player.global_position + Vector2(cos(angle), sin(angle)) * radius
					# print(offset)
					# global_position = offset

				global_position += direction.round().normalized() * speed * delta
				global_position += get_push_vector() * PUSH_VECTOR_INFLUENCE

		else:
				ap.play("idle")

func on_player_hurtbox_enabled() -> void:
	reset_attack = false
	speed = data.speed

func on_player_hurtbox_disabled() -> void:
	# time = distance / speed
	# Only reset attack of FlyingEnemies who could reach the player in time to damage them
	var distance_to_player: float = global_position.distance_to(player.global_position)
	var time_to_reach_player = distance_to_player / speed
	if time_to_reach_player <= player.player_stats.hurtbox_iframe_duration:
		reset_attack = true
		speed *= .1

func on_reset_attack_timer_timeout() -> void:
	reset_attack = false

func on_debuff_apply_knockback(_value, _total_duration) -> void:
	pass

func on_debuff_remove_knockback() -> void:
	pass
