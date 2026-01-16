class_name EnemySnakeNode
extends Sprite2D

var target # Set by EnemySnake parent
var speed: float 

func _physics_process(_delta):
	# var direction = global_position.direction_to(target.global_position)
	# global_position += direction.round().normalized() * speed * delta

	global_position = global_position.lerp(target.global_position, speed /1000)