class_name EnemyBulletBossDeath
extends EnemyBullet

var returning: bool = false

signal bullet_returned

func _ready():
	collision_area.body_entered.connect(on_body_entered)
	collision_area.area_entered.connect(on_area_entered)
	ap.animation_finished.connect(on_animation_finished)
	hide()

func initialize(_direction: Vector2, _spawn_pos: Vector2, _damage: int, _speed: float, _max_distance: float, _z_index: int, _atlas: CompressedTexture2D) -> void:
	damage = _damage
	speed = _speed
	max_distance = _max_distance
	spawn_pos = _spawn_pos
	global_position = _spawn_pos
	z_index = _z_index
	direction = _direction
	ap.play("move")
	await get_tree().create_timer(.001).timeout # 
	show()

func _physics_process(delta) -> void:
	move(delta)

func move(delta) -> void:
	if active:
		global_position += direction * speed * delta
		if global_position.distance_to(spawn_pos) > max_distance:
			if not returning:
				returning = true
				direction = -direction
				# ap.play("hit")
		
		if returning and global_position.distance_to(spawn_pos) <= 1:
			bullet_returned.emit()
			queue_free()

## Used to collide with terrain obstacles
func on_body_entered(_intruder) -> void:
	pass
	# active = false
	# ap.play("hit")

## Used to collide with and damage player, tower, or enemy if reflected
func on_area_entered(intruder: Area2D) -> void:
	if active:
		# active = false
		if intruder is PlayerHurtbox:
			var damage_received = intruder.take_bullet_damage(1, global_position, self)
			if not damage_received:
				return 

		if intruder is TowerHurtbox:
			var damage_received = intruder.take_damage(damage, self)
			if not damage_received:
				return

		if intruder is Enemy:
			intruder.take_damage(damage, Constants.Element.ARCANE, 0.0, false) # Reflected bullets deal Arcane

		if intruder.owner is SpellShield:
			intruder.owner.take_damage(damage)
			active = false

		if intruder is TowerShield:
			intruder.take_damage(damage)
			active = false

		# ap.play("hit")

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		queue_free()
