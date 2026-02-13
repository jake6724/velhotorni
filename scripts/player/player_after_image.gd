class_name PlayerAfterImage
extends Sprite2D

var lifetime: float # Set by PlayerSpecial

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
