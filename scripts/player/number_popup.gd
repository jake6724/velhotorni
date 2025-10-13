class_name NumberPopup
extends Node
# https://www.youtube.com/watch?v=F0DQLSiLkjg

var font: FontFile = preload("res://assets/fonts/Early-GameBoy-Jake-Edit.ttf")
const COLOR_WHITE: String = "#FFFFFF"
const COLOR_BLACK: String = "#000000"
const pos_offset: Vector2 = Vector2(0, -3)

var outline_size: int = 0
var shadow_offset: Vector2 = Vector2(1,1)
var shadow_size: int = 1


var up_distance: float = 64
var up_time: float = 1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var jitter_range: float = 5

var element_text: Dictionary[Constants.Element, String] = {
	Constants.Element.FIRE: "FIRE MANA",
	Constants.Element.WIND: "WIND MANA",
	Constants.Element.WATER: "WATER MANA",
	Constants.Element.EARTH: "EARTH MANA",
	Constants.Element.LIGHT: "LIGHT MANA",
	Constants.Element.DARK: "DARK MANA",
	Constants.Element.ARCANE: "ARCANE MANA",
	Constants.Element.NONE: "",
}

func display_mana_number(value: int, pos: Vector2, element: Constants.Element = Constants.Element.NONE):
	var number: Label = Label.new()
	number.global_position = pos
	number.z_index = Constants.z_index_map["popup"]
	number.text = str("+", str(value), " ", element_text[element])
	number.label_settings = LabelSettings.new()

	number.label_settings.font_color = COLOR_WHITE
	number.label_settings.font_size = 8
	number.label_settings.font = font
	number.label_settings.outline_color = COLOR_WHITE
	number.label_settings.outline_size = outline_size
	number.label_settings.shadow_offset = shadow_offset
	number.label_settings.shadow_size = shadow_size
	number.label_settings.shadow_color = COLOR_BLACK

	call_deferred("add_child", number)
	await number.resized

	number.pivot_offset = Vector2(number.size / 2)
	number.position.x -= number.size.x / 2

	var tween = get_tree().create_tween()
	tween.tween_property(number, "position:y", number.position.y - up_distance, up_time).set_ease(Tween.EASE_OUT)
	tween.tween_interval(.1)
	await tween.finished

	# Blink
	var blink_tween = get_tree().create_tween()
	blink_tween.set_loops(5)
	blink_tween.tween_property(number, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(.075)
	blink_tween.tween_property(number, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(.075)

	await blink_tween.finished
	number.queue_free()

func display_damage_number(value: int, pos: Vector2) -> void:
	var number: Label = Label.new()
	number.global_position = pos + pos_offset
	number.z_index = Constants.z_index_map["popup"]
	number.text = str(value)

	number.label_settings = LabelSettings.new()
	number.label_settings.font_color = COLOR_WHITE
	number.label_settings.font_size = 8
	number.label_settings.font = font
	number.label_settings.outline_color = COLOR_WHITE
	number.label_settings.outline_size = outline_size
	number.label_settings.shadow_offset = shadow_offset
	number.label_settings.shadow_size = shadow_size
	number.label_settings.shadow_color = COLOR_BLACK

	call_deferred("add_child", number)
	await number.resized

	number.pivot_offset.x = (number.size.x / 2)
	number.position.x += ((number.size.x / 2) + get_jitter())

	var tween = get_tree().create_tween()
	tween.tween_property(number, "position:y", number.position.y - 8, .5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(.1)
	await tween.finished
	number.queue_free()

func get_jitter() -> float:
	return rng.randf_range(-jitter_range, jitter_range)