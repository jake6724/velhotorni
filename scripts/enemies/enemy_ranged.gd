class_name EnemyRanged
extends Enemy

@onready var attack_area: Area2D = $AttackArea
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

	attack_area.body_entered.connect(on_body_entered)

func on_body_entered(player: PlayerCharacter) -> void:
	print(player)
	print("Can attack: ", can_attack)
	if can_attack:
		attack_player(player.global_position)

func attack_player(player_pos: Vector2) -> void:
	print("Attack called")
	spawn_enemy_bullet(player_pos)

	burst_count += 1
	if burst_count >= data.burst_max:
		burst_count = 0
		attack_timer.start(data.attack_cooldown)
	else:
		attack_timer.start(data.burst_cooldown)

func spawn_enemy_bullet(player_pos: Vector2) -> void:
	var new_enemy_bullet: EnemyBullet = enemy_bullet_scene.instantiate()
	enemy_bullet_parent.call_deferred("add_child", new_enemy_bullet)
	new_enemy_bullet.call_deferred("initialize", player_pos, global_position, data.bullet_damage, data.bullet_speed, data.bullet_max_distance,
	data.bullet_follow_on_hit, z_index + 1, data.bullet_atlas)

func check_player_in_range() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	if bodies.size() and bodies[0] is PlayerCharacter:
		attack_player(bodies[0].global_position)

func on_attack_timer_timeout() -> void:
	can_attack = true
	check_player_in_range()
