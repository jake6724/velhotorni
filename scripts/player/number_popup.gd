class_name NumberPopup
extends Node2D
# https://www.youtube.com/watch?v=F0DQLSiLkjg

var font: FontFile = preload("res://assets/fonts/Early-GameBoy-Jake-Edit.ttf")
const COLOR_WHITE: String = "#FFFFFF"
const COLOR_BLACK: String = "#000000"
# const COLOR_RED: String = "#d63100"
const COLOR_RED: String = "#ed4918"
const NO_MANA_TEXT: String = "EMPTY"
# const pos_offset: Vector2 = Vector2(0, -3)

var outline_size: int = 0
var shadow_offset: Vector2 = Vector2(1,1)
var shadow_size: int = 1

var up_distance: float = 64
var up_time: float = 1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var jitter_range: float = 16

var active_damage_number: Label
var active_damage_number_timer: Timer = Timer.new()
var active_damage_number_horizonal: bool
var parent_max_health: float 

func _ready():
	active_damage_number_timer.one_shot = true
	active_damage_number_timer.autostart = false
	add_child(active_damage_number_timer)
	active_damage_number_timer.timeout.connect(on_active_damage_number_timer_timeout)

func display_damage_number(value: int, pos: Vector2, moving_horizontally: bool=true, display_tint: bool=false) -> void:
	if value > 1:
		if active_damage_number:
			var new_value: int = int(active_damage_number.text) + value
			active_damage_number.text = str(new_value)
			shake_label(active_damage_number)
			active_damage_number_timer.start(.5)
			if display_tint:
				var health_percentage: float = new_value / parent_max_health
				active_damage_number.label_settings.font_color = active_damage_number.label_settings.font_color.lerp(COLOR_RED, health_percentage)

		else:
			var number: Label = Label.new()
			active_damage_number = number
			number.global_position = to_local(global_position)

			number.text = str(value)

			number.label_settings = LabelSettings.new()
			number.label_settings.font_color = Color.WHITE
			number.label_settings.font_size = 8
			number.label_settings.font = font
			number.label_settings.outline_color = COLOR_WHITE
			number.label_settings.outline_size = outline_size
			number.label_settings.shadow_offset = shadow_offset
			number.label_settings.shadow_size = shadow_size
			number.label_settings.shadow_color = COLOR_BLACK
			
			var health_percentage: float = min(1, value / parent_max_health)
			number.label_settings.font_color = number.label_settings.font_color.lerp(COLOR_RED, health_percentage)

			call_deferred("add_child", number)
			z_as_relative = false
			number.z_index = Constants.z_index_map["popup"]
			await number.resized

			number.pivot_offset.x = (number.size.x / 2)

			if moving_horizontally:
				number.position.y += get_jitter()
			else:
				number.position.x += get_jitter()

			var tween = get_tree().create_tween()
			tween.tween_property(number, "position:y", number.position.y - 2, 1.2).set_ease(Tween.EASE_OUT)
			
			active_damage_number_timer.start(1)

func on_active_damage_number_timer_timeout() -> void:
	if active_damage_number:
		var temp = active_damage_number
		active_damage_number = null
		animate_label_die(temp)

func get_jitter() -> float:
	var x = rng.randf_range(10,15)
	x *= [1,-1].pick_random()
	return x

# func get_random_position_offset() -> Vector2:
# 	var random_angle: float = randf() * .5 * PI
# 	var random_direction: Vector2 = Vector2.RIGHT.rotated(random_angle)
# 	# var _direction: Vector2 = Vector2(rng.randf_range(-1,1), rng.randf_range(-.4,.4))
# 	# _direction = _direction.normalized()

# 	var pos_offset: Vector2 = random_direction * randf_range(10,20)
# 	print(rad_to_deg(pos_offset.angle()))
# 	return pos_offset

func shake_label(label: Label) -> void:
	var shake_tween: Tween = get_tree().create_tween()
	var shake_range: float = 6.3
	var shake_duration: float = .03
	var scale_target: Vector2 = Vector2(1.3, 1.3)
	shake_tween.tween_property(label, "rotation_degrees", shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(label, "rotation_degrees", 0, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(label, "rotation_degrees", -shake_range, shake_duration)
	shake_tween.tween_interval(shake_duration)
	shake_tween.tween_property(label, "rotation_degrees", 0, shake_duration)
	shake_tween.tween_interval(shake_duration)

	var scale_tween: Tween = get_tree().create_tween()
	scale_tween.tween_property(label, "scale", scale_target, .03)
	scale_tween.tween_interval(shake_duration)
	scale_tween.tween_property(label, "scale", Vector2.ONE, .03)

func animate_label_die(label: Label) -> void:
	var scale_tween: Tween = get_tree().create_tween()
	var scale_target: Vector2 = Vector2(.1, .1)
	scale_tween.tween_property(label, "scale", scale_target, .1)
	await scale_tween.finished
	label.queue_free()

func display_mana_empty(_pos: Vector2) -> void:
	var number: Label = Label.new()
	number.global_position = to_local(global_position) + Vector2(0, -10)
	number.z_index = Constants.z_index_map["popup"]
	number.text = str(NO_MANA_TEXT)

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

	# Blink
	var blink_tween = get_tree().create_tween()
	blink_tween.set_loops(5)
	blink_tween.tween_property(number, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(.125)
	blink_tween.tween_property(number, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(.125)

	var tween = get_tree().create_tween()
	tween.tween_property(number, "position:y", number.position.y - up_distance, .75)
	await tween.finished
	animate_label_die(number)

func display_tower_heal(_pos: Vector2, value: int, max_value: int) -> void:
	var number: Label = Label.new()
	number.global_position = to_local(global_position)
	number.z_index = Constants.z_index_map["popup"]
	number.text = str(value,"/",max_value)

	number.label_settings = LabelSettings.new()
	number.label_settings.font_color = Constants.color_green
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
	number.position.x += get_jitter()

	var tween = get_tree().create_tween()
	tween.tween_property(number, "position:y", number.position.y - up_distance, up_time).set_ease(Tween.EASE_OUT)
	# tween.tween_interval(.1)
	await tween.finished
	animate_label_die(number)
