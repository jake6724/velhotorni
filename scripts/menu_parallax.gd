extends Node2D

@export var follow_speed := 5.0

var base_positions := {}

func _ready():
	for child in get_children():
		if child is Sprite2D:
			base_positions[child] = child.position

func _process(delta):
	var center = get_viewport_rect().size * 0.5
	var offset = get_viewport().get_mouse_position() - center

	for child in get_children():
		if child is Sprite2D:
			var strength: float = child.get_meta("parallax_strength", 1.0)

			var base = base_positions[child]
			var target = base + offset * strength

			child.position = child.position.lerp(target, follow_speed * delta)
