@tool
class_name ControllerButtonHint
extends TextureRect


func set_hint_icon(_button_name: String):
	match _button_name:
		"joypad_button_0": texture.region = Rect2(3.0, 3.0, 10.0, 10.0)
		"joypad_button_2": texture.region = Rect2(35.0, 3.0, 10.0, 10.0)  