class_name NewBullet
extends Sprite2D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var primary_area: Area2D = $PrimaryArea
@onready var primary_collider: CollisionShape2D = $ PrimaryArea/PrimaryCollider
@onready var aoe_area: Area2D = $AOEArea
@onready var aoe_collider: CollisionShape2D = $AOEArea/AOECollider

var target: Enemy
var data: BulletData
var target_death_pos: Vector2
var is_active: bool = false # set true in initialize(). Tracks whether bullet should move # TODO: maybe rename?

var _pos_offset: Vector2 = Vector2(8,8) # Hard-code works unless tower sprite size changes
var _original_global_position: Vector2
var _target_direction: Vector2
var _min_distance: float

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

	_original_global_position = global_position
	_min_distance = 11 # TODO: idk

func initialize(_target: Enemy, _data: BulletData) -> void:
	target = _target
	data = _data
	is_active = true

func _physics_process(_delta):
	pass

func on_primary_area_entered(_intruder: Node2D) -> void:
	pass

func on_aoe_area_entered(_intruder: Node2D) -> void:
	pass

func on_animation_finished(_anim_name: String) -> void:
	pass

func on_target_died(_pos: Vector2) -> void:
	pass