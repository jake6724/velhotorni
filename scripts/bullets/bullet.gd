class_name Bullet
extends Sprite2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var primary_area: Area2D = $PrimaryArea
@onready var primary_collider: CollisionShape2D = $ PrimaryArea/PrimaryCollider
@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

@export var data: BulletData

var target: Enemy
var target_death_pos: Vector2
var is_active: bool = false

var _pos_offset: Vector2 = Vector2(Constants.CELL_SIZE/2,Constants.CELL_SIZE/2)
var _original_global_position: Vector2
var _target_direction: Vector2
var _min_distance: float

var direction_at_collision: Vector2 # Shot animation will move in this direction

func _ready() -> void:
	# Configure children
	primary_area.area_entered.connect(on_primary_area_entered)
	aoe_area.area_entered.connect(on_aoe_area_entered)
	
	aoe_collider.disabled = true

	ap.animation_finished.connect(on_animation_finished)

	# Connect to target
	if target and target.is_alive:
		_target_direction = global_position.direction_to(target.global_position + _pos_offset)
		target.death_position.connect(on_target_died)
		if _target_direction == Vector2.ZERO:
			queue_free()

	_original_global_position = global_position
	_min_distance = 11 # This is here to prevent unused warning if I just set it above

func initialize(_target: Enemy, _element: Constants.Element, _damage: float, _debuff_data, _speed: float, _max_distance) -> void:
	data.element = _element
	data.damage = _damage
	data.debuff_data = _debuff_data
	data.speed = _speed
	data.max_distance = _max_distance + (_max_distance * .5)
	target = _target
	is_active = true

func _physics_process(delta):
	if is_active:
		ap.play("move")
		# Target exists and is alive; move toward target an explode on collision
		if target and target.is_alive and not target.collider.disabled:
			global_position = global_position + ((global_position.direction_to(target.global_position + _pos_offset)) * data.speed * delta)
		
		# Target does not exist or is dead
		else:
			queue_free()

	else:
		if target and target.is_alive:
			if data.follow_on_hit:
				global_position = target.global_position + _pos_offset
			else:
				# Move in a straight line after colliding with enemy (for hit animation)
				global_position = global_position + (direction_at_collision * data.speed  * delta)
		else:
			queue_free()

func on_primary_area_entered(intruder: Node2D) -> void:
	if is_active:
		if intruder == target:
			direction_at_collision = global_position.direction_to(target.global_position + _pos_offset)
			is_active = false
			target.take_damage(data.damage, data.element)
			if data.debuff_data and target.debuff_manager:
				target.debuff_manager.add_debuff(data.debuff_data)

			ap.play("hit")

func on_aoe_area_entered(_intruder: Node2D) -> void:
	pass

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		queue_free()

func on_target_died(_pos: Vector2) -> void:
	pass
