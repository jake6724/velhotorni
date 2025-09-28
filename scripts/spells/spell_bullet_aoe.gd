class_name SpellBulletAOE
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D

var data: SpellDataBullet

const SPEED: float = 300

var move_direction: Vector2
var active: bool = true
var pierce_count: int = 0

var original_position: Vector2

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	area.area_entered.connect(on_area_entered)
	area.body_entered.connect(on_body_entered)
	original_position = global_position

func initialize(_data: SpellDataBullet, cast_direction: Vector2) -> void:
	data = _data
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 

	ap.play("move")

func move(delta) -> void:
	if active:
		global_position += move_direction * SPEED * delta

		# print(abs(global_position.distance_to(original_position)))
		# print("MAX DISTANCE: ",data.max_distance)
		# if abs(global_position.distance_to(original_position)) > data.max_distance:
		# 	active = false
		# 	ap.play("hit")

func _physics_process(delta):
	move(delta)

## Hit enemy
func on_area_entered(enemy: Enemy) -> void:
	if active:
		enemy.take_damage(10, Constants.Element.FIRE)
		pierce_count += 1

	if pierce_count >= data.pierce:
		active = false
		ap.play("hit")

## Hit Terrain Obstacle
func on_body_entered(_intruder) -> void:
	active = false
	ap.play("hit")

func on_animation_finished(anim_name) -> void:
	if anim_name == "hit":
		queue_free()
