class_name PlayerCamera
extends Camera2D

@export var power: float
@export var decay: float 


var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var curr_power: float
var shake_offset: Vector2 = Vector2.ZERO

var aim_follow_offset: Vector2 = Vector2.ZERO
var aim_follow_multiplier: float = 40.0
var aim_follow_speed: float = .3
var prev_aim_input: Vector2

func apply_shake(power_scale: float) -> void:
	var new_power: float = power * power_scale
	if new_power >= curr_power:
		curr_power = new_power

func _process(delta):
	if owner.aim_input != prev_aim_input:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "aim_follow_offset", (owner.aim_input * aim_follow_multiplier), aim_follow_speed)
		prev_aim_input = owner.aim_input

	if curr_power > .1:
		curr_power = snappedf(lerpf(curr_power, 0, decay * delta), 0.01)
		shake_offset = get_random_offset()
	else:
		shake_offset = Vector2.ZERO

	offset = shake_offset + aim_follow_offset

func get_random_offset() -> Vector2:
	return Vector2(rng.randf_range(-curr_power, curr_power), rng.randf_range(-curr_power, curr_power))