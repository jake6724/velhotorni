class_name SpellBulletAOE
extends SpellBullet

var num_explosions: int = 3
var explosions_complete_count: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var spell_element_damage_perk_modifier: float

var despawn_timer: Timer = Timer.new()
var scorchmark_sprites: Array[Sprite2D] = []

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/Spells/SpellExplosion.tscn")

func initialize(_data: SpellDataBullet, cast_direction: Vector2, _spell_element_damage_perk_modifier: float, _execution_threshold: float, _double_spell_mana_drop: bool, _perk_debuffs: Array[DebuffData], bullet_speed: float) -> void:
	data = _data
	original_position = global_position
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 
	spell_element_damage_perk_modifier = _spell_element_damage_perk_modifier # Need to save a reference for explosions
	set_damage(data, spell_element_damage_perk_modifier)

	execution_threshold = _execution_threshold
	double_spell_mana_drop = _double_spell_mana_drop
	perk_debuffs = _perk_debuffs
	texture = data.atlas
	speed = bullet_speed

	add_child(despawn_timer)
	despawn_timer.one_shot = true
	despawn_timer.autostart = false
	despawn_timer.timeout.connect(on_despawn_timer_timeout)

## Max distance check
func check_max_distance_reached() -> void:
	if active and abs(global_position.distance_to(original_position)) > data.max_distance:
		explode()

## Hit Enemy
func on_area_entered(_enemy: Enemy) -> void:
	explode()

## Hit Terrain Obstacle
func on_body_entered(_intruder) -> void:
	explode()

func explode() -> void:
	active = false
	collider.set_deferred("disabled", true)
	self_modulate.a = 0

	# Initialize spawn vars
	var angle = rng.randf_range(0, 360)
	var sign = [1,-1].pick_random()
	var angle_vector = Vector2.from_angle(angle).normalized()
	var radius: float = 0
	create_explosion(global_position, angle_vector, radius)

	for i in range(num_explosions):
		angle_vector = Vector2.from_angle(angle).normalized()	
		radius = randf_range(data.explosion_spawn_radius_min, data.explosion_spawn_radius_max)

		create_explosion(global_position, angle_vector, radius)

		var explosion_delay: float = rng.randf_range(0.01, 0.1)
		await get_tree().create_timer(explosion_delay).timeout

		angle += (360 * sign)

func create_explosion(center_point, angle_vector, radius) -> SpellExplosion:
	var new_explosion: SpellExplosion = EXPLOSION_SCENE.instantiate()
	new_explosion.initialize(data, spell_element_damage_perk_modifier)
	call_deferred("add_child",new_explosion)
	await new_explosion.ready
	new_explosion.explosion_complete.connect(on_child_explosion_complete)
	new_explosion.global_position = center_point + (angle_vector * radius)
	new_explosion.ap.play("explode")
	return new_explosion

func on_child_explosion_complete(scorchmark_sprite: Sprite2D) -> void:
	explosions_complete_count += 1
	scorchmark_sprites.append(scorchmark_sprite)
	if explosions_complete_count == num_explosions:
		despawn_timer.start(5)

func on_despawn_timer_timeout() -> void:
	# var fade_tween: Tween = get_tree().create_tween()
	# fade_tween.set_parallel(true)
	# fade_tween.tween_property(scorchmark_sprites[0], "modulate:a", 0, 1)
	# fade_tween.tween_property(scorchmark_sprites[1], "modulate:a", 0, 1)
	# fade_tween.tween_property(scorchmark_sprites[2], "modulate:a", 0, 1)
	# fade_tween.tween_property(scorchmark_sprites[3], "modulate:a", 0, 1)
	# await fade_tween.finished
	queue_free()
