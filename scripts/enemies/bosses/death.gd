class_name Death
extends EnemyBoss

@export var player: PlayerCharacter

@onready var enemy_bullet_parent = %EnemyBulletParent

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var idle_timer: Timer = Timer.new()
var is_pre_attack_idle: bool

var spawn_timer: Timer = Timer.new()

var attacking: bool = true

var BULLET_SCENE = load("res://scenes/bullets/enemy_bullets/EnemyBulletDeath.tscn")
var KRASUE_SPAWN = load("uid://bwulu1o4kofy2")

var melee_dash_direction: Vector2
var melee_attack_active: bool = false
var melee_attack_timer: Timer = Timer.new()
var melee_attack_chance: float = .5 # Start lower

var attack_chances = [
	["melee_attack_start", 0],
	["ranged_attack_start", 0],
	["summon", 0],
]

# State vars
var active_attack_animation_name: String
var phase: int = 0

func boss_initialize() -> void:
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start(rng.randf_range(data.min_spawn_time, data.max_spawn_time))
	hide()

	melee_attack_timer.autostart = false
	melee_attack_timer.one_shot = true
	melee_attack_timer.timeout.connect(on_melee_attack_timer_timeout)
	add_child(melee_attack_timer)

	idle_timer.autostart = false
	idle_timer.one_shot = true
	idle_timer.timeout.connect(on_idle_timer_timeout)
	add_child(idle_timer)

	attack_chances[0][1] = data.melee_attack_chance
	attack_chances[1][1] = data.ranged_attack_chance
	attack_chances[2][1] = data.summon_attack_chance

func _physics_process(delta):
	if is_alive:
		if melee_attack_active:
			global_position += melee_dash_direction * data.melee_attack_dash_power * delta
		else:
			face_player()

func on_spawn_timer_timeout() -> void:
	if is_alive:
		var attack_info: Array = get_attack_info()
		active_attack_animation_name = attack_info[0]
		global_position = attack_info[1]
		show()
		ap.play("spawn")
		await ap.animation_finished
		collider.set_deferred("disabled", false)
		ap.play("idle")
		is_pre_attack_idle = true
		var idle_time = get_idle_time()
		idle_timer.start(idle_time)

func get_ranged_spawn_position() -> Vector2:
	var distance_from_player: float = rng.randf_range(data.min_ranged_spawn_distance, data.max_ranged_spawn_distance)
	var spawn_angle: Vector2 = Vector2(rng.randf_range(-1,1), rng.randf_range(-1,1))
	var spawn_position = player.global_position + (distance_from_player * spawn_angle)
	return spawn_position

func get_melee_spawn_position() -> Vector2:
	var x = randf_range(-data.melee_spawn_distance_range_x, data.melee_spawn_distance_range_x)
	var y = randf_range(-data.melee_spawn_distance_range_y, data.melee_spawn_distance_range_y)
	x = sign(x) * max(abs(x), data.min_melee_spawn_distance_x)
	y = sign(y) * max(abs(y), data.min_melee_spawn_distance_y)
	var spawn_position = player.global_position + Vector2(x, y)
	return spawn_position

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

func start_melee_attack() -> void:
	# face_player()
	melee_dash_direction = global_position.direction_to(player.global_position)
	melee_attack_active = true
	melee_attack_timer.start(data.melee_attack_dash_duration)

func on_melee_attack_timer_timeout() -> void:
	melee_attack_active = false
	melee_dash_direction = Vector2.ZERO

	# TODO: Add melee attack end

	# Run post-attack idle
	ap.play("idle")
	var idle_time = get_idle_time()
	idle_timer.start(idle_time)

func summon_minions() -> void:

	var r: float = 30.0
	var a: float = 60.0
	var t: float = 0.0
	for i in range(6):
		var offset: Vector2 = Vector2(r * cos(t), r * sin(t))
		EnemySpawner.spawn_enemy(KRASUE_SPAWN, global_position + offset)
		t += a
		await get_tree().create_timer(.05).timeout


func end_summon() -> void:
	# Run post-attack idle
	ap.play("idle")
	var idle_time = get_idle_time()
	idle_timer.start(idle_time)

func on_bullet_returned() -> void:
	ap.play("ranged_attack_end")
	await ap.animation_finished

	# Run post-attack idle
	ap.play("idle")
	var idle_time = get_idle_time()
	idle_timer.start(idle_time)

func set_boss_phase() -> void:
	if health <= (max_health * .5) and phase < 1:
		phase = 1
		data.melee_attack_dash_power = data.melee_attack_dash_power * 1.75
		data.melee_attack_dash_duration = data.melee_attack_dash_duration * .6
		data.bullet_speed = data.bullet_speed * 1.5

func get_attack_info() -> Array:
	var animation_name: String = Constants.get_weighted_random(attack_chances)
	match animation_name:
		"melee_attack_start": return [animation_name, get_melee_spawn_position()]
		"ranged_attack_start": return [animation_name, get_ranged_spawn_position()]
		"summon": return [animation_name, get_ranged_spawn_position()]
		_:
			push_error("Death.get_attack_info() failed to return a valid animation name: ", animation_name)
			return []

func on_idle_timer_timeout() -> void:
	if is_pre_attack_idle:
		is_pre_attack_idle = false
		ap.play(active_attack_animation_name)
	else:
		ap.play("spawn", -1, -1.0, true)
		await ap.animation_finished
		hide()
		spawn_timer.start(rng.randf_range(data.min_spawn_time, data.max_spawn_time))
		collider.set_deferred("disabled", true)

func get_idle_time() -> float:
	return rng.randf_range(data.min_idle_time, data.max_idle_time)

func sprite_flash() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate:v", 1, 0.1).from(15)
		
## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
## Returns the amount of damage actually received (after calculating resistances and other modifiers)
func take_damage(damage_recieved: float, tower_element: Constants.Element, execution_threshold_recieved: float, _double_spell_mana_drop: bool, damage_source: Variant=null) -> float:
	if is_alive:
		is_taking_damage = true

		sprite_flash()

		# if not attacking:
		# 	ap.play("hit")
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

		set_boss_phase()

		return damage_applied
	else:
		return 0

func die() -> void:
	is_alive = false

	spawn_timer.stop()

	# Update immediatedly required death properties
	died.emit(self)
	death_position.emit(global_position)
	coin_dropped.emit(global_position, drop_chance)

	collider.set_deferred("disabled", true) 
	debuff_manager.remove_all_debuffs()

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()
	z_index = Constants.z_index_map["enemy_corpse"]

	# SFXPlayer.play_sfx_resource(data.explosion_sfx)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.ENEMY_DEATH_FLESH)
	ap.play("die")
	

	light.visible = false

	# Give time for collision boons and hexes to be removed
	boon_collider.set_deferred("disabled", true)
	indicator.can_show_boon_range = false
	hex_collider.set_deferred("disabled", true)
	indicator.can_show_hex_range = false
	await get_tree().create_timer(.1).timeout

	hide_all_fx() # Somehow, the burn fx can turn back on. The debuff not seem to be active, just the fx. Ensure it is off

func on_animation_finished(anim_name):
	if anim_name == "hit":
		is_taking_damage = false

	if anim_name == "die":
		sprite.z_index = -sprite.z_index
		queue_free()

# Un-unsed overwritten funcs from parent class
func move(_delta) -> void:
	pass

func on_debuff_apply_knockback(_value, _total_duration) -> void:
	pass

func on_debuff_remove_knockback() -> void:
	pass
