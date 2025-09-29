class_name PlayerCamera
extends Camera2D

@export var power: float
@export var decay: float 
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var curr_power: float
var aim_follow_multiplier: float = 40.0
var aim_follow_speed: float = .3

func apply_shake(power_scale: float) -> void:
	var new_power: float = power * power_scale
	if new_power >= curr_power:
		curr_power = new_power

func _process(delta):
	if curr_power > .1:
		curr_power = snappedf(lerpf(curr_power, 0, decay * delta), 0.01)
		offset = get_random_offset()
	else:
		offset = Vector2.ZERO

	# offset += owner.aim_input * aim_follow_multiplier
	var tween = get_tree().create_tween()
	tween.tween_property(self, "offset", (owner.aim_input * aim_follow_multiplier), aim_follow_speed)

func get_random_offset() -> Vector2:
	return Vector2(rng.randf_range(-curr_power, curr_power), rng.randf_range(-curr_power, curr_power))

# func on_aim_input_updated(aim_input) -> void:
# 	print("TEST")
# 	var tween = get_tree().create_tween()
# 	tween.tween_property(self, "global_position", aim_input * aim_follow_multiplier, .1)

# func follow_aim() -> void: