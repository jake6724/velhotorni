class_name EnemyBullet
extends Sprite2D

@onready var collision_area: Area2D = $CollisionArea
@onready var ap: AnimationPlayer = $AnimationPlayer

var active: bool = true
var direction: Vector2
var spawn_pos: Vector2
var player_pos: Vector2 = Vector2.ZERO
var damage: float
var speed: float
var max_distance: float
var follow_on_hit: bool

func _ready():
	collision_area.body_entered.connect(on_body_entered)
	collision_area.area_entered.connect(on_area_entered)
	ap.animation_finished.connect(on_animation_finished)

func initialize(_direction: Vector2, _spawn_pos: Vector2, _damage: int, _speed: float, _max_distance: float, _z_index: int, atlas: CompressedTexture2D) -> void:
	damage = _damage
	speed = _speed
	max_distance = _max_distance
	spawn_pos = _spawn_pos
	global_position = _spawn_pos
	self.texture = atlas
	z_index = _z_index
	direction = _direction
	ap.play("move")

func _physics_process(delta) -> void:
	move(delta)

func move(delta) -> void:
	if active:
		global_position += direction * speed * delta
		if global_position.distance_to(spawn_pos) > max_distance:
			active = false
			ap.play("hit")

## Used to collide with terrain obstacles
func on_body_entered(_intruder) -> void:
	active = false
	ap.play("hit")

## Used to collide with and damage player, tower, or enemy if reflected
func on_area_entered(intruder: Area2D) -> void:
	print("Collision detected with: ", intruder)
	active = false
	if intruder is PlayerHurtbox:
		var damage_received = intruder.take_bullet_damage(1, global_position, self)
		if not damage_received:
			return 

	if intruder is TowerHurtbox:
		intruder.take_damage(damage)

	if intruder is Enemy:
		intruder.take_damage(damage, Constants.Element.ARCANE)

	ap.play("hit")

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		queue_free()
