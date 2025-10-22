class_name EnemyRanged
extends Enemy

@onready var attack_area: Area2D = $AttackArea
@onready var attack_collider: CollisionShape2D = %AttackCollider
@onready var enemy_bullet_parent: Node = $EnemyBulletParent

var attack_timer: Timer = Timer.new()
var burst_count: int = 0
var can_attack: bool = true
var enemy_bullet_scene: PackedScene = preload("res://scenes/bullets/enemy_bullets/EnemyBullet.tscn")

func configure_ranged_enemy() -> void:
	attack_timer.autostart = false
	attack_timer.one_shot = true
	attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)
	attack_area.area_entered.connect(on_area_entered)
	attack_collider.shape.radius = data.attack_range

func on_area_entered(player_beacon: PlayerBeacon) -> void:
	if can_attack:
		attack_player(player_beacon.global_position)

func on_attack_timer_timeout() -> void:
	can_attack = true
	check_player_in_range()

func check_player_in_range() -> void:
	var areas = attack_area.get_overlapping_areas()
	if areas.size() and areas[0] is PlayerBeacon:
		attack_player(areas[0].global_position)

func attack_player(player_pos: Vector2) -> void:
	if is_alive and can_attack:
		spawn_all_bullets(player_pos)
		can_attack = false
		burst_count += 1
		if burst_count >= data.num_bursts:
			burst_count = 0
			attack_timer.start(data.attack_cooldown)
		else:
			attack_timer.start(data.burst_cooldown)

func spawn_all_bullets(player_pos: Vector2) -> void:
	var angle_sign: float = 1
	var angle_increment: float = data.angle_increment
	var spawn_pos: Vector2 = global_position + Vector2(8,8)
	var base_direction: Vector2 = spawn_pos.direction_to(player_pos)
	if data.spawn_center_bullet:
		# Spawn the first bullet which always travels directly at the player
		spawn_enemy_bullet(base_direction, spawn_pos)

	for i in range(data.num_bullets_per_burst - 1):
		var angle_modifier: float = angle_increment * angle_sign
		var direction = base_direction.rotated(deg_to_rad(angle_modifier))
		spawn_enemy_bullet(direction, spawn_pos)

		if i % 2 == 1:
			angle_increment += data.angle_increment
		angle_sign = -angle_sign
		# angle_increment += data.angle_increment

func spawn_enemy_bullet(direction: Vector2, spawn_pos) -> void:
	var new_enemy_bullet: EnemyBullet = enemy_bullet_scene.instantiate()
	enemy_bullet_parent.call_deferred("add_child", new_enemy_bullet)
	new_enemy_bullet.call_deferred("initialize", direction, spawn_pos, data.bullet_damage, data.bullet_speed, data.bullet_max_distance,
	z_index + 1, data.bullet_atlas)