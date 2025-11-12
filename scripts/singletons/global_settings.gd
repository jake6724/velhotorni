extends Node

var controller_active: bool = false:
	set(value):
		controller_active = value
		input_type_changed.emit()

signal input_type_changed

func on_input_type_changed(_controller_active: bool) -> void:
	controller_active = _controller_active
