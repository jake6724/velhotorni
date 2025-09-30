class_name SpellBullet
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D

var move_direction: Vector2
var active: bool = true
var pierce_count: int = 0

var original_position: Vector2

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	area.area_entered.connect(on_area_entered)
	area.body_entered.connect(on_body_entered)
	ap.play("move")

func initialize(_data: SpellDataBullet, cast_direction: Vector2) -> void:
	data = _data
	original_position = global_position
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 

	texture = data.atlas

func move(delta) -> void:
	if active:
		global_position += move_direction * data.speed * delta

	check_max_distance_reached()

func _physics_process(delta):
	move(delta)

## Hit enemy
func on_area_entered(enemy: Enemy) -> void:
	if active:
		deal_damage(enemy)
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

func check_max_distance_reached() -> void:
	if active and abs(global_position.distance_to(original_position)) > data.max_distance:
		active = false
		ap.play("hit")

func deal_damage(enemy: Enemy) -> void:
	enemy.take_damage(data.damage, data.element)