class_name PlayerNumberPopup
extends Node2D

var font: FontFile = preload("res://assets/fonts/Early-GameBoy-Jake-Edit.ttf")
const color_white: String = "#FFFFFF"
const color_black: String = "#000000"

var up_distance: float = 16
var up_time: float = .25

func display_number(value: int, pos: Vector2):
	var number: Label = Label.new()
	number.global_position = to_local(pos)
	number.text = str(value)
	number.label_settings = LabelSettings.new()

	number.label_settings.font_color = color_white
	number.label_settings.font_size = 8
	number.label_settings.font = font
	number.label_settings.outline_color = color_black
	number.label_settings.outline_size = 4

	call_deferred("add_child", number)
	await number.resized

	number.pivot_offset = Vector2(number.size / 2)
	number.position.x -= number.size.x / 2

	var tween = get_tree().create_tween()
	# tween.set_parallel(true) ? 
	tween.tween_property(number, "position:y", number.position.y - up_distance, up_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, .5).set_ease(Tween.EASE_IN)
	tween.tween_property(number, "scale", Vector2.ZERO, .25).set_ease(Tween.EASE_IN)

	await tween.finished
	number.queue_free()
