extends Camera2D

@export var power: float
@export var decay: float 
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var curr_power: float

func apply_shake() -> void:
	curr_power = power

func _process(delta):
	if Input.is_action_just_pressed("x"):
		apply_shake()

	if curr_power > .1:
		curr_power = snappedf(lerpf(curr_power, 0, decay * delta), 0.01)
		offset = get_random_offset()
	else:
		offset = Vector2.ZERO

func get_random_offset() -> Vector2:
	return Vector2(rng.randf_range(-curr_power, curr_power), rng.randf_range(-curr_power, curr_power))