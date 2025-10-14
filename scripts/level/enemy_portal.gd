class_name EnemyPortal
extends AnimatedSprite2D

var open: bool = false

func start() -> void:
	show()
	play("open")
	open = true

