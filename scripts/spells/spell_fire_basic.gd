class_name SpellFireBasic
extends Spell

const SPEED: float = 300

var move_direction: Vector2

func start(cast_direction: Vector2) -> void:
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 

func move(delta) -> void:
	global_position += move_direction * SPEED * delta

func _physics_process(delta):
	move(delta)
