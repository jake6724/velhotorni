class_name EnemyBullet
extends Sprite2D

@onready var detect_player_area: Area2D = $DetectPlayerArea
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
	detect_player_area.body_entered.connect(on_player_detected)
	ap.animation_finished.connect(on_animation_finished)

func initialize(_player_pos: Vector2, _spawn_pos: Vector2, _damage: float, _speed: float, _max_distance: float, _follow_on_hit: bool, _z_index: int, atlas: CompressedTexture2D) -> void:
	player_pos = _player_pos
	damage = _damage
	speed = _speed
	max_distance = _max_distance
	follow_on_hit = _follow_on_hit
	spawn_pos = _spawn_pos
	global_position = _spawn_pos + Vector2(8,8)
	self.texture = atlas
	z_index = _z_index
	direction = global_position.direction_to(player_pos)
	ap.play("move")

func _physics_process(delta) -> void:
	move(delta)

func move(delta) -> void:
	if active:
		global_position += direction * speed * delta
		if global_position.distance_to(spawn_pos) > max_distance:
			active = false
			ap.play("hit")

func on_player_detected(player: PlayerCharacter) -> void:
	active = false

	# player.take_damage

	ap.play("hit")

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		queue_free()
