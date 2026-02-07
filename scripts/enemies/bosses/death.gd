class_name Death
extends EnemyBoss

@export var player: PlayerCharacter

@onready var enemy_bullet_parent = %EnemyBulletParent

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var spawn_timer: Timer = Timer.new()
var attack_timer: Timer = Timer.new()

var attacking: bool = true

const MIN_SPAWN_DISTANCE_FROM_PLAYER: float = 64
const MAX_SPAWN_DISTANCE_FROM_PLAYER: float = 128

const BULLET_SCENE = preload("res://scenes/bullets/enemy_bullets/EnemyBulletDeath.tscn")

func boss_initialize() -> void:

	attack_timer.autostart = false
	attack_timer.one_shot = true
	attack_timer.timeout.connect(on_attack_timer_timeout)
	add_child(attack_timer)

	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start(rng.randf_range(1,3))
	hide()

func _physics_process(delta):
	face_player()
	queue_redraw()

func move(delta) -> void:
	pass

func on_spawn_timer_timeout() -> void:
	global_position = get_spawn_position()
	show()
	ap.play("spawn")
	await ap.animation_finished
	# ap.play("idle")
	# await ap.animation_finished
	ap.play("ranged_attack_start")
	# await ap.animation_finished
	# ap.play("idle")
	# await get_tree().create_timer(1).timeout
	# ap.play("spawn", -1, -1.0, true)
	# await ap.animation_finished
	# hide()
	# spawn_timer.start(rng.randf_range(1,3))

func on_attack_timer_timeout() -> void:
	pass

func get_spawn_position() -> Vector2:
	var distance_from_player: float = rng.randf_range(MIN_SPAWN_DISTANCE_FROM_PLAYER, MAX_SPAWN_DISTANCE_FROM_PLAYER)
	var spawn_angle: Vector2 = Vector2(rng.randf_range(-1,1), rng.randf_range(-1,1))
	var spawn_position = player.global_position + (distance_from_player * spawn_angle)
	return spawn_position

func on_debuff_apply_knockback(_value, _total_duration) -> void:
	pass

func on_debuff_remove_knockback() -> void:
	pass

func _draw() -> void:
	draw_circle(to_local(player.global_position), 3, Color.RED, true)

## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
## Returns the amount of damage actually received (after calculating resistances and other modifiers)
func take_damage(damage_recieved: float, tower_element: Constants.Element, execution_threshold_recieved: float, _double_spell_mana_drop: bool) -> float:
	if is_alive:
		is_taking_damage = true
		if not attacking:
			ap.play("hit")
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_FLESH)
		# Hit by same element
		if tower_element == data.element:
			damage_recieved *= negative_modifier

		if not health_bar.is_visible():
			health_bar.show()

		# Apply Weaken modifier
		damage_recieved = damage_recieved + (damage_recieved * (weaken_percent/100))
		# number_popup.display_damage_number(damage_recieved, global_position)

		var damage_applied: float = min(health, damage_recieved)

		health = max(0, health - damage_recieved)

		if is_boss: enemy_damage_recieved.emit(damage_recieved)
		if health <= 0:
			if _double_spell_mana_drop:
				spell_mana_drop_chance *= 2
			die()
		# Check if should execute
		elif (health / max_health) <= execution_threshold_recieved:
			if _double_spell_mana_drop:
				spell_mana_drop_chance *= 2
			die()

		return damage_applied
	else:
		return 0

func face_player() -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	sprite.flip_h = direction.x < 0

func spawn_enemy_bullet(direction: Vector2 = Vector2.ZERO, spawn_pos = Vector2.ZERO) -> void:
	direction = global_position.direction_to(player.global_position)
	spawn_pos = global_position
	var new_enemy_bullet: EnemyBulletBossDeath = BULLET_SCENE.instantiate()
	new_enemy_bullet.hide()
	enemy_bullet_parent.call_deferred("add_child", new_enemy_bullet)
	new_enemy_bullet.call_deferred("initialize", direction, spawn_pos, data.bullet_damage, data.bullet_speed, data.bullet_max_distance,
	4096, CompressedTexture2D.new())
	new_enemy_bullet.bullet_returned.connect(on_bullet_returned)

func on_bullet_returned() -> void:
	ap.play("ranged_attack_end")
	await ap.animation_finished
	ap.play("spawn", -1, -1.0, true)
	await ap.animation_finished
	hide()
	spawn_timer.start(rng.randf_range(1,3))
