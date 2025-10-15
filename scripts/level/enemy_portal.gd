class_name EnemyPortal
extends AnimatedSprite2D

var open: bool = false

func start() -> void:
	show()
	play("open")
	await animation_finished
	play("idle")
	open = true

func close() -> void:
	play("close")
	await animation_finished
	hide()
	open = false

func preview() -> void:
	show()
	play("star")