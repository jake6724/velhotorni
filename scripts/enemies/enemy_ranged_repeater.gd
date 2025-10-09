class_name EnemyRangedRepeater
extends Enemy

@onready var enemy_bullet_parent: Node = $EnemyBulletParent
var attack_timer: Timer = Timer.new()
var enemy_bullet_scene: PackedScene = preload("res://scenes/bullets/enemy_bullets/EnemyBullet.tscn")
var burst_count: int = 0
var start_angle: float
var bullet_speed: float

func configure_ranged_enemy() -> void:
	attack_timer.autostart = false
	attack_timer.one_shot = true
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)
	attack_timer.start(data.initial_delay)
	start_angle = data.start_angle

func on_attack_timer_timeout() -> void:
	if is_alive:
		spawn_all_bullets()
		burst_count += 1
		if burst_count >= data.num_bursts:
			attack_timer.start(data.attack_cooldown)
			burst_count = 0
			start_angle = data.start_angle
			bullet_speed = data.bullet_speed
		else:
			attack_timer.start(data.burst_cooldown)
			start_angle += data.burst_angle_increment
			bullet_speed += data.burst_bullet_speed_increment

func spawn_all_bullets() -> void:
	var curr_angle: float = start_angle
	var spawn_pos: Vector2 = global_position + Vector2(8,8)

	for i in range(data.num_bullets_per_burst):
		var direction = Vector2.from_angle(deg_to_rad(curr_angle))
		spawn_enemy_bullet(direction, spawn_pos)
		curr_angle += data.angle_increment

func spawn_enemy_bullet(direction: Vector2, spawn_pos) -> void:
	var new_enemy_bullet: EnemyBullet = enemy_bullet_scene.instantiate()
	enemy_bullet_parent.call_deferred("add_child", new_enemy_bullet)
	new_enemy_bullet.call_deferred("initialize", direction, spawn_pos, bullet_speed, data.bullet_max_distance,
	z_index + 1, data.bullet_atlas)
